package FetchJS::Jquery;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version = $version ? "-$version" : "";
  my $is_min = $self->{minify} ? ".min" : "";
  my $basename = "jquery$version$is_min.js";
  my $uri = "http://code.jquery.com/$basename";
  my $js = $self->fetch($uri => $basename) or return;
  $js->move_to($self->_file(js => $basename));
}

sub _list {
  my $self = shift;
  my $file = $self->fetch("http://docs.jquery.com/Downloading_jQuery") or die "Can't get list\n";
  my $html = $file->slurp;
  my @links = $html =~ m!<a [^>]*href="http://code\.jquery\.com/jquery-([^"]+)\.js"[^>]*>Uncompressed</a>!g;
  if (!defined wantarray) {
    print " $_\n" for reverse @links;
  }
  else {
    return reverse @links;
  }
}

1;

__END__

=head1 NAME

FetchJS::Jquery - fetch jQuery

=head1 SYNOPSIS

  fetch_js jquery [<version>]

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
