#!/usr/local/bin/perl
use strict;
use warnings;

############################
#                          #
# Run standard xymon tests #
#     Martin Colello       #
#       07/25/2013         #
#                          #
############################

$ENV{'PATH'}='/usr/local/bin:/usr/bin:/usr/sbin:/usr/local/sbin:/bin:/sbin';

my $hostname = `hostname`;

# Determine what we are
my $whatami = ' ';
my $uname   = `uname -a`;
if ( $uname =~ /SunOS/ ) {
  $whatami .= 'solaris';
  my $zoneadm = `/usr/sbin/zoneadm list -cv`;
  if ( $zoneadm =~ /global/ ) {
    $whatami .= ' global_zone';
  }
}
if ( $uname =~ /Linux/ ) {
  $whatami .= ' Linux';
}

print "\nWill run with flags: $whatami\n\n";

# cd to proper directory
my $xymon_dir = '/usr/local/admin/scripts/hobbit';
chdir("$xymon_dir") or die "Cannot cd to $xymon_dir: $!";

# Create array of tests
my @tests = qw /
cpu2.pl
pblock.pl
cpu3.pl
df.pl
bkupchk.pl
mount.pl
ipmp.pl
mirror2.pl
inomem.pl
inomem2.pl
saptag.pl
sapalert.pl
dnfs.pl
svcs.pl
ntp.pl
systag.pl
/;

# Add to array of tests if we are a Solaris global zone
# gzmem.pl
if ( $whatami =~ /global_zone/ ) { 
  my @solaris_global_zone_tests = qw /
  nb.pl
  zmem.pl
  zfs.pl
  zfsmem.pl
  temp.pl
  dimm.pl
  raid.pl
  oralic.pl
  emccr.pl
  sneep.pl
  mtu.pl
  pset.pl
  memstat.ksh
  aggr.pl
  zonecpu.pl
  hba.ksh
  highPid.pl  
  segkp.pl
/;
  foreach(@solaris_global_zone_tests){
    push @tests, $_;
  }
}
                              
# Add to array of tests if we are a Linux server
if ( $whatami =~ /Linux/ ) { 
  my @linux_tests = qw /
  nb.pl
  oralic_linux.pl
  mtu.pl
  vmwaretools.pl
/;
  foreach(@linux_tests){
    push @tests, $_;
  }
}

# Add temp test to PRD servers

if ( $hostname =~ /chazerpp01|chazerpap0|chazerpap11/ ) {
  push @tests, 'CXPping.pl';
}

# Get list of currently running processes
my $process_list;
if ( $whatami =~ /global_zone/ ) {
  $process_list = `ps -efZ | grep global`;
} else {
  $process_list = `ps -ef`;
}

# Run each test if it's not already running
foreach( @tests ) {
  my $test = $_;
  if ( $process_list =~ /$test/ ) {
    print "$test already running, will skip...\n";
    next;
  }
  my $command = './'."$test".' >/dev/null 2>&1 &';
  print "Kicking off $test...\n";
  system("$command");
}

