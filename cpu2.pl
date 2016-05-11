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


my $global = '/global';
#if ( -e $global ) {
#  my $check_global = `cat $global`;
#  if ( $check_global =~ /augzd05/ ) { exit }
#}

my $top_command;

my $type = "check";
my $threshold = 99;
my $server;
my $uname = `uname -a`;
if ( $uname =~ /Linux/ ) {
  chomp($server      = `hostname -s`);
  $type = "linux";
  $top_command = "top -b -n 1 | head -25";
} else {
  chomp($server      = `hostname`);
  $top_command = "top -d 1";
}

my $top = `$top_command`;
print "$top\n";

chomp(my $date        = `date`);
chomp(my @raw_results = `/usr/bin/vmstat 1 5`);

if ( $server =~ /chazlog01/ ) {
  my $logtmp = '/tmp/cpu2.log';
  open OUT, ">>$logtmp";
  foreach(@raw_results){
    print OUT "$_\n";
  }
}


chomp(my $results = pop(@raw_results));

my @results = split /\s+/,$results;
chomp(my $percent_idle = pop(@results));
if ( $type =~ /linux/ ) {
  chomp($percent_idle = $results[-2]);
}
my $cpu = 100 - $percent_idle;

my $test    = 'cpu2';
my $color   = 'green';# Set default status to green.

my $machine = "$server,amkor,com";
  if ( $cpu > $threshold )         { $color = 'red'   }
  if ( $server =~ /chazlic01/ )    { $color = 'green' }
  if ( $server =~ /chazgrd01/ )    { $color = 'green' }
  if ( $server =~ /chazsec02/ )    { $color = 'green' }
  my $percent = "\n\nPercentage : $cpu\n\n";
  #my $line    = "status $machine.$test $color $percent\n\n$top\n";
  my $line    = "status $machine.$test $color $percent";

# Send to hobbit
print "line is $line\n";

system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
