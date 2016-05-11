#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |       Check for zone mem usage     |
#     |                                    |
#     |           Martin Colello           |
#     |             1/14/2010              |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my $uname        = `uname -a`;
if ( $uname =~ /Linux/ ) {
  exit;
}
my $test         = 'zmem';
my $color        = 'green';# Set default status to green.
chomp(my $server = `/usr/bin/hostname`);
chomp(my $date   = `/usr/bin/date`);
my @work;

chomp(my @output = `/usr/bin/prstat -n 1,30 -Z 1 1`);

# Remove first 3 lines from array
splice(@output,0,3);

foreach(@output){
  my $line = $_;
  if ( $line =~ /%/ ) {
    push @work, $line;
  }
}
foreach(@work){
  #print "$_\n";
  my @split = split (' ',$_);
  #foreach(@split){print "$_ "}
  my $percentage = $split[4];
  my $zone       = "$split[7],amkor,com";
  $zone =~ s/global/$server/g;
  $percentage =~ s/\%//g;

  #Numbers less than one make the graphs ugly 
  if ( $percentage < 1 ) {
    $percentage = 1;
  } 

  my $results = "Zone Memory Percentage\nzmem : $percentage\n";

  my $line    = "status $zone.$test $color $results";

  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
}

