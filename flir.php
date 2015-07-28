#!/usr/bin/php
<?php
//------------- set necessary paramters -------------------------------------

if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    //WINDOWS user: set path to tools
    $convert='"C:\util\ImageMagick\convert.exe"';
    $exiftool='"C:\util\exiftool\exiftool.exe"';
    //set font variable as needed (Mac/Win) for color scale
    $font='-font c:\windows\Fonts\arialbd.ttf';
    $escape='';

} else {
    //Unix/Mac: set path to tools here 
    $convert='/usr/bin/convert';
    $exiftool='/usr/bin/exiftool';
    //set font variable as needed (Mac/Win) for color scale
    $font='-font /Library/Fonts/Arial\ Bold.ttf';
    $escape='\\';
}

//color scale
$font_color='white';
$frame_color='black';

//extract embedded palette to
$embpal='palette.png';

//--------------------------------------------------------------------------

$shortopts  = "";
$shortopts .= "i:";  // Required value
$shortopts .= "o:";  
$shortopts .= "h";  

$longopts  = array(
    "resize:",     // Required value
    "rmin:",     
    "rmax:",    
    "pal:",
    "tref:",
    "emis:",
    "pip::",       // opt. value
    "clut",        // No value
    "scale",      
    "msx",
    "shade",
    "help",       
);
$options = getopt($shortopts, $longopts);
#var_dump($options);

function help()
{
global $argv;
echo <<<EOT

usage: $argv[0] [options] -i ir_file.jpg -o outputimage

Settings:
-i ir_file.jpg      flir radiometric image
-o output.jpg       save  8 Bit image jpg
-o output.png       save 16 Bit image png

Options Summary:
--resize val        scale sensor size with "convert -resize val" (val i.e. 600x or 100%, default is 200%)
--tref temp         overwrite embedded Reflected Apparent Temperature (degree Celsius) 
--emis val          overwrite embedded Emissivity (val i.e. 0.95)
--rmin raw_min      set min RAW value instead embedded value (set scale min temp)
--rmax raw_ma       set max RAW value instead embedded value (set scale max temp)
--pal iron.png      use own palette (instead of embedded palette.png)
--clut              disable "Color LookUp Table" and color scale (save a grayscale image)
--scale             disable color scale on the right edge
--pip[=AxB]         input image is a flir PiP radiometric image
                    overlay embedded "real image" with "ir image"
                    [optional] crop ir image to size AxB (i.e. --pip=90x90 )
--msx               Flir MSX Mode for PiP 
--shade             Flir MSX Mode for PiP with amboss effect 
--help              print this help
  
# source: 
# [1] http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,4898.0.html

EOT;
}

if (isset($options['help']) || isset($options['h']))
{
 help();
};

if (isset($options['i']))
{
    $flirimg="\"".$options['i']."\"";
    if (isset($options['o']))
    {
        $destimg="\"".$options['o']."\"";    
    } else {
      print 'Error: No output file specified! "-o filename"'."\n";
      exit(1);
    }
} else {     
    help();
    exit(1);
};

if (isset($options['pal']))
{
    $pal="\"".$options['pal']."\"";  
} else {
    $pal=$embpal;
}

if (isset($options['resize']))
{
    $resize='-resize '.$options['resize'];    
} else {
    // default
    $resize="-resize 200%";
}

//get Exif values (syntax for Unix and Windows)
eval('$exif='.shell_exec($exiftool.' -php -flir:all -q '.$flirimg));
//var_dump($exif);

if (isset($options['tref']))
{
    $Temp_ref=$options['tref'];  
} else {
    $tmp=explode(" ",$exif[0]['ReflectedApparentTemperature']);
    $Temp_ref = $tmp[0];
}
if (isset($options['emis']))
{
    $Emissivity=$options['emis'];  
} else {
    $Emissivity=$exif[0]['Emissivity'];
}
print("\nReflected Apparent Temperature: ".$Temp_ref." degree Celsius\nEmissivity: ".$Emissivity."\n");

// save Flir values for Plancks Law for better reading in short variables
$R1=$exif[0]['PlanckR1'];
$R2=$exif[0]['PlanckR2'];
$B= $exif[0]['PlanckB'];
$O= $exif[0]['PlanckO'];
$F= $exif[0]['PlanckF'];

print('Plancks values: '.$R1.' '.$R2.' '.$B.' '.$O.' '.$F."\n\n");

// get displayed temp range in RAW values
$RAWmax=$exif[0]['RawValueMedian']+$exif[0]['RawValueRange']/2;
$RAWmin=$RAWmax-$exif[0]['RawValueRange'];

printf("RAW Temp Range FLIR setting: %d %d\n",$RAWmin,$RAWmax);

//overwrite with settings
if (isset($options['rmin'])) $RAWmin=$options['rmin'];
if (isset($options['rmax'])) $RAWmax=$options['rmax'];

printf("RAW Temp Range select      : %d %d\n",$RAWmin,$RAWmax);

// calc amount of radiance of reflected objects ( Emissivity < 1 )
$RAWrefl=$R1/($R2*(exp($B/($Temp_ref+273.15))-$F))-$O;
printf("RAW reflected: %d\n",$RAWrefl); 

// get displayed object temp max/min and convert to "%.1f" for printing
$RAWmaxobj=($RAWmax-(1-$Emissivity)*$RAWrefl)/$Emissivity;
$RAWminobj=($RAWmin-(1-$Emissivity)*$RAWrefl)/$Emissivity;
$Temp_min=sprintf("%.1f", $B/log($R1/($R2*($RAWminobj+$O))+$F)-273.15);
$Temp_max=sprintf("%.1f", $B/log($R1/($R2*($RAWmaxobj+$O))+$F)-273.15);

// extract color table, swap Cb Cr and expand video pal color table from [16,235] to [0,255]
// best results: Windows -colorspace sRGB | MAC -colorspace RGB
exec($exiftool.' '.$flirimg.' -b -Palette | '.$convert.' -size "'.$exif[0]['PaletteColors'].'X1" -depth 8 YCbCr:- -separate -swap 1,2 -set colorspace YCbCr -combine -colorspace RGB -auto-level '.$embpal);

// draw color scale
exec($convert." -size 30x256 gradient: $pal -clut -mattecolor ".$frame_color.' -frame 5x5 -set colorspace rgb gradient.png');

// if your imagemagick have no freetype library remove the next line
exec($convert." gradient.png -background ".$frame_color." ".$font." -fill ".$font_color." -pointsize 15 label:\"$Temp_max C\" +swap -gravity Center -append  label:\"$Temp_min\" -append gradient.png");

if ($exif[0]['RawThermalImageType'] != "TIFF")
{
  //16 bit PNG: change byte order
   $size=$exif[0]['RawThermalImageWidth']."x".$exif[0]['RawThermalImageHeight'];
   exec($exiftool." -b -RawThermalImage $flirimg | ".$convert." - gray:- | ".$convert." -depth 16 -endian msb -size ".$size." gray:- raw.png");   
}else{
   exec($exiftool." -b -RawThermalImage $flirimg | ".$convert." - raw.png");      
}
print('RAW Temp Range from sensor : '.exec($convert.' raw.png -format "%[min] %[max]" info:')."\n");

// convert every RAW-16-Bit Pixel with Planck's Law to a Temperature Grayscale value and append temp scale
$Smax=$B/log($R1/($R2*($RAWmax+$O))+$F);
$Smin=$B/log($R1/($R2*($RAWmin+$O))+$F);
$Sdelta=$Smax-$Smin;
exec($convert." raw.png -fx \"($B/ln($R1/($R2*(65535*u+$O))+$F)-$Smin)/$Sdelta\" ir.png");

if ( !isset($options['pip']) )
{    
    if ( !isset($options['clut']) )
    {
        if ( !isset($options['scale']) )
            {
            // with color scale
            exec($convert." ir.png ".$resize." $pal -clut -background ".$frame_color." -flatten +matte gradient.png -gravity East +append $destimg");
        }else{
            exec($convert." ir.png ".$resize." $pal -clut ".$destimg);
        }
    }else{
        // only gray picture
            exec($convert." ir.png ".$resize." ".$destimg);
    }    
}else{
//make PiP
    //read embedded image
    exec($exiftool." -b -EmbeddedImage $flirimg | ".$convert." - -set colorspace YCbCr -colorspace RGB embedded.png");
    $geometrie=$exif[0]['OffsetX'].$exif[0]['OffsetY'];
    if ( is_string($options['pip']) )
    {
        $crop="-gravity Center -crop ".$options['pip']."+0+0";
    }  
    $resizepercent=100*$exif[0]['EmbeddedImageWidth']/$exif[0]['Real2IR']/$exif[0]['RawThermalImageWidth'];
    $resize="-resize ".$resizepercent.'%';
    if ( !isset($options['msx']) && !isset($options['shade']) )
    {
       exec($convert." ir.png $crop +repage ".$resize." $pal -clut embedded.png +swap -gravity Center -geometry $geometrie -compose over -composite -background ".$frame_color." -flatten +matte gradient.png -gravity East +append ".$destimg);
    }else{
       $cropx=$resizepercent*$exif[0]['RawThermalImageWidth']/100;
       $cropy=$resizepercent*$exif[0]['RawThermalImageHeight']/100;
       // $escape: bash/win have different brackets
       if ( isset($options['msx']) )
       {
          // high pass to real image and crop to IR size
          exec($convert." embedded.png -gravity center -crop {$cropx}x{$cropy}{$geometrie} $escape( -clone 0 -blur 0x3 $escape) -compose mathematics -define compose:args=0,-1,+1,0.5 -composite -colorspace gray -sharpen 0x3 -level 30%,70%! embedded1.png");
       }else{
          // shade filter to real image and crop to IR size
          exec($convert." embedded.png -gravity center -crop {$cropx}x{$cropy}{$geometrie} -auto-level -shade 45x30 -auto-level embedded1.png");
          $gamma=exec($convert." embedded1.png -format \"%[fx:mean]\" info:");
          $gamma=log($gamma)/log(0.5);
          exec($convert." embedded1.png -gamma $gamma embedded1.png");
       }
       // overlay real with IR
       exec($convert." ir.png ".$resize." $pal -clut embedded1.png +swap -compose overlay -composite ir2.png");
       echo "\n";
       #echo($convert." ir.png $crop +repage ".$resize." $pal -clut embedded1.png +swap -gravity Center -geometry $geometrie -compose overlay -composite ".$destimg);
       exec($convert." embedded.png ir2.png -gravity Center -geometry $geometrie -compose over -composite -background ".$frame_color." -flatten +matte gradient.png -gravity East +append ".$destimg); 
    }
}

print("wrote $destimg with Temp-Range: $Temp_min / $Temp_max degree Celsius\n");

?>

