use strict;
use WWW::Mechanize;

my $url = "https://goalkicker.com/";
my $mech = WWW::Mechanize->new();

#$mech->proxy(['http','https'],'http://xxx.xxx.xxx.xxx:xxxx/');
print $mech->status()."\n";
$mech->get($url) || die "$!";
die unless ($mech->success);

my @links = $mech->find_all_links();
for my $link ( @links ) {
	my $url = $link->url_abs;
	print "Fetching '$url' ...\n";
	$mech->get($url) || die "$!";
	my @pdflinks = $mech->find_all_links( url_regex =>  qr/(.pdf)$/i );
	for my $pdflink ( @pdflinks ) {
		my $pdfurl = $pdflink->url_abs;
		my $pdffilename = $pdfurl;
		$pdffilename =~ s[^.+/][];
		$mech->get($pdfurl, ':content_file' => "$pdffilename");
	}
}
