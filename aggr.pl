#!/usr/local/bin/perl -w
use strict;
use Sys::Hostname;

###########################################
#                                         #
# Check if all links of aggr are online   #
#                                         #
# Martin Colello 06/2013                  #
#                                         #
###########################################

my $hostname = hostname();
chomp($hostname);
my $color    = 'green';
my $machine  = "$hostname,amkor,com";
my $test     = 'aggr';
my $results  = "\n";

my $uname = `uname -a`;
if ( $uname =~ /5\.11/ ) { exit }

my @dladm    = `/usr/sbin/dladm show-aggr | grep -v key | grep -v device`;
chomp(@dladm);

#           ixgbe2       90:e2:ba:35:64:dc         10000 Mbps    full    up      attached
#           ixgbe6       90:e2:ba:3b:5f:3c         10000 Mbps    full    up      attached

# If no output from command exit
if ( ! @dladm ) {
    exit;
}

# Check output for correct txt
foreach (@dladm) {
  my $line = $_;
  $line =~ s/^\s+//g;
  print "line: $line\n";
  $results .= "$line\n";
  if ( ($line !~ /full/) or ($line !~ /up/) or ($line !~ /attached/) ) {
    $color = 'red';
  }
}

# Modify output based on green or red result
if ( $color eq 'green' ) {
  $results = "\n\nAll interfaces ok:\n\n$results\n";
} else {
  $results = "\n\nProblem with aggr:\n\n$results\n";
}

# Build xymon data line
my $line = "status $machine.$test $color $results";

#print "$line\n";

# Send to xymon
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
