use strict;
use WWW::Mechanize;
use HTML::TreeBuilder;

$|=0;

my $users = {
              'user1'=>'pw1',
              'user2'=>'pw2'
            };

my $mech = WWW::Mechanize->new();

my $proxy_ip   = '0.0.0.0';
my $proxy_port = '0';
$mech->proxy(['http','https'],"http://$proxy_ip:$proxy_port");

my $url = "https://www.gnssnet.hu";
$mech->get($url) || die "$!";

$mech->submit_form(
    form_id => 'login-form',
    fields  => { 'LoginForm[username]' => 'user',
                 'LoginForm[password]' => 'pw' },
    button  => 'login-button'
);

#<a href="/index.php?r=usage%2Findex">Használat és Igazolás</a>
#$mech->get('https://www.gnssnet.hu/index.php?r=usage%2Findex') || die "$!";

#<a href="/index.php?r=usage%2Fview&amp;id=10863">Valós idejű szolgáltatás</a>
#https://www.gnssnet.hu/index.php?r=usage%2Fview&id=0000	user1
#https://www.gnssnet.hu/index.php?r=usage%2Fview&id=0000	user2

foreach my $user ( sort keys %{$users} ) {
	$mech->get('https://www.gnssnet.hu/index.php?r=usage%2Fview&id='.$users->{$user}) || die "$!";

	##########################################################
	#                                                        #
	#  Az eredményben nincs benne az inicializálás helye!!!  #
	#                                                        #
	##########################################################

	my $tree = HTML::TreeBuilder->new_from_content($mech->content);
	my $u = $tree->look_down(_tag => 'h6')->as_text();
	$u =~ s/(.*):\s*(\w+)/$2/;
	print $u."\n";
	foreach my $tr ($tree->look_down(_tag => 'tr')) {
		foreach my $td ($tr->look_down(_tag => 'td')) {
			if ($td->as_text ne "") {
				print $td->as_text."\t";
			} else {
				next;
			}
			my $a = $td->look_down(_tag => 'a') or next;
		}
		print "\n";
	}
	print "\n";
}

$mech->get('https://www.gnssnet.hu/index.php?r=site%2Fuserout') || die "$!";
