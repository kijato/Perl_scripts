use strict;
$|=1;
my ($infile, $outfile) = @ARGV;
die "Usage: $0 INFILE OUTFILE\n" if not $outfile;
open my $fhin, '<:raw', $infile or die;
open my $fhout, '>:raw', $outfile or die;
my $cont = '';
my $prev = '';
my $counter = 0;
my $size = -s $infile;
my $bytes = 0;
while (1) {
    my $success = read $fhin, $cont, 1;
    die $! if not defined $success;
    last if not $success;
    if ( $cont eq chr(0x0A) && $prev ne chr(0x0D) ) { $counter++; print $fhout chr(0x20); }
    else { print $fhout $cont; }
    printf("%f%%, %d darab\r",++$bytes*100/$size,$counter);
    $prev=$cont;
}
close $fhin;
close $fhout;

