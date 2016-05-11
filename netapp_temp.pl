#!/usr/local/bin/perl -w
use strict;

my @filers = qw ( phpadrnas01 chaznas03 chaznas06 );
my $uname = `uname -a`;
my $results;
my $test = 'ntemp';
my $green_header = "\nChassis temperature ok.\n\n\n";
my $color;

foreach( @filers ){

  my $filer = $_;
  my $output = `rsh $filer environment status chassis Temperature`;
  if ( $output !~ /Temperature ok/ ) {
    $results  = "$output \n\n\nCall Unix team!";
    $color   = 'red';
  } else {
  $color = 'green';
    $results = $green_header;
  }

  my $machine = "$filer,amkor,com";

  my $line    = "status $machine.$test $color $results";

  #print "$line";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
}


