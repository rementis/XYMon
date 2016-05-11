#!/usr/local/bin/perl -w
use strict;

###########################################
#                                         #
# Check the temperature status            #
#                                         #
# Martin Colello 11/2010                  #
#                                         #
###########################################

my $uname = `uname -a`;
my $color = 'green';
chomp(my $hostname = `hostname`);
my $machine = "$hostname,amkor,com";
my $test = 'raid';
my %location;
my $results = "\n\n";
my $result;
my $switch = 'green';
$results .= "\n";

if ( ! -e "/opt/HPQacucli/sbin/hpacucli" ) { exit }

chomp(my @results = `/opt/HPQacucli/sbin/hpacucli ctrl all show config`);

foreach(@results){
  my $line = $_;
  if ( $line =~ /^(\s)*$/) { next }
  if ( $line =~ /logicaldrive/ ) {
  $results .= "$line\n\n";
    if ( $line !~ /OK/ ) {
      $switch = 'red';
    } 
  }
  if ( $line =~ /physicaldrive/ ) {
  $results .= "$line\n";
    if ( $line !~ /OK/ ) {
      $switch = 'red';
    } 
  }
}

if ( $switch eq 'red'){
  $color = 'red';
}

my $line = "status $machine.$test $color $results";

#print "$line\n";
# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
