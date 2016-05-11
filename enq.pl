#!/usr/local/bin/perl -w
use strict;

############################
#                          #
# Check SAP enqueue stats  #
#                          #
# Martin Colello 06/2011   #
#                          #
############################

my $color    = 'green';
my $hostname = `hostname`;
chomp($hostname);
my $machine  = "$hostname,amkor,com";
my $test     = 'enq';
my $results  = "\n\n";
my $limit;
my $peak;
my $actual;

my @enqstat = `cat /usr/sap/PRD/ASCS01/data/ENQSTAT`;
chomp(@enqstat);

my $startsearch = 'off';
foreach(@enqstat) {
  my $line = $_;
  if ( $line =~ /Granule Entries/ ) {
    $startsearch = 'on';
    $line =~ /:\s(\d+)/;
    $limit = $1;
    $results .= "limit : $limit\n";
  }
  if ( $startsearch eq 'on' ) {
    if ( $line =~ /Peak Util/ ) {
      $line =~ /:\s(\d+)/;
      $peak = $1;
      $results .= "peak : $peak\n";
    }
  }  
  if ( $startsearch eq 'on' ) {
    if ( $line =~ /Actual Util/ ) {
      $line =~ /:\s(\d+)/;
      $actual = $1;
      $results .= "actual : $actual\n";
      $startsearch = 'off';
    }
  }  
}

if ( $actual > 120000 ) {
  $color = 'yellow';
}
  
if ( $actual > 139999 ) {
  $color = 'red';
  $results .= "\n\nAssign any ticket to SAP Basis\n";
}

my $line = "status $machine.$test $color $results";
# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
