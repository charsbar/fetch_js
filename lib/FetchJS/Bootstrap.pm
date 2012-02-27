package FetchJS::Bootstrap;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  my $uri = $version
    ? "http://github.com/twitter/bootstrap/zipball/v$version"
    : "http://twitter.github.com/bootstrap/assets/bootstrap.zip";
  my $zipball = $self->fetch($uri => "bootstrap.zip");
  $self->unzip($zipball,
    [qr/\.(js|png|css)$/ => ''],
  );
}

1;

__END__

=head1 NAME

FetchJS::Bootstrap - fetch Bootstrap from Twitter

=head1 SYNOPSIS

  fetch_js bootstrap

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
