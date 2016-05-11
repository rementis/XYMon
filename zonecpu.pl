#!/usr/local/bin/perl -w
use strict;

###############################################
#                                             #
# Monitor cpu utilization on a per-zone basis #
#                                             #
# Martin Colello                              #
# 4/3/2007                                    #
#                                             #
###############################################

my $uname = `uname -a`;
if ( $uname =~ /Linux/ ) {
  exit;
}
chomp(my $global      = `hostname`);

if ($global =~ /chazplmapb01/) {exit};
if ($global =~ /chazplmapd01/) {exit};
if ($global =~ /chazplmapq01/) {exit};
if ($global =~ /chazi3db01/)   {exit};


chomp(my $date        = `date`);
chomp(my @raw_results = `prstat -n 2,25 -Z 1 1`);

my %server_cpu;# Hash of servername/cpu percentage
my $global_servername='empty';
my $global_percentage='empty';


foreach(@raw_results) {
  if ( $_ =~ /%.*%/ ) {
    chomp(my @temp  = split /\s+/, $_);
    my $percentage  = $temp[7];
    my $server_name = $temp[8];
    if ( $server_name eq 'global' ) {
      $global_servername = $global;
      $global_percentage = $percentage;
      next;# Don't put global zone in hash
    }
    $percentage =~ s/%//g;
    $server_cpu{$server_name} = $percentage;# Build hash
  }
}

my $results = "\n\n";
$results   .= "Zone              CPU\n\n";
my $test    = 'zonecpu';
my $color   = 'green';# Set default status to green.

# Cycle through zones and report for each
while ( my ($server, $percent) = each(%server_cpu) ) {
  $results   .= sprintf("%-15s   %.1f \n",$server,$percent);# Built for global zone report
  my $machine = "$server,amkor,com";
  if ( $percent > 90 ) { $color = 'red' }
  $percent    = "\n\nPercentage : $percent\n\n";
  my $line    = "status $machine.$test $color $percent";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
}

# Take care of global zone reporting
my $machine = "$global_servername,amkor,com";
my $percent = "\n\nPercentage : $global_percentage\n\n";
my $line    = "status $machine.$test $color $percent $results";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
