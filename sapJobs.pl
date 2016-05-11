#!/usr/local/bin/perl -w
use strict;

#################################
#                               #
# Check for number of sap jobs  #
#                               #
# Martin Colello                #
# 03/18/2016                    #
#                               #
#################################

#chazerpp01:oraprd 52% /usr/local/admin/scripts/oracle/control_db.ksh sap_active_jobs
#
#  COUNT(*)
#----------
#SUM((SYSDATE-TO_DATE(CONCAT(CONCAT(STRTDATE,''),STRTTIME),'YYYYMMDDHH:MI:SS'))*2
#--------------------------------------------------------------------------------
#        15
#                                                                           11041

my $test     = 'sapJobsTotal';
my $test2    = 'sapJobsSeconds';
my $color    = 'green';
my $results  = "\n";
my $results2 = "\n";
my $hostname = `hostname`;
chomp($hostname);
my $machine  = "$hostname,amkor,com";

my @rawlist = `su - oraprd -c "/usr/local/admin/scripts/oracle/control_db.ksh sap_active_jobs" 2<&1`;
chomp(@rawlist);

my $jobs;
my $seconds;

pop(@rawlist);
pop(@rawlist);

my $seconds_line = pop(@rawlist);
my $jobs_line    = pop(@rawlist);
$seconds_line =~ /(\d+)/;
$seconds = $1;
$jobs_line =~ /(\d+)/;
$jobs = $1;

$results  .= "\n\n";
$results2 .= "\n\n";

$results  .= "sapJobsTotal : $jobs\n\n";
$results2 .= "sapJobsSeconds : $seconds\n\n";

# Send to hobbit
my $line      = "status $machine.$test $color $results";
my $line2     = "status $machine.$test2 $color $results2";
print "$line\n";
print "$line2\n";
system("echo \"$line\"  | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
system("echo \"$line2\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");

