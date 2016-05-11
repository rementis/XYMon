#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |    Check for missing nfs mounts    |
#     |                                    |
#     |           Martin Colello           |
#     |             8/25/2008              |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

my $uname = `uname -a`;
my $tab = '/etc/vfstab';
my $server;
my $split_num = '2';
if ( $uname =~ /Linux/ ) {
  $tab = '/etc/fstab';
  $split_num = '1';
  chomp($server      = `hostname -s`);
} else {
  chomp($server      = `hostname`);
}
my $test    = 'mount';
my $color   = 'green';# Set default status to green.
my $machine = "$server,amkor,com";
my $results;
my @vfstab;
chomp(my $date        = `date`);

chomp(my $df = `df -k`);
chomp(my @file = `cat $tab`);

foreach( @file ) {
  my $line = $_;
  if ( $line =~ /^#/         ) { next }
  if ( $line =~ /^\s/        ) { next }
  if ( $line =~ /^fd/        ) { next }
  if ( $line =~ /swap/       ) { next }
  if ( $line =~ /sharefs/    ) { next }
  if ( $line =~ /^devpts/    ) { next }
  if ( $line =~ /\s\/boot\s/ ) { next }
  if ( $line =~ /^proc/      ) { next }
  if ( $line =~ /^sysfs/     ) { next }
  if ( $line =~ /^tmpfs/     ) { next }
  if ( $line =~ /^\/dev\//   ) { next }
  if ( $line =~ /devices/    ) { next }
  if ( $line =~ /ctfs/       ) { next }
  if ( $line =~ /^objfs/     ) { next }
  if ( $line =~ /^\/proc/    ) { next }
  if ( $line ) {push @vfstab, $line}
}
chomp(@vfstab);

foreach( @vfstab ) {
  my @split = split /\s+/, $_;
  if ( $df =~ /\s$split[$split_num]/ ) {
    next; 
  } else {
    $results = $results . "\nFilesystem not mounted:\n";
    $results = $results . "$split[0]\t$split[2]\n\n";
    $color = 'red';
  }
}

if ( $color =~ /green/ ) {
  $results = $results . "All mount points ok.\n\n";
  $results = $results . "\n\n$df\n\n";
}

my $line    = "status $machine.$test $color $results";
print "$line\n";
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
