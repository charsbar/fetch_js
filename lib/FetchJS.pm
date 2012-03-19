package FetchJS;

use strict;
use warnings;
use File::Spec;
use Path::Extended;
use File::HomeDir;
use List::Util qw/first/;
use base 'CLI::Dispatch::Command';

our $VERSION = '0.01';

sub options {qw/dir=s tmpdir=s minify|min debug/, shift->_options}
sub _options {return ()}

sub run { shift->_prepare->_run(@_) }

sub _prepare {
  my $self = shift;
  if ($self->{debug}) {
    $self->{tmpdir} ||= '.';
    $self->{verbose} = 1;
  }

  $self->{_rootdir} = _find_root($self->{dir});
  $self->{_tmpdir}  = dir($self->{tmpdir} || File::Spec->tmpdir);
  $self->{_config}  = do($self->_config_file->path) || {};
  $self;
}

sub _find_root {
  my $dir = shift;

  my $root;
  for ($dir, qw/public root public_html html/) {
    next unless $_;
    $root = dir($_);
    next unless $root->exists && $root->is_dir;
    my $static = $root->subdir('static');
    return $static if $static->exists && $static->is_dir;
    return $root;
  }
  die "Can't find a directory to store js/css/images\n";
}

sub _fixdir {
  my ($self, $dir) = @_;
  return $dir unless ref $dir eq ref [];
  for (@$dir) {
    return $_ if $self->{_rootdir}->subdir($_)->exists;
  }
  return $dir->[0];
}

sub _file {
  my $self = shift;
  $self->{_rootdir}->file($self->_fixdir(shift), @_);
}

sub _dir {
  my $self = shift;
  $self->{_rootdir}->subdir($self->_fixdir(shift), @_);
}

sub _tmpfile { shift->{_tmpdir}->file(@_) }

sub _home { shift->{_home} ||= dir(File::HomeDir->my_home, '.fetch_js')->mkdir }

sub _config_file { shift->_home->file('fetch_js_conf.pl') }

sub conf {
  my $self = shift;
  my ($basename) = ref $self =~ /::([^:]+)$/;
  if (@_) {
    $self->{_config}{$basename} = @_ > 1 ? {@_} : shift;
  }
  $self->{_config}{$basename} || {};
}

sub _save_config {
  my $self = shift;

  require Data::Dump;
  $self->_config_file->save(Data::Dump::dump($self->{_config} || {}));
}

sub fetch_lwp {
  my ($self, $uri, $name, $postdata) = @_;

  # XXX: this is lame but don't have a tuit to dig into it now
  if ($uri =~ /github\.com/) {
    return $self->fetch_furl($uri, $name, $postdata);
  }

  # TODO: post by LWP
  if ($postdata) {
    return $self->fetch_furl($uri, $name, $postdata);
  }

  unless ($name) {
    require URI;
    $name = (split '/', URI->new($uri)->path)[-1];
  }
  my $file = $self->_tmpfile($name);

  require LWP::UserAgent;
  my $ua = LWP::UserAgent->new(
    env_proxy => 1,
    ssl_opts => {verify_hostname => 0},
  );
  $ua->show_progress(1) if $self->{verbose};

  my $res = $ua->mirror($uri => $file);

  if ($res->is_error) {
    die "Can't fetch $name: ".$res->status_line."\n";
  }

  $file;
}

sub fetch_furl {
  my ($self, $uri, $name, $postdata) = @_;

  unless ($name) {
    require URI;
    $name = (split '/', URI->new($uri)->path)[-1];
  }
  my $file = $self->_tmpfile($name);

  my @headers;
  if ($file->exists) {
    my $mtime = $file->mtime;
    require HTTP::Date;
    push @headers, ('If-Modified-Since' => HTTP::Date::time2str($mtime));
  }

  print STDERR "fetching $uri ... " if $self->{verbose};

  my ($received, $content_length, $threshold, $next) = (0, 0, 0, 0);
  my $is_verbose = $self->{verbose} ? 1 : 0;

  require Furl;
  my $ua = Furl->new;
  my $res = $ua->request(
    method  => $postdata ? 'POST' : 'GET',
    url     => $uri,
    headers => \@headers,
    content => $postdata,
    write_code => sub {
      my ($status, $msg, $headers, $buf) = @_;
      unless ($content_length) {
        $content_length = $headers->{'content-length'} || -1;
        $next = $threshold = int($content_length / 100);
      }

      unless ($file->is_open) {
        $file->openw;
        $file->binmode;
      }

      $file->print($buf);
      my $buflen = length $buf;
      $received += $buflen;
      if ($is_verbose and $content_length > 0 and $received > $next) {
        my $progress = int($received / $content_length * 100);
        printf STDERR "%3.0f%%\b\b\b\b", $progress;
        $next = $threshold * $progress;
      }
    },
  );
  print STDERR "\n" if $is_verbose;
  $file->close if $file->is_open;

  if ($res->code !~ /^[23]\d\d$/) {
    die "Can't fetch $name: ".$res->status_line."\n";
  }
  elsif ($res->is_success) {
    my $size = $file->stat->size;
    my $clen = $res->content_length;
    if (defined $clen and $size < $clen) {
      $file->remove;
      die "Transfer truncated: only $size out of $clen bytes received\n";
    }
    elsif (defined $clen and $size > $clen) {
      $file->remove;
      die "Content-Length mismatch: expected $clen bytes, got $size\n";
    }
    else {
      if (my $lm = $res->headers->last_modified) {
        require HTTP::Date;
        my $mtime = HTTP::Date::str2time($lm);
        $file->mtime($mtime) if $mtime;
      }
    }
  }
  else {
    warn $res->status_line;
  }
  $file;
}

*fetch = \&fetch_lwp;

sub unzip {
  my ($self, $zipball, @wants) = @_;

  require Archive::Zip;
  my $zip = Archive::Zip->new($zipball->path) or return;

  my @rules = _rules(@wants);
  my $root  = _root(map { $_->fileName} $zip->members);

  for my $member ($zip->members) {
    my $name = $member->fileName;
    $self->log(debug => $name);
    $name =~ s/^$root// if $root;
    my $rule;
    if (!@wants or $rule = first {$name =~ /$_->[0]/} @rules) {
      $self->log(info => "extracted $name");
      my $dest = $rule ? $rule->[1] : "";
      if (ref $dest eq ref sub {}) {
        $dest->($name);
        $dest = "";
      }
      my $file = $self->_file($dest, $name);
      $member->extractToFileNamed($file->path);

      _minify($file) if $self->{minify};
    }
  }
  $zipball->remove unless $self->{debug};
}

sub untar {
  my ($self, $tarball, @wants) = @_;

  require Archive::Tar;
  my $tar = Archive::Tar->new($tarball->path) or return;

  my @rules = _rules(@wants);
  my $root  = _root($tar->list_files);

  for my $name ($tar->list_files) {
    my $path = $name;
    $self->log(debug => $name);
    $path =~ s/^$root// if $root;
    my $rule;
    if (!@wants or $rule = first {$path =~ /$_->[0]/} @rules) {
      $self->log(info => "extracted $name");
      my $dest = $rule ? $rule->[1] : "";
      if (ref $dest eq ref sub {}) {
        $dest->($path);
        $dest = "";
      }
      my $file = $self->_file($dest, $path);
      $tar->extract_file($name, $file->path);

      _minify($file) if $self->{minify};
    }
  }
  $tarball->remove unless $self->{debug};
}

sub _rules {
  my @wants = @_;

  my @rules;
  for (@wants) {
    if (ref $_ eq ref []) {
      if (ref $_->[0] eq ref qr//) {
        push @rules, [$_->[0], $_->[1]];
      }
      else {
        push @rules, [qr/^$_->[0]$/, $_->[1]];
      }
    }
    else {
      if (ref $_ eq ref qr//) {
        push @rules, [$_ => 'js'];
      }
      else {
        push @rules, [qr/^$_$/ => 'js'];
      }
    }
  }
  @rules;
}

sub _root {
  my $root = '';
  for my $name (@_) {
    unless ($root) {
      ($root) = $name =~ m{([^/]+/)};
      last unless $root;
    }
    unless ($name =~ m/^$root/) {
      $root = '';
      last;
    }
  }
  $root;
}

sub _minify {
  my $file = shift;
  my $name = $file->basename;
  return if $name =~ /\.min\./;

  my $source = $file->slurp;
  my $minified;
  if ($file =~ /\.js/) {
    require JavaScript::Minifier::XS;
    $minified = eval { JavaScript::Minifier::XS::minify($source) }
      or do { warn "Can't minify $file: $@"; return };
    $name =~ s/\.js$/.min.js/;
  }
  if ($file =~ /\.css/) {
    require CSS::Minifier::XS;
    $minified = eval { CSS::Minifier::XS::minify($source) }
      or do { warn "Can't minify $file: $@"; return };
    $name =~ s/\.css$/.min.css/;
  }
  $file->parent->file($name)->save($minified);
}

1;

__END__

=head1 NAME

FetchJS - fetch js (and other static files I use for web apps)

=head1 SYNOPSIS

  fetch_js <jquery|highcharts|...> [--dir=...] [--tmpdir=...] [--minify]

=head1 TODO

=over 4

=item List available versions (scrape?)

=item dynamic build (ant/make/rake...)?

=back

=head1 METHODS

=head2 fetch, fetch_lwp, fetch_furl ($uri, $file, $postdata)

=head2 unzip ($file, @wants)

=head2 options, run

No need to care. Used internally for L<CLI::Dispatch::Command>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
