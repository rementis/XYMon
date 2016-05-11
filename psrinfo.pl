#!/usr/local/bin/perl
use strict;
use Sys::Hostname;

################################
#                              #
# Check number of processors   #
#                              #
# Martin Colello 10/2012       #
#                              #
################################

# Initialize some variables
my $hostname = hostname();
my $uname    = `uname -a`;
my $test     = 'psrinfo';
my $color    = 'green';
my $machine  = "$hostname,amkor,com";
my $results  = "\n\n";

my $command = '/usr/sbin/psrinfo';

if ( -e $command ) {
  my @output  = `$command`;
  my $output  = @output;
  $results   .= "\n\npsrinfo : $output\n\n";
  if ( $output < 3 ) {
    $color = 'yellow';
  }
} else {
  exit;
}

my $line = "status $machine.$test $color $results";
print "line is $line\n";
#system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
