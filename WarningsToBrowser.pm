package WarningsToBrowser;

use strict;
use warnings;

# HTMLで<body>が見付かったとき
#   <body>の下に足す
# HTMLで<body>が見付からなかったとき
#   末尾に足す
# テキストの時
#   末尾に足す
# 他テキストの時 CSVなど
#   末尾に足す
# 画像の時
#   何もしない
# メディアの時
#   何もしない
# Content-typeが無いとき
#   Content-type: text/plainを付けて、足す
# Content-typeが不明な時
#   何もしない

our $HTML = <<'HTML';
<div style="border: 1px solid gray; padding: 10px;">
    <b>STDERR (return code: %d)</b>
    <pre>%s</pre>
</div>
HTML
chop($HTML);

{
    my $orig_stdout;
    my $orig_stderr;
    my $r_stdout;
    my $r_stderr;

    BEGIN {
        begin_capture_stdios: {
            open($orig_stdout, ">&=", fileno(STDOUT));
            open($orig_stderr, ">&=", fileno(STDERR));
            close(STDOUT);
            close(STDERR);

            pipe($r_stdout, STDOUT);
            pipe($r_stderr, STDERR);
        }
    }

    END {
        my $content;
        my $warning;

        end_capture_stdios: {
            close(STDOUT);
            close(STDERR);

            $content = do { local $/; <$r_stdout> };
            $warning = do { local $/; <$r_stderr> };
        }
            
        modify_output: {
            unless ( $content =~ m/\A(?:^\S+$)*^content-type:\s*([\w\/]+)/msi ) {
                print $orig_stdout "Content-type: text/plain\n\n";
                $warning .= qq{"Content-type:" header missing.\n};
            }
            my $content_type = $1 || "text/plain";
            my $error_occurred = $?;

            if ( !length($warning) ) {
                print $orig_stdout $content;
            }
            else {
                if ( $content_type =~ m{^text/html}i ) {
                    require HTML::Entities;
                    my $encoded = HTML::Entities::encode($warning);
                    my $error   = sprintf($HTML, $?, $encoded);

                    if ( $content =~ m/body[^>]*>/g ) {
                        $content =~ s/\G/$error/;
                        print $orig_stdout $content;
                    }
                    else {
                        print $orig_stdout $content;
                        print $orig_stdout $error;
                    }
                }
                elsif ( $content_type =~ m{^text/}i ) {
                    print $orig_stdout $content;
                    print $orig_stdout sprintf("\nSTDERR (return code: %d)\n\n%s", $?, $warning);
                }
            }
        }
    }
}

=head1 AUTHOR

Tomohiro Hosaka, C<< <bokutin at bokut.in> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Tomohiro Hosaka, all rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

1;
