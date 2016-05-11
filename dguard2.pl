#!/usr/local/bin/perl
use strict;
use Sys::Hostname;

###################################################
#                                                 #
# Determine how many minutes behind the dataguard #
# instance is and report status to XYMon.         #
#                                                 #
# Martin Colello                                  #
# 02/29/2016                                      #
#                                                 #
###################################################
 
my $hostname = hostname();
chomp($hostname);

# Set sids to blank
my $sid1 = 'none';
my $sid2 = 'none';

if ( $hostname =~ /audrbpr01/ ) { 
  $sid1 = 'BPRS';# Dataguard sid for setting env of sql query
  $sid2 = 'bpr'; # User name sid, will become orabpr
}
if ( $hostname =~ /audrerpp01/ ) { 
  $sid1 = 'PRDS';
  $sid2 = 'prd';
}
$sid2 = 'ora'."$sid2";

# If sid is unknown just quit
if ( $sid1 =~ /none/ ) { exit }

my $test    = 'dguard';
my $color   = 'green';
my $machine = "$hostname,amkor,com";


# Build SQL Query
my $temp_query = '/tmp/dataguard.ksh';
open QUERY, ">$temp_query" or die "Cannot open: $!";
print QUERY '#!/bin/ksh';
print QUERY "\n";
print QUERY "export ORACLE_SID=$sid1\n";
print QUERY "export DB_SID=$sid1\n";
print QUERY "sqlplus '/as sysdba' << EOF\n";
print QUERY "set linesize 1000;\n";
print QUERY 'select * from V\$DATAGUARD_STATS;';
print QUERY "\n";
print QUERY "EOF\n";
close QUERY;

# Run SQL Query
system("chmod +x $temp_query");
my $raw_data = `su - $sid2 -c "$temp_query"`;
unlink("$temp_query");

print "$raw_data\n";
# Grep through data and do math to get total time
$raw_data =~ /apply lag\s+\+(\d+)\s(.*?)\s/;

my $days = $1;
my $time = $2;

$time =~ /(\d+):(\d+):(\d+)/;
my $hours   = $1;
my $minutes = $2;
my $seconds = $3;

my $total_seconds = $days * 86400;
$total_seconds    = $total_seconds + ($hours * 60 * 60);
$total_seconds    = $total_seconds + ($minutes * 60);
$total_seconds    = $total_seconds + $seconds;

my $total_hours   = $total_seconds / 3600;
my $total_minutes = $total_seconds / 60;
$days             = $total_minutes / 1440;
$total_minutes    = sprintf "%.2f",$total_minutes;
$hours            = $total_minutes / 60;

$days             = sprintf "%.2f",$days;# Shorten to two decimal places
$hours            = sprintf "%.2f",$hours;

# Build XYMon output
my $results = "\n\n";
$results .= "Minutes Behind\n\nminutes : $total_minutes\n\n";

if ( $days > 1  ) {
  $results .= "$days days or ";
}
if ( $total_hours > 1 ) {
  $results .= "$hours hours\n";
}

if ( $total_minutes > 100 ) {
  $color = 'yellow';
}
if ( $total_minutes > 140 ) {
  $color = 'red';
}

# Build final XYMon status line
my $line = "status $machine.$test $color $results";
print "$line\n";

# Send to XYMon
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
