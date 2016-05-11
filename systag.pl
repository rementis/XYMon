#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |       Check if systag exists       |
#     |                                    |
#     |           Martin Colello           |
#     |             09/09/2013             |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|


my $uname = `uname -a`;
my $server;
if ( $uname =~ /Linux/ ) {
  chomp($server = `hostname -s`);
} else {
  chomp($server = `hostname`);
}
$server =~ s/\.amkor\.com//g;
  
chomp(my $date   = `date`);
my $test         = 'systag';
my $color        = 'green'; # Set default status to green.
my $results      = "\n\n";
my $machine      = "$server,amkor,com";

if ( ! -e '/systag' ) {
  $color = 'yellow';
  $results .= "/systag does not exist\n\n";
} else {
  $color = 'green';
  $results .= "/systag exists\n\n";
  my $saptag = `cat /systag`;
  my @results = split /,/, $saptag;
  if ( $results[2] ) {
    $results .= "Type:        $results[0]\n";
    $results .= "HW  :        $results[1]\n";
    $results .= "App :        $results[2]\n";
  }

  if ( ! $results[2] ) {
    $color = 'yellow';
    $results .= "Please check systag file, it may be incomplete.\n";
  }

}


my $line    = "status $machine.$test $color $results";
print "$line\n";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
