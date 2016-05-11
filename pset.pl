#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |      Monitor pset on a local       |
#     |                zone.               |
#     |                                    |
#     |           Martin Colello           |
#     |              6/1/2009              |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my $uname = `uname -a`;
if ( $uname =~ /Linux/ ) {
  exit;
}
chomp(my $server      = `/usr/bin/hostname`);

chomp(my $date        = `/usr/bin/date`);
chomp(my @raw         = `/usr/bin/poolstat`);
my $test    = 'pset';
my $color   = 'green';# Set default status to green.
my $machine = "$server,amkor,com";
my $number  = "";
my $output;

foreach(@raw){
  my $line = $_;
  if ($line =~ /pset/) {next}
  if ($line =~ /size/) {next}
  my @line = split /\s+/, $line;
  $number = $line[3];
}

$output .= "\n\n";
$output .= "pset : $number\n\n";


my $line    = "status $machine.$test $color $output";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
