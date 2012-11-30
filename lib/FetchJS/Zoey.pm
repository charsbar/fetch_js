package FetchJS::Zoey;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my $self = shift;

  my $uri = "https://github.com/StanAngeloff/zoey/zipball/develop";
  my $zipball = $self->fetch($uri => "zoey.zip");
  $self->unzip($zipball,
    ['scripts/zoey.js'      => sub {$_[0] =~ s/^scripts/js/ }],
    [qr{release/\S+\.js$}   => sub {$_[0] =~ s/^release/js/ }],
    [qr{release/\S+\.css$}  => sub {$_[0] =~ s/^release/css/ }],
    [qr{release/images/.+$} => sub {$_[0] =~ s/^release// }],
  );
}

sub _list { shift->_github_list("/StanAngeloff/zoey") }

1;

__END__

=head1 NAME

FetchJS::Zoey - fetch Zoey (mobile web app framework)

=head1 SYNOPSIS

  fetch_js zoey

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
