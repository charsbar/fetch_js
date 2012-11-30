package FetchJS::Bootstrap;

use strict;
use warnings;
use base 'FetchJS';

sub _options {qw/bootswatch=s/}

sub _run {
  my ($self, $version) = @_;

  my $uri = $version
    ? "http://github.com/twitter/bootstrap/zipball/v$version"
    : "http://twitter.github.com/bootstrap/assets/bootstrap.zip";
  my $zipball = $self->fetch($uri => "bootstrap.zip");
  $self->unzip($zipball,
    [qr/\.(js|png|css)$/ => ''],
  );

  if (my $bootswatch = $self->{bootswatch}) {
    for my $file (qw/bootstrap.css bootstrap.min.css/) {
      my $bootswatch_uri = "http://bootswatch.com/$bootswatch/$file";
      my $css = $self->fetch($bootswatch_uri => $file);
      unless ($css) {
        $self->log(error => "Can't fetch $bootswatch theme");
        return;
      }
      $css->move_to($self->_file(css => $file));
    }
  }
}

sub _list { shift->_github_list("/twitter/bootstrap") }

1;

__END__

=head1 NAME

FetchJS::Bootstrap - fetch Bootstrap from Twitter

=head1 SYNOPSIS

  fetch_js bootstrap [--bootswatch=<simplex|...>]

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
