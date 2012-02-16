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
