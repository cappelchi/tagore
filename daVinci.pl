#!/usr/bin/perl -w
use strict;
use Getopt::Long;

# Author: Lavanya Rishishwar
# Date: 6/17/2015

############################################
#########  USAGE INSTRUCTIONS  #############

my $usage = "$0 -i <STRING input bed file> [-o <STRING output prefix. Default: out>]\n";

# Input file should have a structure like: chr start stop feature size col [chrCopy]
# Delimiter doesn't matter.

############################################
########  VARIABLE DECLARATIONS  ###########
my $i;         # Input coordinate bed file
my $out="out"; # Output file
############################################
# Get the arguments
my $args = GetOptions ( "i=s"   => \$i,
                        "o=s"   => \$out);

############################################
if(! defined $i){
	print "ERROR: You didn't specify the input coordinate file (-i option)\n$usage\nExiting\n";
	exit 2;
}

if(! -e $i){
	print "ERROR: The input coordinate file doesn't exist (-i option)\n$usage\nExiting\n";
	exit 3;
}

############################################

my %coor =(	"1" => { "cx" => 1320.9, "cy" =>1.5, "ht" =>1654.5, "wd" =>118.6},
			"2" => { "cx" => 1493.7, "cy" =>43.6, "ht" =>1612.4, "wd" =>118.6},
			"3" => { "cx" => 1669.9, "cy" =>341.4, "ht" =>1314.7, "wd" =>118.6},
			"4" => { "cx" => 1847.9, "cy" =>517.9, "ht" =>1138.1, "wd" =>118.6},
			"5" => { "cx" => 2027.7, "cy" =>461, "ht" =>1195.1, "wd" =>118.6},
			"6" => { "cx" => 2204.7, "cy" =>524.2, "ht" =>1131.8, "wd" =>118.6},
			"7" => { "cx" => 2390.5, "cy" =>608.5, "ht" =>1047.5, "wd" =>118.6},
			"8" => { "cx" => 2565.2, "cy" =>692.8, "ht" =>963.2, "wd" =>118.6},
			"9" => { "cx" => 2746.8, "cy" =>724.4, "ht" =>931.6, "wd" =>118.6},
			"10" => { "cx" => 2926.1, "cy" =>766.6, "ht" =>889.4, "wd" =>118.6},
			"11" => { "cx" => 3103.8, "cy" =>766.6, "ht" =>889.4, "wd" =>118.6},
			"12" => { "cx" => 3287.9, "cy" =>769.7, "ht" =>886.3, "wd" =>118.6},
			"13" => { "cx" => 1321.6, "cy" =>2068.8, "ht" =>766.1, "wd" =>118.6},
			"14" => { "cx" => 1493.9, "cy" =>2121.5, "ht" =>713.4, "wd" =>118.6},
			"15" => { "cx" => 1669.8, "cy" =>2153.1, "ht" =>681.8, "wd" =>118.6},
			"16" => { "cx" => 1849, "cy" =>2232.2, "ht" =>602.8, "wd" =>118.6},
			"17" => { "cx" => 2033.5, "cy" =>2290.7, "ht" =>544.3, "wd" =>118.6},
			"18" => { "cx" => 2208, "cy" =>2313.9, "ht" =>521.1, "wd" =>118.6},
			"19" => { "cx" => 2391.8, "cy" =>2437.2, "ht" =>397.8, "wd" =>118.6},
			"20" => { "cx" => 2566.7, "cy" =>2416.1, "ht" =>418.9, "wd" =>118.6},
			"21" => { "cx" => 2745.3, "cy" =>2510.9, "ht" =>324.1, "wd" =>118.6},
			"22" => { "cx" => 2929.2, "cy" =>2489.8, "ht" =>345.1, "wd" =>118.6},
			"X" => { "cx" => 3103.3, "cy" =>1799.6, "ht" =>1035.4, "wd" =>59},
			);

# hg19 chrom sizes
my %chromSizes = ("1" => 249250621, "2" => 243199373, "3" => 198022430, "4" => 191154276, "5" => 180915260, "6" => 171115067, "7" => 159138663, "8" => 146364022, "9" => 141213431, "10" => 135534747, "11" => 135006516, "12" => 133851895, "13" => 115169878, "14" => 107349540, "15" => 102531392, "16" => 90354753, "17" => 81195210, "18" => 78077248, "19" => 59128983, "20" => 63025520, "21" => 48129895, "22" => 51304566, "X" => 155270560, "Y" => 59373566);


open IN, "<$i" or die "Cannot open input file $i: $!\n";
open OUT, ">$out.svg" or die "Cannot open input file $out.svg: $!\n";
while(<DATA>){
	print OUT $_;
}
while(<IN>){
	next if($_ =~ /^#/);
	chomp $_;
	my ($chr, $start, $stop, $feature, $size, $col, $chrCopy) = split(/\s+/, $_);
	$chr =~ s/chr//i;
	
	# Checks
	if(!defined $size || $size < 0 || $size > 1){
		print STDERR "Feature size \"$size\" unclear.  Please bound the size between 0 (0%) to 1 (100%). Defaulting to 1.\n";
	}
	if(!defined $col || $col =~ /^#/ && length($col) != 7){
		print STDERR "Feature color \"$col\" unclear.  Please define the color in hex starting with #.  Defaulting to #000000.\n";
	}
	if(defined $chrCopy && $chrCopy != 1 && $chrCopy != 2){
		print STDERR "Feature chromosome copy \"$chrCopy\" unclear.  Please define the chromosome copy as either 1 (for the first chr copy) or 2 (for the second chr copy).  Skipping chr copy.\n";
		undef $chrCopy;
	}
	
	
	if($feature == 0){
		my $ftStart = $start*$coor{$chr}{"ht"}/$chromSizes{$chr};
		my $ftEnd   = $stop*$coor{$chr}{"ht"}/$chromSizes{$chr};
		if(! defined $chrCopy){
			my $wd = $coor{$chr}{"wd"}*$size;
			my $x  = $coor{$chr}{"cx"} - $wd/2;
			my $y  = $coor{$chr}{"cy"} + $ftStart;
			my $ht = $ftEnd-$ftStart;
			print OUT "<rect x=\"$x\" y=\"$y\" fill=\"$col\" width=\"$wd\" height=\"$ht\"/>\n";
		} else {
			my $wd = $coor{$chr}{"wd"}*$size/2;
			my $x;
			if($chrCopy == 1){
				$x  = $coor{$chr}{"cx"} - $wd;
			} else {
				$x  = $coor{$chr}{"cx"};
			}
			my $y  = $coor{$chr}{"cy"} + $ftStart;
			my $ht = $ftEnd-$ftStart;
			print OUT "<rect x=\"$x\" y=\"$y\" fill=\"$col\" width=\"$wd\" height=\"$ht\"/>\n";
		}
	} elsif($feature == 1){
		if(! defined $chrCopy){
			my $ftStart = $start*$coor{$chr}{"ht"}/$chromSizes{$chr};
			my $ftEnd   = $stop*$coor{$chr}{"ht"}/$chromSizes{$chr};
			
			my $r  = $coor{$chr}{"wd"}*$size/2;
			my $x  = $coor{$chr}{"cx"};
			my $y  = $coor{$chr}{"cy"}+($ftStart+$ftEnd)/2;
			
			print OUT "<circle fill=\"$col\" cx=\"$x\" cy=\"$y\" r=\"$r\"/>\n";
		} else {
			my $ftStart = $start*$coor{$chr}{"ht"}/$chromSizes{$chr};
			my $ftEnd   = $stop*$coor{$chr}{"ht"}/$chromSizes{$chr};
			
			my $r  = $coor{$chr}{"wd"}*$size/4;
			my $x;
			if($chrCopy == 1){
				$x  = $coor{$chr}{"cx"} - $coor{$chr}{"wd"}/4;
			} else {
				$x  = $coor{$chr}{"cx"} + $coor{$chr}{"wd"}/4;
			}
			my $y  = $coor{$chr}{"cy"}+($ftStart+$ftEnd)/2;
			
			print OUT "<circle fill=\"$col\" cx=\"$x\" cy=\"$y\" r=\"$r\"/>\n";
		}
	} elsif($feature == 2){
		my $ftStart = $start*$coor{$chr}{"ht"}/$chromSizes{$chr};
		my $ftEnd   = $stop*$coor{$chr}{"ht"}/$chromSizes{$chr};
		if (!defined $chrCopy){
			my $x  = $coor{$chr}{"cx"} - $coor{$chr}{"wd"}/2;
			my $y  = $coor{$chr}{"cy"}+($ftStart+$ftEnd)/2;
			my $sx = 38.2*$size;
			my $sy = 21.5*$size;			
			print OUT "<polygon fill=\"$col\" points=\"".($x-$sx).",".($y-$sy)." $x,$y ".($x-$sx).",".($y+$sy)." \"/>\n";
		} else {
			my $x;
			my $sx;
			if($chrCopy == 1){
				$x  = $coor{$chr}{"cx"} - $coor{$chr}{"wd"}/2;
				$sx = 38.2*$size;
			} else {
				$x  = $coor{$chr}{"cx"} + $coor{$chr}{"wd"}/2;
				$sx = -38.2*$size;
			}
			my $y  = $coor{$chr}{"cy"}+($ftStart+$ftEnd)/2;
			my $sy = 21.5*$size;			
			print OUT "<polygon fill=\"$col\" points=\"".($x-$sx).",".($y-$sy)." $x,$y ".($x-$sx).",".($y+$sy)." \"/>\n";
		}
	} elsif($feature == 3){
		if(! defined $chrCopy){
			my $x1 = $coor{$chr}{"cx"} - $coor{$chr}{"wd"}/2;
			my $x2 = $coor{$chr}{"cx"} + $coor{$chr}{"wd"}/2;
			my $y1 = $start*$coor{$chr}{"ht"}/$chromSizes{$chr};
			my $y2 = $stop*$coor{$chr}{"ht"}/$chromSizes{$chr};
			my $y  = ($y1+$y2)/2;
			$y += $coor{$chr}{"cy"};
			my $miter = $size*50;
			print OUT "<line fill=\"none\" stroke=\"$col\" stroke-miterlimit=\"10\" x1=\"$x1\" y1=\"$y\" x2=\"$x2\" y2=\"$y\"/>\n";
		} else {
			my $y1 = $start*$coor{$chr}{"ht"}/$chromSizes{$chr};
			my $y2 = $stop*$coor{$chr}{"ht"}/$chromSizes{$chr};
			my $y  = ($y1+$y2)/2;
			$y += $coor{$chr}{"cy"};
			my $miter = $size*50;
			if($chrCopy == 1){
				my $x1 = $coor{$chr}{"cx"} - $coor{$chr}{"wd"}/2;
				my $x2 = $coor{$chr}{"cx"};
				print OUT "<line fill=\"none\" stroke=\"$col\" stroke-miterlimit=\"10\" x1=\"$x1\" y1=\"$y\" x2=\"$x2\" y2=\"$y\"/>\n";
			} else {
				my $x1 = $coor{$chr}{"cx"};
				my $x2 = $coor{$chr}{"cx"} + $coor{$chr}{"wd"}/2;
				print OUT "<line fill=\"none\" stroke=\"$col\" stroke-miterlimit=\"10\" x1=\"$x1\" y1=\"$y\" x2=\"$x2\" y2=\"$y\"/>\n";
			}
		}
	} else {
		print STDERR "Feature type \"$feature\" unclear.  Please indicate either 0, 1 or 2. Skipping $_\n";
		next;
	}
}
print OUT "</svg>\n";
close IN;
close OUT;

`rsvg $out.svg $out.png`;


__DATA__
<?xml version="1.0" encoding="utf-8"?>
<!-- Generator: Adobe Illustrator 18.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1"
	 id="svg2" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:svg="http://www.w3.org/2000/svg" sodipodi:docname="genomePretty.svg" inkscape:version="0.48.2 r9819"
	 xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="1192 0 2200 3024"
	 enable-background="new 1192 0 2200 3024" xml:space="preserve">
<sodipodi:namedview  pagecolor="#ffffff" inkscape:cx="261.59989" showguides="false" units="in" inkscape:zoom="1.200431" showgrid="false" fit-margin-top="0" fit-margin-left="0" borderopacity="1.0" bordercolor="#666666" id="base" inkscape:cy="246.30581" fit-margin-bottom="0" fit-margin-right="0" inkscape:window-maximized="1" inkscape:window-y="-8" inkscape:window-x="-8" inkscape:current-layer="layer1" inkscape:document-units="in" inkscape:window-width="1366" inkscape:pageopacity="0.0" inkscape:window-height="746" inkscape:guide-bbox="true" inkscape:pageshadow="2">
	<sodipodi:guide  position="-373.91519,355.08062" orientation="1,0" id="guide3000"></sodipodi:guide>
	<sodipodi:guide  position="-358.91519,247.08062" orientation="0,1" id="guide3022"></sodipodi:guide>
	<sodipodi:guide  position="-353.20091,242.58062" orientation="0,1" id="guide3024"></sodipodi:guide>
	<sodipodi:guide  position="-350.34376,220.08062" orientation="0,1" id="guide3026"></sodipodi:guide>
	<sodipodi:guide  position="-329.62948,215.58062" orientation="0,1" id="guide3028"></sodipodi:guide>
	<sodipodi:guide  position="-393.20091,193.08062" orientation="0,1" id="guide3034"></sodipodi:guide>
	<sodipodi:guide  position="-395.34376,188.58062" orientation="0,1" id="guide3085"></sodipodi:guide>
	<sodipodi:guide  position="64.258329,165.46299" orientation="0,1" id="guide3087"></sodipodi:guide>
	<sodipodi:guide  position="-241.41519,161.58062" orientation="0,1" id="guide3115"></sodipodi:guide>
	<sodipodi:guide  position="-337.48662,134.58062" orientation="0,1" id="guide3119"></sodipodi:guide>
	<sodipodi:guide  position="404.46508,112.96031" orientation="0,1" id="guide3121"></sodipodi:guide>
	<sodipodi:guide  position="-366.91519,171.83062" orientation="0,1" id="guide3129"></sodipodi:guide>
	<sodipodi:guide  position="-355.17686,31.080619" orientation="0,1" id="guide3143"></sodipodi:guide>
	<sodipodi:guide  position="-18.947596,22.718619" orientation="0,1" id="guide3145"></sodipodi:guide>
	<sodipodi:guide  position="-173.45042,4.0806193" orientation="0,1" id="guide3195"></sodipodi:guide>
	<sodipodi:guide  position="-284.46619,-0.41938071" orientation="0,1" id="guide3197"></sodipodi:guide>
	<sodipodi:guide  position="-298.25477,-22.919381" orientation="0,1" id="guide3199"></sodipodi:guide>
	<sodipodi:guide  position="-325.12483,-27.419381" orientation="0,1" id="guide3201"></sodipodi:guide>
	<sodipodi:guide  position="-340.32762,-49.919381" orientation="0,1" id="guide3203"></sodipodi:guide>
	<sodipodi:guide  position="-317.34665,-54.419381" orientation="0,1" id="guide3205"></sodipodi:guide>
	<sodipodi:guide  position="-316.63954,-76.919381" orientation="0,1" id="guide3207"></sodipodi:guide>
	<sodipodi:guide  position="-303.91162,-81.419385" orientation="0,1" id="guide3209"></sodipodi:guide>
	<sodipodi:guide  position="-294.66519,-103.91938" orientation="0,1" id="guide3247"></sodipodi:guide>
	<sodipodi:guide  position="-346.66519,-108.41938" orientation="0,1" id="guide3249"></sodipodi:guide>
	<sodipodi:guide  position="-246.91519,-130.91938" orientation="0,1" id="guide3253"></sodipodi:guide>
	<sodipodi:guide  position="-277.41519,-135.41938" orientation="0,1" id="guide3255"></sodipodi:guide>
	<sodipodi:guide  position="-321.66519,-157.91938" orientation="0,1" id="guide3257"></sodipodi:guide>
	<sodipodi:guide  position="-330.66519,-162.41938" orientation="0,1" id="guide3259"></sodipodi:guide>
	<sodipodi:guide  position="-333.91519,-184.91938" orientation="0,1" id="guide3261"></sodipodi:guide>
	<sodipodi:guide  position="-350.16519,-189.41938" orientation="0,1" id="guide3263"></sodipodi:guide>
	<sodipodi:guide  position="-406.44211,-211.91938" orientation="0,1" id="guide3340"></sodipodi:guide>
	<sodipodi:guide  position="-413.51317,-216.41938" orientation="0,1" id="guide3342"></sodipodi:guide>
	<sodipodi:guide  position="-410.33119,-238.91938" orientation="0,1" id="guide3346"></sodipodi:guide>
	<sodipodi:guide  position="-401.41519,377.58062" orientation="1,0" id="guide3354"></sodipodi:guide>
	<sodipodi:guide  position="-299.16519,252.33062" orientation="0,1" id="guide3376"></sodipodi:guide>
	<sodipodi:guide  position="-283.91519,225.58062" orientation="0,1" id="guide3382"></sodipodi:guide>
	<sodipodi:guide  position="-362.91519,198.58062" orientation="0,1" id="guide3390"></sodipodi:guide>
	<sodipodi:guide  position="-384.91519,9.8306193" orientation="0,1" id="guide3430"></sodipodi:guide>
	<sodipodi:guide  position="-289.16519,-17.419381" orientation="0,1" id="guide3436"></sodipodi:guide>
	<sodipodi:guide  position="-373.91519,-43.919381" orientation="0,1" id="guide3446"></sodipodi:guide>
	<sodipodi:guide  position="-286.16519,-71.419381" orientation="0,1" id="guide3448"></sodipodi:guide>
	<sodipodi:guide  position="-387.66519,-98.169385" orientation="0,1" id="guide3454"></sodipodi:guide>
	<sodipodi:guide  position="-275.16519,-125.41938" orientation="0,1" id="guide3460"></sodipodi:guide>
	<sodipodi:guide  position="-360.41519,-152.16938" orientation="0,1" id="guide3466"></sodipodi:guide>
	<sodipodi:guide  position="-414.16519,-179.66938" orientation="0,1" id="guide3472"></sodipodi:guide>
	<sodipodi:guide  position="-292.91519,-206.66938" orientation="0,1" id="guide3478"></sodipodi:guide>
	<sodipodi:guide  position="-362.91519,-233.16938" orientation="0,1" id="guide3488"></sodipodi:guide>
	<sodipodi:guide  position="69.834804,258.83062" orientation="0,1" id="guide4064"></sodipodi:guide>
	<sodipodi:guide  position="14.849242,307.945" orientation="1,0" id="guide4081"></sodipodi:guide>
	<sodipodi:guide  position="47.641319,384.75448" orientation="1,0" id="guide4083"></sodipodi:guide>
	<sodipodi:guide  position="81.084804,242.58062" orientation="1,0" id="guide4085"></sodipodi:guide>
	<sodipodi:guide  position="114.90485,254.20489" orientation="1,0" id="guide4087"></sodipodi:guide>
	<sodipodi:guide  position="149.02275,252.33062" orientation="1,0" id="guide4089"></sodipodi:guide>
	<sodipodi:guide  position="182.625,252.33062" orientation="1,0" id="guide4091"></sodipodi:guide>
	<sodipodi:guide  position="217.875,252.33062" orientation="1,0" id="guide4093"></sodipodi:guide>
	<sodipodi:guide  position="251.03125,257.25" orientation="1,0" id="guide4095"></sodipodi:guide>
	<sodipodi:guide  position="285.5,347.75" orientation="1,0" id="guide4097"></sodipodi:guide>
	<sodipodi:guide  position="319.625,345.375" orientation="1,0" id="guide4099"></sodipodi:guide>
	<sodipodi:guide  position="353.25,134.58062" orientation="1,0" id="guide4101"></sodipodi:guide>
	<sodipodi:guide  position="388.20162,278.95363" orientation="1,0" id="guide4103"></sodipodi:guide>
	<sodipodi:guide  position="3.8890872,161.58062" orientation="1,0" id="guide12488"></sodipodi:guide>
	<sodipodi:guide  position="26.516504,181.37288" orientation="0,1" id="guide12492"></sodipodi:guide>
	<sodipodi:guide  position="26.516504,35.812499" orientation="0,1" id="guide12494"></sodipodi:guide>
	<sodipodi:guide  position="9.457553,183.14065" orientation="0,1" id="guide13008"></sodipodi:guide>
	<sodipodi:guide  position="26.140625,37.859375" orientation="1,0" id="guide13439"></sodipodi:guide>
	<sodipodi:guide  position="107.21507,150.1718" orientation="0,1" id="guide15391"></sodipodi:guide>
	<sodipodi:guide  position="371.76139,232.19619" orientation="0,1" id="guide17232"></sodipodi:guide>
	<sodipodi:guide  position="441.94174,303.17203" orientation="0,1" id="guide21930"></sodipodi:guide>
	<sodipodi:guide  position="340.64869,247.08062" orientation="1,0" id="guide22976"></sodipodi:guide>
</sodipodi:namedview>
<text transform="matrix(1 0 0 1 1264.1563 1739.7329)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr1</text>
<text transform="matrix(1 0 0 1 1441.693 1734.55)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr2</text>
<text transform="matrix(1 0 0 1 1613.5026 1734.2891)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr3</text>
<text transform="matrix(1 0 0 1 1785.9053 1734.3207)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr4</text>
<text transform="matrix(1 0 0 1 2147.3137 1735.1141)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr6</text>
<text transform="matrix(1 0 0 1 1965.4866 1734.0438)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr5</text>
<text transform="matrix(1 0 0 1 2326.6689 1734.2257)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr7</text>
<text transform="matrix(1 0 0 1 2504.9221 1735.1141)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr8</text>
<text transform="matrix(1 0 0 1 2687.2769 1735.1141)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr9</text>
<text transform="matrix(1 0 0 1 2852.8042 1735.1141)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr10</text>
<text transform="matrix(1 0 0 1 3028.2463 1735.1141)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr11</text>
<text transform="matrix(1 0 0 1 3210.6294 1735.1141)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr12</text>
<text transform="matrix(1 0 0 1 1239.786 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr13</text>
<text transform="matrix(1 0 0 1 1415.0485 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr14</text>
<text transform="matrix(1 0 0 1 1591.2256 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr15</text>
<text transform="matrix(1 0 0 1 1772.1217 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr16</text>
<text transform="matrix(1 0 0 1 1953.5588 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr17</text>
<text transform="matrix(1 0 0 1 2127.3179 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr18</text>
<text transform="matrix(1 0 0 1 2310.6108 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr19</text>
<text transform="matrix(1 0 0 1 2486.3867 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr20</text>
<text transform="matrix(1 0 0 1 2668.3025 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr21</text>
<text transform="matrix(1 0 0 1 2848.5874 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chr22</text>
<text transform="matrix(1 0 0 1 3037.1143 2904.1479)" font-family="'HelveticaNeueLTStd-Roman'" font-size="57.9613">chrX</text>
<g id="g13248" transform="matrix(1,0,0,-1,0,482.82734)">
	
		<path id="path13242" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1262.8-1604.5c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4v-85.9v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1262.8-1604.5z"/>
	
		<path id="path13310" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1380.3-1604.5c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l0.5-85.9v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L1380.3-1604.5z"/>
	
		<path id="path13314" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1379.8-2333.7c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v612.8v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L1379.8-2333.7z"/>
	
		<path id="path13318" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1262.8-2333.7c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4v612.8v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1262.8-2333.7z"/>
</g>
<g id="g13701" transform="matrix(1,0,0,-1,66.19018,498.82734)">
	
		<path id="path13703" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1545.4-1672.8c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-0.5-77.5v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1545.4-1672.8z"/>
	
		<path id="path13705" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1662.9-1672.8c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-77.5v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L1662.9-1672.8z"/>
	
		<path id="path13707" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1662.4-2317.7c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v536.9v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L1662.4-2317.7z"/>
	
		<path id="path13709" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1545.4-2317.7c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,536.9v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1545.4-2317.7z"/>
</g>
<g id="g13795" transform="matrix(1,0,0,-1,32.80018,492.82734)">
	
		<path id="path13797" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1402.8-1647.1c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-0.5-73.2v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1402.8-1647.1z"/>
	
		<path id="path13799" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1520.3-1647.1c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-73.2v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L1520.3-1647.1z"/>
	
		<path id="path13801" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1519.8-2323.7c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v572.8v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L1519.8-2323.7z"/>
	
		<path id="path13803" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1402.8-2323.7c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,572.8v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1402.8-2323.7z"/>
</g>
<g id="g15121" transform="matrix(1,0,0,-1,100.19018,513.82314)">
	
		<path id="path15123" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1690.5-1736.8c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-0.5-219.7v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1690.5-1736.8z"/>
	
		<path id="path15125" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1808-1736.8c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-219.7v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L1808-1736.8z"/>
	
		<path id="path15127" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1807.5-2302.7c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4v316.2v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4L1807.5-2302.7z"/>
	
		<path id="path15129" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1690.5-2302.7c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-1.1,316.2v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1690.5-2302.7z"/>
</g>
<g id="g15153" transform="matrix(1,0,0,-1,135.20629,525.16314)">
	
		<path id="path15155" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1840-1785.2c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-1.1-123.8v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4L1840-1785.2z"
		/>
	
		<path id="path15157" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1957.5-1785.2c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4V-1909v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-1785.2z"/>
	
		<path id="path15159" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1957-2292.6c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4v353v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4L1957-2292.6z"/>
	
		<path id="path15161" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1840-2292.6c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,353v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4L1840-2292.6z"/>
</g>
<g id="g15163" transform="matrix(1,0,0,-1,168.32629,529.48314)">
	
		<path id="path15165" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1981.4-1803.6c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-79v-15.3l-22.1,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1981.4-1803.6z"/>
	
		<path id="path15167" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2098.9-1803.6c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-79v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L2098.9-1803.6z"/>
	
		<path id="path15169" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2098.4-2287.9c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v375.2v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2098.4-2287.9z"/>
	
		<path id="path15171" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1981.4-2287.9c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,375.2v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1981.4-2287.9z"/>
</g>
<g id="g15909" transform="matrix(0,-0.29019973,-1.25,0,234.22665,321.12444)" inkscape:label="chr19">
	<g id="g15911" transform="scale(0.1,0.1)">
	</g>
</g>
<g id="g16094" transform="matrix(1,0,0,-1,203.20127,552.97313)">
	
		<path id="path16096" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2130.3-1903.9c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-142.3v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L2130.3-1903.9z"/>
	
		<path id="path16098" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2247.8-1903.9c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-142.3v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L2247.8-1903.9z"/>
	
		<path id="path16100" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2247.3-2264.9c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4l-0.5,188.6v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4V-2264.9z"/>
	
		<path id="path16102" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2130.3-2264.9c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-1.1,188.6v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L2130.3-2264.9z"/>
</g>
<g id="g16104" transform="matrix(1,0,0,-1,236.39218,548.97313)">
	
		<path id="path16106" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2272-1886.8c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-1.1-148.6v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4L2272-1886.8z"
		/>
	
		<path id="path16108" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2389.5-1886.8c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-148.6v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L2389.5-1886.8z"/>
	
		<path id="path16110" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2389-2268.9c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4v202.9v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4L2389-2268.9z"/>
	
		<path id="path16112" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2272-2268.9c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-1.1,202.9v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4L2272-2268.9z"
		/>
</g>
<g id="g16204" transform="matrix(1.25,0,0,-1.25,282.87896,312.69013)" inkscape:label="chr20">
	<g id="g16206" transform="scale(0.1,0.1)">
	</g>
</g>
<g id="g16409" transform="matrix(1,0,0,-1,270.29502,566.97313)">
	<g id="g16871">
		
			<path id="path16411" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2416.8-1963.7c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-46.9v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
			L2416.8-1963.7z"/>
		
			<path id="path16413" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2534.3-1963.7c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-46.9v-15.3l22.7,1.1
			c13.7,0,36.4,7.9,36.4,17.4V-1963.7z"/>
		
			<path id="path16415" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2533.7-2250.9c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v209.7v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
			L2533.7-2250.9z"/>
		
			<path id="path16417" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2416.8-2250.9c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,209.7v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
			L2416.8-2250.9z"/>
	</g>
	<g id="g16877">
		
			<path id="path16879" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2416.8-1963.7c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-46.9v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
			L2416.8-1963.7z"/>
		
			<path id="path16881" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2534.3-1963.7c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-46.9v-15.3l22.7,1.1
			c13.7,0,36.4,7.9,36.4,17.4V-1963.7z"/>
		
			<path id="path16883" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2533.7-2250.9c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v209.7v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
			L2533.7-2250.9z"/>
		
			<path id="path16885" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2416.8-2250.9c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,209.7v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
			L2416.8-2250.9z"/>
	</g>
</g>
<g id="g16664" transform="matrix(1.25,0,0,-1.25,293.35186,285.99343)" inkscape:label="chr21">
	<g id="g16666" transform="scale(0.1,0.1)">
	</g>
</g>
<g id="g16861" transform="matrix(1,0,0,-1,305.19082,562.97313)">
	
		<path id="path16863" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2565.7-1946.6c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-0.5-56.4v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L2565.7-1946.6z"/>
	
		<path id="path16865" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2683.2-1946.6c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-56.4v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-1946.6z"/>
	
		<path id="path16867" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2682.7-2254.9c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v221.3v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2682.7-2254.9z"/>
	
		<path id="path16869" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2565.7-2254.9c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,221.3v15.3l-22.7-0.5c-13.7,0-36.4-7.9-36.4-17.4
		L2565.7-2254.9z"/>
</g>
<g id="g16977" transform="matrix(1.25,0,0,-1.25,337.89958,315.51514)" inkscape:label="chr22">
	<g id="g16979" transform="scale(0.1,0.1)">
	</g>
</g>
<g id="g17200" transform="matrix(1,0,0,-1,343.78671,431.92314)">
	
		<path id="path17202" sodipodi:nodetypes="csccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2730.5-1387.1c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-0.5-369.9c0-7.9-13.2-19-29-19c-13.7,0-29.5,9-29.5,18.4
		L2730.5-1387.1z"/>
	
		<path id="path17208" sodipodi:nodetypes="csccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2730.5-2385.6c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,592.3c0,6.3-13.7,17.4-29,17.4
		c-13.7,0-29.5-9-29.5-18.4L2730.5-2385.6z"/>
</g>
<g id="g17756" transform="matrix(1.25,0,0,-1.25,293.06109,251.19013)" inkscape:label="chrX">
	<g id="g17758" transform="scale(0.1,0.1)">
	</g>
</g>
<g id="g19367" transform="matrix(1,0,0,-1,-0.07261999,90.283139)">
	
		<path id="path19369" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1262.5,71.4c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-0.5-794.6v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1262.5,71.4z"/>
	
		<path id="path19371" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1380,71.4c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-794.6v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V71.4z"/>
	
		<path id="path19373" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1379.5-1546.2c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4v792.5v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4L1379.5-1546.2z"/>
	
		<path id="path19375" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1262.5-1546.2c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,792.5v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1262.5-1546.2z"/>
</g>
<g id="g19387" transform="matrix(1,0,0,-1,32.719419,98.283139)">
	
		<path id="path19389" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1402.5,37.2c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-0.5-582.8v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4L1402.5,37.2z"
		/>
	
		<path id="path19391" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1520,37.2c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-582.8v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V37.2z"/>
	
		<path id="path19393" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1519.5-1538.2c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4v962.7v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4L1519.5-1538.2z"/>
	
		<path id="path19395" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1402.5-1538.2c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,962.7v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1402.5-1538.2z"/>
</g>
<g id="g19690" transform="matrix(1,0,0,-1,66.162904,154.72314)">
	
		<path id="path19692" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1545.3-203.7c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-0.5-562.8v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L1545.3-203.7z"/>
	
		<path id="path19694" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1662.8-203.7c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-562.8v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L1662.8-203.7z"/>
	
		<path id="path19696" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1662.2-1481.5c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v685v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L1662.2-1481.5z"/>
	
		<path id="path19698" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1545.3-1481.5c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,685v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1545.3-1481.5z"/>
</g>
<g id="g19722" transform="matrix(1,0,0,-1,99.98292,188.03314)">
	
		<path id="path19724" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1689.7-345.9c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-1.1-258.7v-15.3l-22.1,1.6c-13.7,0-36.4,7.9-36.4,17.4L1689.7-345.9
		z"/>
	
		<path id="path19726" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1807.2-345.9c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-258.7v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-345.9z"/>
	
		<path id="path19728" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1806.6-1447.2c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v812.5v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L1806.6-1447.2z"/>
	
		<path id="path19730" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1689.7-1447.2c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,812.5v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1689.7-1447.2z"/>
</g>
<g id="g19740" transform="matrix(1.25,0,0,-1.25,-0.23686154,-15.941161)" inkscape:label="chr3">
	<g id="g19742" transform="scale(0.1,0.1)">
	</g>
</g>
<g id="g20330" transform="matrix(1,0,0,-1,134.10085,177.22314)">
	<g id="g3728">
		
			<path id="path20332" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M1835.3-299.8c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-1.1-277.2v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
			L1835.3-299.8z"/>
		
			<path id="path20334" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M1952.8-299.8c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-277.2v-15.3l22.7,1.1
			c13.7,0,36.4,7.9,36.4,17.4V-299.8z"/>
		
			<path id="path20336" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M1952.3-1457.9c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v851v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
			L1952.3-1457.9z"/>
		
			<path id="path20338" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M1835.3-1457.9c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,851v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4L1835.3-1457.9
			z"/>
	</g>
</g>
<g id="g20598" transform="matrix(1,0,0,-1,167.7031,189.1412)">
	
		<path id="path20600" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1978.8-350.6c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-1.1-363.6v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4L1978.8-350.6
		z"/>
	
		<path id="path20602" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2096.3-350.6c-1.6,4.2-3.7,7.4-5.8,9.5c-6.9,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-363.6v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L2096.3-350.6z"/>
	
		<path id="path20604" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2095.7-1445.6c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v701.3v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2095.7-1445.6z"/>
	
		<path id="path20606" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M1978.8-1445.6c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,701.3v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L1978.8-1445.6z"/>
</g>
<g id="g20933" transform="matrix(1,0,0,-1,236.10935,221.1412)">
	
		<path id="path20935" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2270.8-487.3c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-0.5-267.1v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4L2270.8-487.3
		z"/>
	
		<path id="path20937" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2388.3-487.3c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-267.1v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-487.3z"/>
	
		<path id="path20939" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2387.8-1413.6c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4V-785v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2387.8-1413.6z"/>
	
		<path id="path20941" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2270.8-1413.6c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,628.6v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L2270.8-1413.6z"/>
</g>
<g id="g21432" transform="matrix(1,0,0,-1,275.9531,227.1412)">
	<g id="g21922" transform="translate(-5.375,-1.0546876e-6)">
		
			<path id="path21434" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2418-512.9c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-316.7v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
			L2418-512.9z"/>
		
			<path id="path21436" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2535.5-512.9c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-316.7v-15.3l22.7,1.1
			c13.7,0,36.4,7.9,36.4,17.4V-512.9z"/>
		
			<path id="path21438" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2534.9-1407.6c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v547.5v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
			L2534.9-1407.6z"/>
		
			<path id="path21440" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
			M2418-1407.6c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,547.5v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
			L2418-1407.6z"/>
	</g>
</g>
<g id="g21934" transform="matrix(1,0,0,-1,304.7031,235.1412)">
	
		<path id="path21936" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2563.6-547c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-229.2v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L2563.6-547z"/>
	
		<path id="path21938" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2681.1-547c-1.6,4.2-3.7,7.4-5.8,9.5c-6.9,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-229.2v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-547z"/>
	
		<path id="path21940" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2680.6-1399.6c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v593.3v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2680.6-1399.6z"/>
	
		<path id="path21942" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2563.6-1399.6c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,593.3v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L2563.6-1399.6z"/>
</g>
<g id="g22276" transform="matrix(1,0,0,-1,338.3281,235.1412)">
	
		<path id="path22278" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2707.2-547c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-319.3v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L2707.2-547z"/>
	
		<path id="path22280" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2824.7-547c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-319.3v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-547z"/>
	
		<path id="path22282" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2824.2-1399.6c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v502.7v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2824.2-1399.6z"/>
	
		<path id="path22284" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2707.2-1399.6c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,502.7v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L2707.2-1399.6z"/>
</g>
<g id="g22328" transform="matrix(1,0,0,-1,373.27969,235.72314)">
	
		<path id="path22330" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2856.4-549.5c7.4,17.4,17.9,18.4,29,18.4s22.1-1.1,29.5-18.4l-1.1-192.9v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4L2856.4-549.5
		z"/>
	
		<path id="path22332" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2973.9-549.5c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-192.9v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-549.5z"/>
	
		<path id="path22334" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2973.4-1398.9c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4v626v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4L2973.4-1398.9z"/>
	
		<path id="path22336" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2856.4-1398.9c7.4-17.4,17.9-18.4,29-18.4s22.1,1.1,29.5,18.4l-0.5,626v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4L2856.4-1398.9z
		"/>
</g>
<g id="g3794" transform="matrix(1,0,0,-1,202.9531,205.1412)">
	
		<path id="path3796" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2129.3-419c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-356.2v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L2129.3-419z"/>
	
		<path id="path3798" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2246.8-419c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4v-356.2v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4V-419z"/>
	
		<path id="path3800" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2246.2-1429.6c-7.4-17.4-17.9-18.4-29-18.4c-11.1,0-22.1,1.1-29.5,18.4v623.9v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4
		L2246.2-1429.6z"/>
	
		<path id="path3802" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2129.3-1429.6c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-0.5,624.4v15.3l-22.7-1.6c-13.7,0-36.4-7.9-36.4-17.4
		L2129.3-1429.6z"/>
</g>
<g id="g3967" transform="matrix(1,0,0,-1,203.20127,552.97313)">
	
		<path id="path3969" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2130.3-1903.9c7.4,17.4,17.9,18.4,29,18.4c11.1,0,22.1-1.1,29.5-18.4l-1.1-142.3v-15.3l-22.7,1.1c-13.7,0-36.4,7.9-36.4,17.4
		L2130.3-1903.9z"/>
	
		<path id="path3971" sodipodi:nodetypes="csscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2247.8-1903.9c-1.6,4.2-3.7,7.4-5.8,9.5c-6.8,7.9-15.3,9-23.7,9c-11.1,0-22.1-1.1-29.5-18.4l-0.5-142.3v-15.3l22.7,1.1
		c13.7,0,36.4,7.9,36.4,17.4L2247.8-1903.9z"/>
	
		<path id="path3973" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2247.3-2264.9c-7.4-17.4-17.9-18.4-29-18.4s-22.1,1.1-29.5,18.4l-0.5,188.6v15.3l22.7-1.1c13.7,0,36.4-7.9,36.4-17.4V-2264.9z"/>
	
		<path id="path3975" sodipodi:nodetypes="cscccccc" inkscape:connector-curvature="0" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="square" stroke-linejoin="round" d="
		M2130.3-2264.9c7.4-17.4,17.9-18.4,29-18.4c11.1,0,22.1,1.1,29.5,18.4l-1.1,188.6v15.3l-22.7-1.1c-13.7,0-36.4-7.9-36.4-17.4
		L2130.3-2264.9z"/>
</g>