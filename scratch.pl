#!/usr/local/bin/perl
use strict;
use warnings;
use Sys::Hostname;

######################################
#                                    #
#  Check CommVault Scratch Tapes     #
#         Martin Colello             #
#           05/09/2013               #
#                                    #
######################################

system('/opt/simpana/Base/qlogin -u "xymon"  -ps "333ec1321d99ab44cb158305e338e7932"  -cs "awcvcc01.us.ds.amkor.com"');
my $scratch = `/opt/simpana/Base/qlist media -l "STK ACSLS 10" -srp "Default Scratch" | grep slot | wc -l`;
chomp($scratch);

# Get hostname and set some variables
my $hostname = hostname();
my $color    = 'green';
my $date     = `date`;
my $results  = "CommVault Scratch Tapes\n\n";
chomp($hostname);
chomp($date);

$hostname =~ s/\.amkor\.com//;

$results .= "scratch : $scratch\n";

if ( $scratch < 9 ) {
  $color = 'yellow';
} 
if ( $scratch < 6 ) {
  $color = 'red';
} 
#> 1203 $ cat /tmp/cv/*.csv | grep 'STK ACSLS' | grep Library
#STK ACSLS 10,STK ACSLS,STK ACSLS Library,12/10/2012 20:54:49,Default Scratch,ULTRIUM V3,1800/1800,8,101,0/19/119,0/68,Ready/ Enabled,"master, Help Desk Operations",N/A,1 Jobs / 0.000 GB,awcvma01** (P:IP B:-3 T:-3 L:0),#Mark Media Appendable#Use Appendable Media: within 14 day(s) of its last write time#Start New Media: When required media is exported#Start New Media: When required media is stuck in drive#Enable Auto-Discovery of media into default scratch pool#Verify access path using Serial Number for Drive#Check for cleaning media loaded in Drive#Check for Tape Alerts#Enable Auto-Recovery when media is stuck in drive#Attempt to remove media from the drive when unload the stuck media fails#Enable Auto-Cleaning: Wait 3 day(s) after last cleaning#Unmount Media from the drive after 20 Minutes of inactivity#Automatically update barcodes on firmware changes#Retry read operations on SCSI errors: [5] time(s) with a retry interval of [5] minute(s)#Automatically use spare media from different scratch pool if found in drive#Reset container when assigned media reappears in library#Reset export location when assigned media reappears in library#Do periodic mail slot check for any changes in status#Library status check interval 120 second(s),N/A,

system("rm /tmp/cv/*.csv");
sleep 3;
system("/usr/local/admin/scripts/hobbit/cv_slots.sh");
sleep 10;
my $slots = `cat /tmp/cv/*.csv | grep 'STK ACSLS' | grep Library`;

my @slots = split /,/, $slots;
chomp(@slots);
$slots = $slots[9];
#slots is 0/19/119
$slots =~ /\d+\/(\d+)/;
$slots = $1;
$results .= "slots : $slots\n";

# Send status to hobbit
&send_to_hobbit ( $color,$results );

exit;

sub send_to_hobbit {
  my $color     = shift;
  my $results   = shift;
  my $test      = 'scratch';
  my $machine   = "$hostname,amkor,com";
  my $line      = "status $machine.$test $color $results";
  print "line is: $line\n";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
}
