use strict;
use WWW::Mechanize;
use HTML::TreeBuilder;
#use Data::Dumper;

$|=1;

my $links = {};

my $mech = WWW::Mechanize->new();
my $proxy_ip   = '0.0.0.0';
my $proxy_port = '0';
$mech->proxy(['http','https'],"http://$proxy_ip:$proxy_port");

my $url = "https://www.geotradegnss.com/index.php?page=geotradegnss&spage=hasznalat_lista";
$mech->get($url) || die "$!";

$mech->submit_form(
	form_name => 'urlap',
    fields    => { felhasznalonev => $ARGV[0],
                   jelszo => $ARGV[1] },
);
$mech->submit();

my $rows;

my $i=0;

my $year = 1900 + (localtime)[5];
foreach my $y ( 2008 .. $year ) {

	foreach my $m ( 1 .. 12 ) {

		$mech->get("https://www.geotradegnss.com/index.php?page=geotradegnss&spage=hasznalat_lista&lang=hu&ev=$y&ho=$m") || die "$!";
		
		my $tree = HTML::TreeBuilder->new_from_content($mech->content);
		
		foreach my $tr ($tree->look_down(_tag => 'tr')) {

			my @row = ();

			foreach my $th ($tr->look_down(_tag => 'th')) {
				if ($th->as_text ne "") {
					# print "\t".$th->as_text."\t";
					push @row, $th->as_text;
				} else {
					next;
				}
			}

			foreach my $td ($tr->look_down(_tag => 'td')) {
				if ($td->as_text ne "") {
					# print "\t".$td->as_text."\t";
					push @row, $td->as_text;
				} else {
					next;
				}
			}

			push @{$rows},\@row;
			printf STDERR  ("Year: %4u\tMonth: %2u\tCount of rows: %u\r",$y,$m,++$i);

		} # tr

	} # $m

} # $y

$i=0;
print "Sorszám\tIdőpont\tFelhasználó\tIdőtartam[perc]\tBázisállomás\n";
foreach my $row ( @$rows ) {
	next unless ( $$row[0] =~ /^\d{4}/ );
	print ++$i.".\t";
	foreach my $r ( @$row ) {
		print $r."\t";
	}
	print "\n";
}
