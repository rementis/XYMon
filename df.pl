#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |       Check for df timeout.        |
#     |                                    |
#     |           Martin Colello           |
#     |             2/12/2008              |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my $uname = `uname -a`;
my $test    = 'df';
my $color   = 'green';# Set default status to green.
my $server;
my $df_output;
if ( -e '/usr/bin/hostname' ) {
  chomp($server      = `/usr/bin/hostname`);
}
if ( $uname =~ /Linux/ ) {
  chomp($server = `hostname -s`);
}
my $machine = "$server,amkor,com";
my $results;
#my $checkme = `ps -ef | grep 'df -k' | grep -v grep`;
#if ( $checkme =~ /df/ ) { exit }


chomp(my $date        = `date`);

eval {
  local $SIG{ALRM} = sub { die "alarm\n" };
  alarm(60);
  system("/usr/bin/df -k > /dev/null 2>&1");
  alarm(0);
  };


if ($@) {
  $color = 'red';
  $results .= "\n\ndf -k timed out on server.\nPlease contact Unix team.\n\n";
  }
  else {
  $results .= "\n\ndf command completed normally\n\n";
  $df_output = `df -h`;
  }

if ( $df_output =~ /Stale NFS file handle/ ) {
  $results = "\n\nStale file handle found\n\n$df_output\n\n";
  $color = 'yellow';
}

my $line    = "status $machine.$test $color $results";

print "$line\n";

system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
