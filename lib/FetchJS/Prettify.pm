package FetchJS::Prettify;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  my $uri = "http://google-code-prettify.googlecode.com/files/prettify-1-Jun-2011.tar.bz2";

  my $tarball = $self->fetch($uri => "prettify.tar.bz2");
  $self->untar($tarball,
    # should put lang-*.js under js/prettify/ (too many plugins)?
    [qr{src/.+\.js$} => sub { $_[0] =~ s{\bsrc\b}{js} }],
    [qr{src/.+\.css$} => sub { $_[0] =~ s{\bsrc\b}{css} }],
    [qr{styles/.+\.css$} => sub { $_[0] =~ s{\bstyles\b}{css} }],
  );
}

1;

__END__

=head1 NAME

FetchJS::Prettify - fetch google-code-prettify

=head1 SYNOPSIS

  fetch_js prettify

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
