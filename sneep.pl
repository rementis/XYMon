#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |    Check if sneep is installed     |
#     |                                    |
#     |           Martin Colello           |
#     |             07/31/2011             |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|


my $uname        = `uname -a`;
chomp(my $server = `/usr/bin/hostname`);
chomp(my $date   = `/usr/bin/date`);
my $test         = 'sneep';
my $color        = 'green'; # Set default status to green.
my $results      = "\n\n";
my $machine      = "$server,amkor,com";

if ( -e '/usr/sbin/sneep' ) {
  my $serial = `/usr/sbin/sneep`;
  $color = 'green';
  $results .= "SUNWsneep installed.\n\nSerial: $serial";
  system("echo \"$server: $serial\" > /usr/local/admin/scripts/hobbit/sneep/$server.sneep");
} else {
  $color = 'yellow';
  $results .= "Sneep package not installed.\n";
  my $serial = `cat /usr/local/admin/scripts/hobbit/sneep/$server.sneep`;
  $results .= "Serial: $serial";
}

my $check_vmware = `prtdiag | grep -i vmware`;
if ( $check_vmware =~ /VMware/ ) {
  $color = 'green';
  $results = "\n\nSystem is Vmware\n\n";
}

my $line    = "status+1h $machine.$test $color $results";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
