package FetchJS::Dygraphs;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  if ($self->{minify}) {
    my $uri = "http://dygraphs.com/dygraph-combined.js";
    my $basename = "dygraph-combined.js";
    my $js = $self->fetch($uri => $basename) or return;
    $js->move_to($self->_file(js => $basename));
  }
  else {
    $version ||= 'master';
    my $uri = "https://github.com/danvk/dygraphs/zipball/$version";

    my $zipball = $self->fetch_furl($uri => "dygraphs.zip") or return;
    $self->unzip($zipball, 
      qr!^[^/]+\.js$!,
      qr!^rgbcolor/[^/]+\.js$!,
      qr!^strftime/[^/]+\.js$!,
    );
  }
}

1;

__END__

=head1 NAME

FetchJS::Dygraphs - fetch dygraphs

=head1 SYNOPSIS

  fetch_js dygraphs

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
