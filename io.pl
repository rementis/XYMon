#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |            I/O Latency             |
#     |                                    |
#     |           Martin Colello           |
#     |             2/06/2009              |
#     |                                    | 
#     |          MCOLE 01/27/2015          | 
#     |     Separate out kbs read/write    | 
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my $uname        = `uname -a`;
my $test         = 'IO';                  # additional test at end of script
my $color        = 'green';               # Set default status to green.
my $colorLAT     = 'green';               # Set default status to green.
chomp(my $server = `/usr/bin/hostname`);
my $machine      = "$server,amkor,com";
my $results = "\n";
my $results2 = "\n";
my @send_results;
my @send_results2;
my $number = "1";


chomp(my $date   = `/usr/bin/date`);

my @results = `iostat -dxn 3 3`;
my @data;
foreach(@results){

# chazerpp01
  if ($_ =~ /asvfasp0\d\-nfs:\/vol\/sapdata\d_\w\w\w\/sapdata/) {
    push @data, $_;
  }
}
exit unless ( @data );# If not data, exit script
my @data2;

$data2[0] = pop(@data);
$data2[1] = pop(@data);
$data2[2] = pop(@data);
$data2[3] = pop(@data);

@data2 = sort(@data2) unless ( $#data2 < 2 );

#print "data2 is @data2\n";

foreach(@data2){

  /sapdata(\d)/;
  $number = $1;
  my @split = split /\s+/, $_;

#  print "$split[0] $split[1] $split[2] $split[3] $split[4] $split[5] $split[6] $split[7] $split[8] \n";

  my $read    = $split[3];
  my $write   = $split[4];
  my $kbs     = $split[3] + $split[4];
  my $latency = $split[8];
 
  $kbs     = int($kbs);
  #$latency = int($latency);

  if ( $latency > 40 ) {
    $colorLAT = 'red';
  }

  push @send_results, "read"."$number".":$read\n";
  push @send_results, "write"."$number".":$write\n";
  push @send_results, "kbs"."$number".":$kbs\n";
  push @send_results2, "latency"."$number".":$latency\n";

  $number++;
}

@send_results = sort(@send_results);
foreach(@send_results){
  $results .= "$_";
}
@send_results2 = sort(@send_results2);
foreach(@send_results2){
  $results2 .= "$_";
}

my $line    = "status $machine.$test $color $results";
#print "$line\n";

$test = 'latency1';
my $line2   = "status $machine.$test $colorLAT $results2";
#print "$line2\n";

system("echo \"$line\"  | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
system("echo \"$line2\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
