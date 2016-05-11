#!/usr/local/bin/perl -w
use strict;

# Get CPU stats and send to hobbit
# Martin Colello
# 5/5/2011

my @filers = qw /asfasp01 asfasp02 asfasd01 asfasd02 chazxnas01/;

foreach(@filers) {
  my $filer = $_;
  print "$filer...\n";
  my @results = `rsh $filer sysstat -c 1 -x 1`;

  foreach(@results) {
    my $line = $_;
    if ($line =~ /CPU/) {next}
    if ($line =~ /in/)  {next}
    my @split = split /\s+/, $line;  
    my $cpu   = $split[1];
    my $disk  = $split[16];
    $cpu      =~ s/%//g; 
    $disk     =~ s/%//g; 
 
    if ( $cpu  > 99 ) { $cpu  = 100 }
    if ( $disk > 99 ) { $disk = 100 }

    send_to_hobbit($filer,$cpu,$disk);
  }
}

sub send_to_hobbit {

  my $filer      = $_[0];
  my $cpu        = $_[1];
  my $disk       = $_[2];

  my $results    = "\ncpu  : $cpu\n";
  $results      .= "disk : $disk\n";

  my $color      = "green\n\n";
  my $machine    = "$filer,amkor,com";
  my $test       = 'fcpu';

  my $line       = "status $machine.$test $color $results";
  print "$line\n";

  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");

}
