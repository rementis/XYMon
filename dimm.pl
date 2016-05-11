#!/usr/local/bin/perl -w
use strict;

###########################################
#                                         #
# Check the dimm status                   #
#                                         #
# Martin Colello 11/2010                  #
#                                         #
###########################################

my $uname = `uname -a`;
my $color = 'green';
chomp(my $hostname = `hostname`);
my $machine = "$hostname,amkor,com";
my $test = 'dimm';
my %location;
my $results = "\n\nMemory DIMMs\n\n";
$results .= "\n";
my $switch = 'green';

if ( ! -e "/opt/HPQhealth/sbin/hpasmcli" ) { exit }

chomp(my @results = `/opt/HPQhealth/sbin/hpasmcli -s "show dimm"`);

foreach(@results) {
  my $line = $_;
  if ( $line =~ /Board/  ) { next }
  if ( $line =~ /DIMM/   ) { next }
  if ( $line =~ /---/    ) { next }
  if ( $line =~ /Proc/   ) { next }
  if ( $line =~ /Number/ ) { next }
  if ( $line =~ /Total/  ) { next }
  if ( $line =~ /^(\s)*$/) { next }

  if ($line =~ /Ok/) {
    $color = 'green';
  } else {
    $switch = 'red';
  }

  $results .= "$line\n";

}

if ( $switch eq 'red'){
  $color = 'red';
}
 

my $line = "status $machine.$test $color $results";
# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
