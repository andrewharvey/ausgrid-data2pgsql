#!/usr/bin/perl -w

# Author: Andrew Harvey <andrew.harvey4@gmail.com>
# License: CC0 http://creativecommons.org/publicdomain/zero/1.0/
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;
use Text::CSV;
use DBI;
use File::Basename;

# destination database schema + dot, and table
my $schema = "ausgrid.";
my $dst_table = "works";

my %month_short_num = (
  "JAN" => 1,
  "FEB" => 3,
  "MAR" => 3,
  "APR" => 4,
  "MAY" => 5,
  "JUN" => 6,
  "JUL" => 7,
  "AUG" => 8,
  "SEP" => 9,
  "OCT" => 10,
  "NOV" => 11,
  "DEC" => 12
  );

# for each source data csv filename
for my $src_csv_full_filename (@ARGV) {
  print "$src_csv_full_filename\n";

  my $start_month;
  my $end_month;
  my $year;

  my $src_csv_filename = fileparse($src_csv_full_filename);

  # pull date details from csv filename
  if ($src_csv_filename =~ /^(\w{3})-(\w{3})_(\d{4})\.csv$/) {
    $start_month = $month_short_num{$1};
    $end_month = $month_short_num{$2};
    $year = $3;
  }else{
    die "Source csv filename unexpected form: $src_csv_filename\n";
  }

  # set up database connection
  my $dbh = DBI->connect("DBI:Pg:", '', '' , {'RaiseError' => 1, AutoCommit => 0});
  my $sth;

  # open the source csv file for reading
  my $csv = Text::CSV->new();
  open (my $src_data, '<', "$src_csv_full_filename") or die $!;

  my @header = $csv->getline($src_data);
  $csv->column_names(@header);

  # prepare the insert statement
  $sth = $dbh->prepare("INSERT INTO $schema$dst_table VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);");

  # go through each line in the source csv file and execute the prepared SQL statement
  while (my $row = $csv->getline_hr($src_data)) {
    if ($row->{'LGA'} ne "Total Network") {
      $sth->execute(
        $row->{'LGA'},
        $start_month,
        $end_month,
        $year,
        $row->{'Repairs'},
        $row->{'Average repair time'},
        $row->{'Proactive replacement'},
        $row->{'Total use'},
        $row->{'Average daily use'},
        $row->{'New small substations'},
        $row->{'Installing cables'},
        $row->{'Maintenance jobs'},
        $row->{'Connections'},
        $row->{'Generation capacity'},
        $row->{'Exported power'},
        $row->{'Reports'},
        $row->{'Clean ups'},
        $row->{'Average response time'}
      ) or die $!;
      $dbh->commit or die $!;
    }
  }

  $dbh->disconnect or warn $!;

  close $src_data or warn $!;
}
