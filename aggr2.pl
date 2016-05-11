#!/usr/local/bin/perl -w
use strict;

############################################
#                                          #
# Check aggr size on NetApp cluster        #
#                                          #
# Martin Colello 01/2016                   #
#                                          #
############################################

my $results  = "\n\n";
my $color    = 'green';
my $hostname = `hostname`;
chomp($hostname);
my $machine  = 'asclst01,amkor,com';
my $test     = 'aggr2';
$results .= "Aggregate              Size      Percent      Used\n\n";
my $results2 = "\n";

my $command='ssh -q -o StrictHostKeyChecking=no -i /usr/local/admin/snapdot/.ssh/id_dsa -l snapdot asclst01 storage aggr show -fields usedsize,availsize,percent-used';

my @output = `$command`;
chomp(@output);

foreach(@output) {
  my $line = $_;

  # Skip unwanted output lines
  if ( $line =~ /aggregate/ ) { next }
  if ( $line =~ /displayed/ ) { next }
  if ( $line =~ /---/       ) { next }
  if ( $line =~ /^\s/       ) { next }

  # Add output line to results
  $results .= "$line\n";

  # Determine if any percentages are over 89
  # and if so turn color to red
  my @split = split /\s+/, $line;
  my $percent = $split[2];
  $percent =~ s/%//;
  if ( $percent gt 89 ) {
    $color = 'red';
  }
  $results2 .= "$split[0] : $percent\n";

}

# Raw output example
#aggregate              availsize percent-used usedsize 
#---------------------- --------- ------------ -------- 
#ASCLST01_01_root_aggr0 812.3GB   43%          603.4GB  
#ASCLST01_01_sata_aggr0 56.13TB   66%          111.2TB  
#ASCLST01_01_sata_aggr1 13.29TB   77%          45.54TB  
#ASCLST01_02_root_aggr0 812.3GB   43%          603.4GB  
#ASCLST01_02_sata_aggr0 43.08TB   75%          131.5TB  
#5 entries were displayed.

my $final_results = "$results\n\n$results2\n";


my $line = "status $machine.$test $color $final_results";
print "$line\n";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
