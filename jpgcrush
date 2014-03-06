#!/usr/bin/perl -s
# jpgcrush by Loren Merritt
# Last updated: 2008-11-29
# This code is public domain.

@ARGV or die <<EOT;
usage: jpgcrush [opts] foo.jpg [...]
-f   fast (constant scan order rather than search)
-g   convert to grayscale (implies -f)
-r   restart markers
EOT

$n=0;
$opts = "-optimize";
$g and $opts .= " -grayscale";
$r and $opts .= " -restart 1";
$f ||= $g;
$iss = $css = .001;

foreach $if (@ARGV) {
    # `file` isn't always correct
    my $type = `file -b "$if"`;
    if($if !~ /\.jpe?g$/i or $type =~ /PNG|MNG|PPM|PGM|bitmap|ASCII/) {
        warn "\n$if isn't a jpeg\n";
        next;
    } elsif($type !~ /JPEG/) {
        warn "\n$if might not be a jpeg:  $type\n";
    }

    ($cf = $if) =~ s/^.*\///;
    $cf = "_$cf.c.jpg";
    printf "\r[%d/%d %.2f%%]  %s    ", $n, $#ARGV+1, 100*($css/$iss-1), $if;
    unlink $cf;
    if($f) {
        $err = `jpegtran $opts -scans ~/src/perl/jpeg_scan_rgb.txt "$if" 2>&1 >"$cf"`;
        # I don't know a fast way to distinguish color from grayscale input
        # (short of invoking a whole extra copy of jpegtran or identify),
        # so just let the error message tell me.
        # jpegtran will also error out if I use the grayscale scan on a color
        # image, so there's no risk of accidental conversion.
        if($err =~ /Invalid scan script at entry 2/) {
            $err = `jpegtran $opts -scans ~/src/perl/jpeg_scan_bw.txt "$if" 2>&1 >"$cf"`;
        }
        $err and warn "\njpegtran failed:\n$err\n" and next;
    } else {
        system("jpegrescan", "-q", ("-r")x$r, $if, $cf) and next;
    }
    $cs = -s $cf;
    $is = -s $if;
    if($cs and ($cs < $is or $r)) {
        system "touch", "-r", $if, $cf;
        rename $cf, $if;
    } else {
        unlink $cf;
    }
    $css += $cs;
    $iss += $is;
    $n++;
}
printf "\r[%d/%d %.2f%%]\n", $n, $#ARGV+1, 100*($css/$iss-1);
