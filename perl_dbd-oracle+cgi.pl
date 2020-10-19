#
# https://docs.cs.cf.ac.uk/notes/accessing-oracle-with-perl/
#

#!/usr/bin/perl
use CGI;
use DBI;
# start a new CGI session
$q = new CGI;
# output the CGI header
print $q->header;
# output some HTML to set up the page
print "<title>Perl CGI using DBI to access Oracle</title>\n";
print "<h1>Perl CGI using DBI to access Oracle</h1>\n";
# are the user name and password assigned?
if( $q->param('username') ne "" && $q->param('password') ne "" ) {
	# yes. Let's see if they work
	$driver= "Oracle";
	$dsn = "DBI:$driver:sid=csora12edu;host=csoracle.cs.cf.ac.uk";
	$dbh = DBI->connect($dsn, $q->param('username'), $q->param('password'));
	# if the user name and password are bad, then $dbh is null
}
if( $q->param('username') eq "" || $q->param('password') eq ""
                                                || $dbh eq "" ) {
	# the username and password are empty, or didn't work
	# prompt for them...
	print "<p>Enter the Oracle account name and password</p>\n";
	print $q->start_form;
	print "<table border=0>\n";
	print "<tr>\n";
	print "<td width=\"200\">\n";
	print "Oracle account name:\n";
	print "</td>\n";
	print "<td>\n";
	print $q->textfield('username');
	print "</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td width=\"200\">\n";
	print "Password:\n";
	print "</td>\n";
	print "<td>\n";
	print $q->password_field('password');
	print "</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td width=\"200\">\n";
	print $q->submit(-name=>'Action', -value=>'Login');
	print "</td>\n";
	print "<td>\n";
	print "&nbsp";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print $q->end_form;
	# and exit the CGI script
	exit;
}
# else we have logged in to Oracle
# run the SQL command
$sth = $dbh->prepare("select s.student_no, surname, forename, module_code, mark
       from students s, marks m
       where module_code = 'CM0001' and m.student_no = s.student_no order by mark desc");
$sth->execute;
# retrieve and output the result
print "<p>The marks are as follows:</p>\n";
print "<table cols=5 border=1>\n";
print "<tr>\n";
print "<th>Student ID</th>\n";
print "<th>Surname</th>\n";
print "<th>Forename</th>\n";
print "<th>Module</th>\n";
print "<th>Mark</th>\n";
print "</tr>";
while(  my $ref = $sth->fetchrow_hashref() ) {
        print "<tr>\n";
        print "<td>", $ref->{'STUDENT_NO'}, "</td>\n";
        print "<td>", $ref->{'SURNAME'}, "</td>\n";
        print "<td>", $ref->{'FORENAME'}, "</td>\n";
        print "<td>", $ref->{'MODULE_CODE'}, "</td>\n";
        print "<td>", $ref->{'MARK'}, "</td>\n";
        print "</tr>\n";
}
print "</table>\n";
exit;
