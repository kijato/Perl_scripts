#
# https://metacpan.org/pod/DBD::Oracle
# http://www.juliandyke.com/Research/Development/UsingPerlDBIWithOracle.php
# https://docstore.mik.ua/orelly/linux/dbi/ch06_01.htm
# https://metacpan.org/pod/DBI#table_info
#

use strict;
use DBI;
use Data::Dumper;


#my ($host,$port,$sid,$user,$passwd) = ('10.108.1.7', '1521', 'ORCL', 'plsql', 'plsql');

my $dbh = DBI->connect("dbi:Oracle:host=$host;port=$port;sid=$sid", $user, $passwd, { RaiseError => 1 } ) || die $!;
$dbh->{AutoCommit}=>1;

$dbh->do("alter session set NLS_NUMERIC_CHARACTERS = '.,'");
$dbh->do("alter session set NLS_DATE_FORMAT='YYYY-MM-DD'");

print"\n";

my $sql = "SELECT current_date FROM dual";
my $count = $dbh->selectrow_array ($sql);
printf("Current date: %s\n\n", $count);


#my $sth = $dbh->prepare("SELECT tablespace_name, table_name, num_rows from user_tables WHERE rownum<5");
my $sth = $dbh->prepare("SELECT * FROM nls_session_parameters ORDER BY 1"); # nls_parameters, nls_database_parameters, nls_instance_parameters, nls_session_parameters

# fetchrow_hashref:
$sth->execute;
while(  my $ref = $sth->fetchrow_hashref() ) {
	#printf "%-10s %-30s %-10s %s\n", $ref->{'TABLESPACE_NAME'}, $ref->{'TABLE_NAME'}, $ref->{'NUM_ROWS'};
	printf "%s %s\n", $ref->{'PARAMETER'}, $ref->{'VALUE'};
}
print"\n";

#fetchrow_array
$sth->execute;
while ( my @data = $sth->fetchrow_array())
{
	print join("\t",@data);
	print "\n";
}
print"\n";

#fetchall_arrayref
$sth->execute;
my $array = $sth->fetchall_arrayref();
foreach my $row (@$array)
{
	printf ("%-10s %-30s %-10s %s\n",@$row[0],@$row[1],@$row[2]);
}
print"\n";

if($sth){ $sth->finish; }

$dbh->disconnect;

__END__

$dbh = DBI->connect ('dbi::SQLite:alkalmazott.db', undef, undef) or die DBI->errstr;
$dbh->do ('CREATE TABLE Alkalmazott (azonosito INTEGER, nev VARCHAR(75), fizetes INTEGER)') or die $dbh - >errstr;
	$sth = $dbh - >prepare ('INSERT INTO Alkalmazott VALUES (?, ?, ?)');
	open (F, "data.cvs");
	while (<F>) {
		@data = split(',');
		$sth - >execute(@data) or die $sth - >errstr;
	}
	close(F);
