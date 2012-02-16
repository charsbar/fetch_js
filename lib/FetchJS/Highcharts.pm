package FetchJS::Highcharts;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version ||= 'v2.1.9';

  if ($version =~ /^[0-9]+\.[0-9]+\.[0-9]+$/) {
    $version = "v$version";
  }
  my $uri = "https://github.com/highslide-software/highcharts.com/zipball/$version";

  my $zipball = $self->fetch_furl($uri => 'highcharts.zip') or return;
  $self->unzip($zipball,
    [qr{js/\S+\.js$} => ''],
  );
}

1;

__END__

=head1 NAME

FetchJS::Highcharts - fetch Highcharts

=head1 SYNOPSIS

  fetch_js highcharts [<version>]

=head1 DESCRIPTION

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
