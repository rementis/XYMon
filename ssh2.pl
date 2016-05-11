#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |       Check if ssh to remote hosts |
#     |         is working properly.       |
#     |                                    |
#     |           Martin Colello           |
#     |             12/07/2011             |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my @hosts = `cat /usr/local/admin/master/hname`;
chomp(@hosts);
foreach( @hosts ) {
  my $host         = $_;
  my $machine      = "$host,amkor,com";
  my $test         = 'ssh2';
  my $color        = 'green'; # Set default status to green.
  my $results      = "\n\n";
  my $ssh          = `ssh -q $host echo "Good"`;
  if ( $ssh !~ /Good/ ) {
    $ssh           = `ssh -q $host echo "Good"`;
    if ( $ssh !~ /Good/ ) {
      $color = 'yellow';
      $results .= "Connection via ssh from chazlog01 to $host is not working.\n\n";
      print "$host NOT good.\n";
      if ( $host =~ /chazxftp03/ ) {
        $color = 'green';
      }
    }
  } else {
    $results .= "Connection via ssh from chazlog01 to $host is working properly.\n\n";
    print "$host\n";
  }
  my $line    = "status+25h $machine.$test $color $results";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
}
