package FetchJS::Html5;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version ||= 'master';
  my $uri = "https://github.com/aFarkas/html5shiv/zipball/$version";

  my $zipball = $self->fetch_furl($uri => "html5.zip") or return;
  $self->unzip($zipball, (
    [qr{src/.+\.js$} => sub { $_[0] =~ s/\bsrc\b/js/ }],
  ));
}

sub _list { shift->_github_list("/aFarkas/html5shiv") }

1;

__END__

=head1 NAME

FetchJS::Html5 - fetch html5.js

=head1 SYNOPSIS

  fetch_js html5

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
