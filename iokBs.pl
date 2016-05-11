#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |            I/O Latency             |
#     |                                    |
#     |           Martin Colello           |
#     |             2/06/2009              |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my $uname        = `uname -a`;
my $test         = 'iokBs';# additional test at end of script
my $color        = 'green';# Set default status to green.
chomp(my $server = `/usr/bin/hostname`);
my $machine      = "$server,amkor,com";
my $results;


chomp(my $date   = `/usr/bin/date`);

my @results = `iostat -dxn 3 3`;
my @data;
foreach(@results){

# chazerpp01
  if ($_ =~ /asvfasp0\d\-nfs:\/vol\/sapdata\d_prd/) {
    push @data, $_;
  }

#asvfasp01-nfs:/vol/sapdata1_prd/sapdata1/sapdata1
#                       5.0T   3.3T   1.7T    67%    /oracle/PRD/sapdata1

# chazdbp01
  if ($_ =~ /asvfasp04-nfs:\/vol\/oracle_prd_fin\/dbase\/u004/) {
    push @data, $_;
  }

# chazbidbp01
  if ($_ =~ /chaznas09:\/vol\/hyperion_prod\/essbase_prod/) {
    push @data, $_;
  }
# chazerpq01
  if ($_ =~ /chaznas03-st:\/vol\/sapdata_qas\/sapdata_qas/) {
    push @data, $_;
  }
# chazerpq02
  if ($_ =~ /chaznas06:\/vol\/sapdata_qa1\/sapdata_qa1/) {
    push @data, $_;
  }
# chazmdv01
  if ($_ =~ /chaznas04-st-54:\/vol\/sapdata_mdv\/sapdata_mdv/) {
    push @data, $_;
  }
# chazmqa01
  if ($_ =~ /chaznas03-st-54:\/vol\/sapdata_mqa\/sapdata_mqa/) {
    push @data, $_;
  }
# chazpqa01
  if ($_ =~ /chaznas03:\/vol\/sapdata_pqa\/sapdata_pqa/) {
    push @data, $_;
  }
# chazeqa01
  if ($_ =~ /chaznas03:\/vol\/sapdata_eqa\/sapdata1/) {
    push @data, $_;
  }
}

my @split = split /\s+/, $data[2];

my $kBs     = $split[3] + $split[4];
my $latency = $split[8];
my $actv    = $split[6];
 
#print "$split[0] $split[1] $split[2] $split[3] $split[4] $split[5] $split[6] $split[7] $split[8]\n";

$kBs     = int($kBs);
$latency = int($latency);
$actv    = int($actv);

#print "kBs is $kBs   latency is $latency    actv is $actv\n";

$results .= "\n";
$results .= "kBs:$kBs\n";
$results .= "latency:$latency\n";
$results .= "actv:$actv\n";

my $line    = "status $machine.$test $color $results";
print "$line\n";
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
#if ( $latency == 0 ) {
#  $color = 'yellow';
#}

$test="latency";
$line    = "status $machine.$test $color $results";
print "$line\n";
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
$color = 'green';

$test="actv"; 
$line    = "status $machine.$test $color $results"; 
print "$line\n";
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
