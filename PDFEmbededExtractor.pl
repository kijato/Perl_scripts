#!/usr/bin/perl
use strict;
#use strict subs;
#use strict refs;
use CAM::PDF;
use XML::Parser;
#use Data::Dumper;
use utf8; # Perl pragma to enable/disable UTF-8 (or UTF-EBCDIC) in source code (necessary if you want to use Unicode in function or var names)
#use Unicode::UTF8 # Encoding and decoding of UTF-8 encoding form
use DateTime;

BEGIN { $| = 1 } # Turn on autoflush.

my $parameter = shift @ARGV;

if (-e $parameter) { # exists
	filesExtract($parameter);
} else { # glob
	my @parameters = glob($parameter);
	foreach $parameter ( @parameters ) {
		if (-d $parameter) { # directory
			print "The '$parameter' is a directory. Maybe you need to run the script again...\n";
		}
		filesExtract($parameter);
	}
}

sub filesExtract() {
	#
	# A PDF megnyitása
	#

	my $pdffile  = shift @_;
	
	my $doc = CAM::PDF-> new( $pdffile ) or return; # die ($pdffile);
	my $names_dict = $doc-> getValue( $doc-> getRootDict-> { Names }); 
	my $files_tree = $names_dict-> { EmbeddedFiles };
	my @agenda     = $files_tree;
	my $ret = {};
	while ( @agenda ) {
		my $item = $doc-> getValue( shift @agenda );

		if ( $item-> { Kids }) {
			my $kids = $doc-> getValue( $item-> { Kids });
			push @agenda, @$kids
		}
		else {
			my $nodes = $doc-> getValue( $item-> { Names });
			my @names = map { $doc-> getValue( $_ )} @$nodes;
			while ( @names ) {
				my ( $k, $v ) = splice @names, 0, 2;
				my $ef_node   = $v-> { EF };
				my $ef_dict   = $doc-> getValue( $ef_node );
				my $any_num   = ( values %$ef_dict )[ 0 ]-> { value };
				my $obj_node  = $doc-> dereference( $any_num );
				$ret-> { $k } = $doc-> decodeOne( $obj_node-> { value }, 0 );
			}
		}
	}
	#print Dumper($ret);

	#
	# A beágyazott fájlok mentése
	#

	foreach my $filename (keys %$ret) {
	  $pdffile =~ s/\.pdf$//;
	  my $fn = $pdffile.'_-_'.$filename;
	  #open FH,'>:encoding(utf8)',$fn;
	  open FH,'>',$fn;
	  print FH $ret->{$filename};
	  close FH;
	  print "Saved the embeded '$fn' file.\n";
	}
}


__END__


#
# Az XML feldolgozása
#

my $xmlp = XML::Parser->new(Style => 'Tree');
my $xmlref = $xmlp->parse($ret->{'hivatalok.xml'}, ProtocolEncoding => 'UTF-8');

my $hivatalok = [];
for ( my $i=0; $i<=scalar(@{$xmlref->[1]}); $i+=4) {
	#sprintf("%f %%\r", $i / scalar(@{$xmlref->[1]}) * 100 );
	#print $i."\t".$xmlref->[1]->[$i]."\n";
	if ( ref($xmlref->[1]->[$i]) eq 'ARRAY') {
		my $kulcs_ertek = {};
		for ( my $j=0; $j<=scalar(@{$xmlref->[1]->[$i]}); $j+=4) {
			#print "\t".$xmlref->[1]->[$i]->[$j-1].": ";
			if ( ref($xmlref->[1]->[$i]->[$j]) eq 'ARRAY') {
				#print "\"".$xmlref->[1]->[$i]->[$j]->[2]."\";";
				$kulcs_ertek->{$xmlref->[1]->[$i]->[$j-1]} = $xmlref->[1]->[$i]->[$j]->[2]; 
			}
		}
		push @$hivatalok,$kulcs_ertek;
	}
}
#print Dumper($hivatalok);

#
# CSV fájl kiírása
#

# Kigyűjtjük a létező adatmezőket (kulcsokat). Ez fontos, mert nem feltétlenül létezik az összes adatmező egy adott tételnél. (Pl.: hiányozhat a "Megye")
my $keys={};
foreach my $h ( @{$hivatalok} ) {
	foreach my $v ( sort keys %{$h} ) {
		$keys->{$v}++;
	}
}
#print STDERR Dumper($keys);

my $csvfile=$pdffile;
   $csvfile=~s/\.pdf$/.csv/;
open FH,'>:encoding(utf8)',$csvfile; 

my $oneRow="";

# Kiírjuk a fejlécet
foreach my $v ( sort keys %{$keys} ) {
	$oneRow.=$v.';'
}
$oneRow=~s/;$//;
print FH "$oneRow\n";

# Kiírjuk az adatokat
foreach my $h ( @{$hivatalok} ) {
	$oneRow="";
	foreach my $v ( sort keys %{$keys} ) {
		$h->{$v}=~s/"/``/g;
		$h->{$v}=~s/;/˛/g;
		$h->{$v}=~s/\x{0A}/ /g;
		$oneRow.='"'.$h->{$v}.'";'
	}
	$oneRow=~s/\s+/ /g;
	$oneRow=~s/;$//;
	print FH "$oneRow\n";
}
close FH;

unlink 'hivatalok.xml';
unlink $pdffile;
unlink $tmpfile;
