#!/usr/local/bin/perl -w
use strict;

my @filers = qw ( asfasp01 asfasp02 asfasd01 asfasd02 asclst01 adrsclst01);
my $uname = `uname -a`;
my $results;
my $test = 'ndisk';
my $green_header = "All disks register ok.\n\n\n";
my $color;

my @time_data = localtime(time);
my $hour      = $time_data[2];

foreach( @filers ){

  my $filer = $_;
  my $output;
  if ( $filer !~ /asclst01|adrsclst01/ ) {
    $output  = `rsh $filer vol status -f`;
  } else {
    $output  = `ssh -o StrictHostKeyChecking=no -i /usr/local/admin/snapdot/.ssh/id_dsa -l snapdot $filer storage disk show -container-type broken 2>&1`;
  }
  print "$filer: $output\n";
  if ( ($output !~ /Broken disks \(empty\)/) && ($output !~ /There are no entries matching your query/) ) {
    $results  = "$output \n\n\n";
    $results .= "priv set advanced\n";
    $results .= "led_on DEVICE\n";
    $results .= "led_off DEVICE\n";
    $results .= "priv set -q\n";
    $color   = 'red';
  } else {
  $color = 'green';
    $results = $green_header;
  }

  if ( $hour == 16 ) { $color = 'green' }
  if ( $hour == 17 ) { $color = 'green' }
  if ( $hour == 18 ) { $color = 'green' }
  if ( $hour == 19 ) { $color = 'green' }
  if ( $hour == 20 ) { $color = 'green' }
  if ( $hour == 21 ) { $color = 'green' }
  if ( $hour == 22 ) { $color = 'green' }
  if ( $hour == 23 ) { $color = 'green' }
  if ( $hour == 0 )  { $color = 'green' }
  if ( $hour == 1 )  { $color = 'green' }
  if ( $hour == 2 )  { $color = 'green' }
  if ( $hour == 3 )  { $color = 'green' }
  if ( $hour == 4 )  { $color = 'green' }
  if ( $hour == 5 )  { $color = 'green' }
  if ( $hour == 6 )  { $color = 'green' }
  if ( $hour == 7 )  { $color = 'green' }

  my $machine = "$filer,amkor,com";

  my $line    = "status $machine.$test $color $results";

  print "$line";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
}


