#!/usr/local/bin/perl -w
use strict;
use Sys::Hostname;

###########################################
#                                         #
# Get number of hourly log switches       #
#                                         #
# Martin Colello 07/17/2015               # 
#                                         #
###########################################

my $hostname = hostname();
chomp($hostname);
my $color = 'green';
my $results = "\n";
my $machine = "$hostname,amkor,com";
my $test = 'logswitch';
my $number;

my @raw_output = `su - oraprd -c "/usr/local/admin/scripts/oracle/control_db.ksh log_switch"`;

foreach(@raw_output) {
  my $line = $_;
  if ( $line =~ /Sun/ ) { next };
  if ( $line =~ /\d/ ) { 
    $line =~ /(\d+)/;
    $number = $1;
  }
}

$results .= "number : $number\n";

my $line = "status $machine.$test $color $results";
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
