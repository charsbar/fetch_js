package FetchJS::Tinymce;

use strict;
use warnings;
use base 'FetchJS';

sub _options {qw/jquery dev lang=s/}

sub _run {
  my ($self, $version) = @_;

  $version ||= '3.4.8';
  my $type = $self->{jquery} ? "_jquery" :
             $self->{dev}    ? "_dev"    : "";

  my $uri = "https://github.com/downloads/tinymce/tinymce/tinymce_$version$type.zip";
  my $zipball = $self->fetch($uri => "tinymce.zip");
  $self->unzip($zipball,
    [qr{jscripts/\S+.(js|png|gif|jpg|css)$} => sub { $_[0] =~ s/jscripts/js/ }],
  );

  my @langs = $self->{lang} ? split ',', $self->{lang} : qw/ja/;
  my $lang_uri = "http://www.tinymce.com/i18n/index.php?ctrl=export&act=zip";
  my $langfile = $self->fetch($lang_uri => "tinymce_lang.zip", {
    la_export => 'js',
    pr_id => 7,
    submitted => 'Download',
    (map {("la[]" => $_)} @langs),
  });
  $self->unzip($langfile, [qr/\.js$/ => sub { $_[0] =~ s{^tinymce_language_pack/}{js/tiny_mce/} } ]);
}

sub _list { shift->_github_list("/tinymce/tinymce") }

1;

__END__

=head1 NAME

FetchJS::Tinymce - fetch TinyMCE

=head1 SYNOPSIS

  fetch_js tinymce [<version>] [--lang=ja,zh-cn,...] [--jquery]

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
