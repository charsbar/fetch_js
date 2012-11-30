package FetchJS::PowerTip;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version ||= '1.1.0';
  my $uri = "https://github.com/downloads/stevenbenner/jquery-powertip/jquery.powertip-$version.zip";
  my $zipball = $self->fetch($uri => "powertip.zip");
  $self->unzip($zipball,
    [qr/\.js$/  => 'js'],
    [qr/\.css$/ => 'css'],
  );
}

sub _list { shift->_github_list("/stevenbenner/jquery-powertip") }

1;

__END__

=head1 NAME

FetchJS::PowerTip - fetch jquery.powertip

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
