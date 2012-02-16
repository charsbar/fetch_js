package FetchJS::Zepto;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version ||= '0.8';
  my $uri = "http://zeptojs.com/downloads/zepto-$version.zip";

  my $zipball = $self->fetch($uri => "zepto.zip") or return;

  $self->unzip($zipball,
    [qr{dist/\S+.js} => sub { $_[0] =~ s/^dist/js/ }],
  );
}

1;

__END__

=head1 NAME

FetchJS::Zepto - fetch zepto.js (for mobile)

=head1 SYNOPSIS

  fetch_js zepto

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
