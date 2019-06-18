use strict;
use Data::Dumper; # print Dumper(\%s);
use Data::Dumper::Concise; # kulcsok rendezése ABC szerint
use Data::Printer; # p %variable;

my @pontok = (); # pontok mindkét rendszerben
my %affin = ( a=>0, b=>0, c=>0, d=>0 ); # paraméterek
my %s = ( y1=>0, x1=>0, y2=>0, x2=>0 ); # súlypont, és hozzá közhető adatok

open FH,$ARGV[0] or die "$!\n";
my @row;
my $sorszam=0;
while(<FH>){
	if(++$sorszam==1){next;}
	chomp;
	s/\s+//g;
	@row = split(/;/);
	push @pontok,{ id=>$row[0], y1=>$row[1], x1=>$row[2], y2=>$row[3], x2=>$row[4] };
	$s{'y1'}+=$row[1];
	$s{'x1'}+=$row[2];
	$s{'y2'}+=$row[3];
	$s{'x2'}+=$row[4];
}
close FH;
print"\nPontok:\n"; p @pontok;

# súlypont számítása
foreach ( keys %s ) {
	$s{$_}/=@pontok;
}
print"\nsúlypont:\n", Dumper(\%s);

foreach my $p ( @pontok ) {
	# súlyponti koordináták számítása
	foreach ( ('y1','x1','y2','x2') ) {
		$p->{'s_'.$_}=$p->{$_}-$s{$_};
	}
	# együtthatók számítása
	$s{'yy'} += $p->{'s_y1'} * $p->{'s_y1'};
	$s{'yx'} += $p->{'s_y1'} * $p->{'s_x1'};
	$s{'ya'} += $p->{'s_y1'} * $p->{'s_y2'};
	$s{'yb'} += $p->{'s_y1'} * $p->{'s_x2'};
	$s{'xx'} += $p->{'s_x1'} * $p->{'s_x1'};
	$s{'xa'} += $p->{'s_x1'} * $p->{'s_y2'};
	$s{'xb'} += $p->{'s_x1'} * $p->{'s_x2'};
}
# paraméterek számítása
$affin{'a'} = ( ( $s{'ya'} * $s{'xx'} ) - ( $s{'xa'} * $s{'yx'} ) ) / ( ( $s{'yy'} * $s{'xx'} ) - ( $s{'yx'} * $s{'yx'} ) );
$affin{'b'} = ( ( $s{'xa'} * $s{'yy'} ) - ( $s{'ya'} * $s{'yx'} ) ) / ( ( $s{'yy'} * $s{'xx'} ) - ( $s{'yx'} * $s{'yx'} ) );
$affin{'c'} = ( ( $s{'yb'} * $s{'xx'} ) - ( $s{'xb'} * $s{'yx'} ) ) / ( ( $s{'yy'} * $s{'xx'} ) - ( $s{'yx'} * $s{'yx'} ) );
$affin{'d'} = ( ( $s{'xb'} * $s{'yy'} ) - ( $s{'yb'} * $s{'yx'} ) ) / ( ( $s{'yy'} * $s{'xx'} ) - ( $s{'yx'} * $s{'yx'} ) );
print "\nParaméterek:\n"; p %affin;

#pktr^[i].a:=as + a*(pktr^[i].y-ys) + b*(pktr^[i].x-xs);
#pktr^[i].b:=bs + c*(pktr^[i].y-ys) + d*(pktr^[i].x-xs);

foreach my $p ( @pontok ) {
	foreach ( ('y1','x1','y2','x2') ) {
	#pktr^[i].ey:=pktr^[i].a-(as + a*(pktr^[i].y-ys) + b*(pktr^[i].x-xs));
	#pktr^[i].ex:=pktr^[i].b-(bs - b*(pktr^[i].y-ys) + a*(pktr^[i].x-xs));
	#pktr^[i].em:=sqrt(sqr(pktr^[i].ey)+sqr(pktr^[i].ex));
	$p->{'ey'} =  ( $s{'y2'} + $affin{'a'} * ( $p->{y1} - $s{'y1'} ) + $affin{'b'} * ( $p->{x1} - $s{'x1'} ) ) - $p->{y2};
	$p->{'ex'} =  ( $s{'x2'} + $affin{'c'} * ( $p->{y1} - $s{'y1'} ) + $affin{'d'} * ( $p->{x1} - $s{'x1'} ) ) - $p->{x2};
	$p->{'em'} = sqrt( $p->{'ey'}**2 + $p->{'ex'}**2 );
	}
}
print"\nPontok:\n"; p @pontok;
print"\nSúlypont:\n"; p %s;

print "\nEltérések:\n";
foreach my $p ( @pontok ) {
	foreach ( ('id','y1','x1','y2','x2','ey','ex','em') ) {
		print "$_: ".$p->{$_}."\t";
	}
	print "\n";
}


__END__

foreach ( keys %affin ) { print $_.": ".$affin{$_}."\n"; }
foreach my $key (keys %{ $ad_grp_ref }) { ... }

Paraméterek:
{
    a   8.33797203269079,
    b   5.51619933636013,
    c   -5.52052610314876,
    d   8.33961010715281
}

Súlypont:
{
    xa   -11991.63875,
    xb   342988.5035,
    xx   27939.70425475,
    x1   297.10375,
    x2   137031.5,
    ya   671628.18175,
    yb   -683588.2195,
    yx   -19922.42432175,
    yy   93730.73482475,
    y1   513.16825,
    y2   676764.25
}

Pontok és eltérések:
id: 1   y1: 401.038     x1: 427.743     y2: 676550.0    x2: 138740.0    ey: -0.0567443660693243  ex: -0.0016182315594051   em: 0.0567674356826987
id: 2   y1: 668.69      x1: 303.107     y2: 678094.0    x2: 136223.0    ey:  0.101125641143881   ex:  0.00288389337947592  em: 0.101166754113123
id: 3   y1: 658.848     x1: 201.383     y2: 677451.0    x2: 135429.0    ey: -0.0910563964862376  ex: -0.00259673944674432  em: 0.0910934157709172
id: 4   y1: 324.097     x1: 256.182     y2: 674962.0    x2: 137734.0    ey:  0.0466751214116812  ex:  0.00133107759756967  em: 0.0466940973396631
