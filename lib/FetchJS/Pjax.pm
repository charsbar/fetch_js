package FetchJS::Pjax;

use strict;
use warnings;
use base 'FetchJS';

sub _run {
  my ($self, $version) = @_;

  $version ||= 'master';
  my $uri = "https://github.com/defunkt/jquery-pjax/zipball/$version";

  my $zipball = $self->fetch_furl($uri => "pjax.zip") or return;
  $self->unzip($zipball, qw{
    jquery.pjax.js
  });
}

sub _list { shift->_github_list("/defunkt/jquery-pjax") }

1;

__END__

=head1 NAME

FetchJS::Pjax - fetch jquery.pjax

=head1 SYNOPSIS

  fetch_js pjax

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
