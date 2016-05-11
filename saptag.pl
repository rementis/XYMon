#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |       Check if saptag exists       |
#     |                                    |
#     |           Martin Colello           |
#     |             10/11/2011             |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|


chomp(my $server = `hostname`);
$server =~ s/\.amkor\.com//g;
chomp(my $date   = `date`);
my $test         = 'saptag';
my $color        = 'green'; # Set default status to green.
my $results      = "\n\n";
my $machine      = "$server,amkor,com";

if ( ! -e '/usr/sap' ) { exit }

if ( ! -e '/saptag' ) {
  $color = 'yellow';
  $results .= "/saptag does not exist\n\n";
} else {
  $color = 'green';
  $results .= "/saptag exists\n\n";
  system("chmod 777 /saptag");
  my $saptag = `cat /saptag`;
  my @results = split /:/, $saptag;
  if ( $results[3] ) {
    $results .= "Project:     $results[0]\n";
    $results .= "Type:        $results[1]\n";
    $results .= "Environment: $results[2]\n";
    $results .= "SID:         $results[3]\n";
  }

  if ( ! $results[3] ) {
    $color = 'yellow';
    $results .= "Please check saptag file, it may be incomplete.\n";
  }
}

if ( $machine =~ /^phpa/ ) {
  $color = 'green';
}
if ( $machine =~ /chazlog01/ ) {
  $color = 'green';
}
if ( $machine =~ /chazxpr02/ ) {
  $color = 'green';
}
if ( $machine =~ /chazsrt01|chazsec01/ ) {
  $color = 'green';
}
if ( $machine =~ /audrerpp01|audrbpr01/ ) {
  $color = 'green';
}
if ( $machine =~ /auplmdbd01/ ) { $color = 'green' }


my $line    = "status $machine.$test $color $results";
print "$line\n";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
