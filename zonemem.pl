#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     | Monitor cpu utilization on a local |
#     |                zone.               |
#     |                                    |
#     |           Martin Colello           |
#     |             7/25/2007              |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|


my $uname = `uname -a`;
if ( $uname =~ /Linux/ ) {
  exit;
}

chomp(my $date        = `/usr/bin/date`);
chomp(my @raw_results = `/usr/bin/prstat -Z 1 1 | grep chaz`);
my $server;
my $amount;

foreach(@raw_results){
  my @temp = split /\s+/, $_;
  $server = $temp[8];
  $amount = $temp[5];
  $amount =~ s/\%//g;

  my $test    = 'zonemem';
  my $color   = 'green';# Set default status to green.

  my $machine = "$server,amkor,com";

  my $mem = "\n\nmem : $amount\n\n";
  my $line    = "status $machine.$test $color $mem";

  # Send to hobbit
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");

}# End of foreach(@raw_results)
