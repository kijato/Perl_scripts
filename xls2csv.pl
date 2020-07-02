#!/usr/bin/perl -w

use strict;
use warnings;
use Spreadsheet::ParseExcel;
use encoding "LATIN2";
#use encoding 'utf8';
#$|=0;

my $fajl=$ARGV[0] || die "Hiányzó paraméter!\n";
my $formated = $ARGV[1] || 1;
my $separator = $ARGV[2] || ';';

my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse($fajl);
if ( !defined $workbook ) { die $parser->error(), ".\n"; }

for my $worksheet ( $workbook->worksheets() ) {
  my ( $row_min, $row_max ) = $worksheet->row_range();
  my ( $col_min, $col_max ) = $worksheet->col_range();
  #print "Sheet name: ".$worksheet->{Name}."\n";
  for my $row ( $row_min .. $row_max ) {
    print $worksheet->{Name}." [",$row+1,"];";
    for my $col ( $col_min .. $col_max ) {
      my $cell = $worksheet->get_cell( $row, $col );
      #next unless $cell;
      unless ($cell) { print $separator; next; }
      #print "Row, Col    = ($row, $col)\t";
      if ($formated) {
        print $cell->value(); # The value() method returns the formatted value of the cell.
      } else {
        print $cell->unformatted(); # The unformatted() method returns the unformatted value of the cell.
      }
      print $separator;
    }
    print "\n";
  }
}
