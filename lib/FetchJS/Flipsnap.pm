package FetchJS::Flipsnap;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version ||= 'master';

  my $uri = "https://github.com/pxgrid/js-flipsnap/zipball/$version";

  my $zipball = $self->fetch($uri => "flipsnap.zip");
  $self->unzip($zipball,
    [qr/\.js$/ => 'js'],
  );
}

1;

__END__

=head1 NAME

FetchJS::Flipsnap - fetch flipsnap (for mobile)

=head1 SYNOPSIS

  fetch_js flipsnap [<version>]

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
