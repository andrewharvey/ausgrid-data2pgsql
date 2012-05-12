#!/usr/bin/perl -w

# Loads .csv usage file from http://www.ausgrid.com.au/Common/About-us/Sharing-information/Data-to-share/Average-electricity-use.aspx
# into PostgreSQL (after some tweaks done by the download-data.sh script).
#
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

# destination database schema + dot, and table
my $schema = "ausgrid.";
my $dst_table = "usage";

my $src_csv_full_filename = $ARGV[0];
print "$src_csv_full_filename\n";

my $year;

# pull year from csv filename
if ($src_csv_full_filename =~ /LGA_(\d{4})\.csv$/) {
  $year = $1;
}else{
  die "Source csv filename unexpected form: $src_csv_full_filename\n";
}

# set up database connection
my $dbh = DBI->connect("DBI:Pg:", '', '' , {'RaiseError' => 1, AutoCommit => 0});
my $sth;

# open the source csv file for reading
my $csv = Text::CSV->new();
open (my $src_data, '<', "$src_csv_full_filename") or die $!;

# prepare the insert statement
$sth = $dbh->prepare("INSERT INTO $schema$dst_table VALUES (?,?,?,?,?,?,?,?,?,?);");

# go through each line in the source csv file and execute the prepared SQL statement
while (my $row = $csv->getline($src_data)) {
  my $lga_name = $row->[0];
  $lga_name =~ s/^\s*//; # trim leading whitespace
  $lga_name =~ s/\s*$//; # trim trailing whitespace

  # total residential 1 2 3
  my @res_gen_supply = ($row->[4], $row->[5], $row->[6]);
  my @res_off_peak = ($row->[7], $row->[8], $row->[9]);
  my @non_res_small = ($row->[10], $row->[11], $row->[12]);
  my @non_res_med_large = ($row->[13], $row->[14], $row->[15]);

  my $res_gen_supply_kwh = $res_gen_supply[0];
  my $res_gen_supply_customers = $res_gen_supply[1];
  my $res_off_peak_kwh = $res_off_peak[0];
  my $res_off_peak_customers = $res_off_peak[1];
  my $non_res_small_kwh = $non_res_small[0];
  my $non_res_small_customers = $non_res_small[1];
  my $non_res_med_large_kwh = $non_res_med_large[0];
  my $non_res_med_large_customers = $non_res_med_large[1];

  $res_gen_supply_kwh =~ tr/,//d;
  $res_gen_supply_customers =~ tr/,//d;
  $res_off_peak_kwh =~ tr/,//d;
  $res_off_peak_customers =~ tr/,//d;
  $non_res_small_kwh =~ tr/,//d;
  $non_res_small_customers =~ tr/,//d;
  $non_res_med_large_kwh =~ tr/,//d;
  $non_res_med_large_customers =~ tr/,//d;

  $sth->execute(
    $year,
    $lga_name,
    $res_gen_supply_kwh,
    $res_gen_supply_customers,
    $res_off_peak_kwh,
    $res_off_peak_customers,
    $non_res_small_kwh,
    $non_res_small_customers,
    $non_res_med_large_kwh,
    $non_res_med_large_customers
  ) or die $!;
  $dbh->commit or die $!;
}

$dbh->disconnect or warn $!;

close $src_data or warn $!;
