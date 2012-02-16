package FetchJS::Tablesorter;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my $self = shift;

  my $uri = "http://autobahn.tablesorter.com/jquery.tablesorter.zip";
  my $zipball = $self->fetch($uri) or return;
  $self->unzip($zipball, qw{
      jquery.metadata.js
      jquery.tablesorter.js
    },
    [qr{themes/[^/]+/\S+\.(gif|png|css)$} => 'tablesorter/'],
  );

  my $pager_name = "jquery.tablesorter.pager.js";
  my $pager_uri = "http://tablesorter.com/addons/pager/$pager_name";
  my $pager = $self->fetch($pager_uri) or return;
  $pager->move_to($self->_file(js => $pager_name));
}

1;

__END__

=head1 NAME

FetchJS::Tablesorter - fetch jquery.tablesorter

=head1 SYNOPSIS

  fetch_js tablesorter

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
