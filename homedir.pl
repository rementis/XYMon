#!/usr/local/bin/perl -w
use strict;

############################################
#                                          #
# Check if home directory mount is working #
#                                          #
# Martin Colello 12/2015                   #
#                                          #
############################################

my $color    = 'green';
my $hostname = `hostname`;
chomp($hostname);
$hostname =~ s/\.amkor\.com//g;
my $machine  = "$hostname,amkor,com";
my $test     = 'homedir';
my $results  = "\n\nChecking if autofs is working properly.  Check /etc/auto_home\n\n";

if ( $hostname =~ /chazesb/    )   { exit }
if ( $hostname =~ /chaztmd/    )   { exit }
my $homedir = `su - mcole -c "hostname"`;
sleep 1;
my $df = `df`;

if ( $df =~ /home\/mcole/ ) {
  $color = 'green';
} else {
  $color = 'yellow';
}

if ( $hostname =~ /audrspma01/    )   { $color = 'green' }
if ( $hostname =~ /audrbpr01/     )   { $color = 'green' }
if ( $hostname =~ /audrerpp01/    )   { $color = 'green' }
if ( $hostname =~ /audesign01/    )   { $color = 'green' }
if ( $hostname =~ /auxgzp01/      )   { $color = 'green' }
if ( $hostname =~ /auxgzp02/      )   { $color = 'green' }
if ( $hostname =~ /phpaxpr02/     )   { $color = 'green' }
if ( $hostname =~ /aumonp01/      )   { $color = 'green' }
if ( $hostname =~ /ausplp01/      )   { $color = 'green' }
if ( $hostname =~ /ausplp02/      )   { $color = 'green' }
if ( $hostname =~ /ausplf01/      )   { $color = 'green' }
if ( $hostname =~ /autmdbp01/     )   { $color = 'green' }
if ( $hostname =~ /chazxplmapp01/ )   { $color = 'green' }
if ( $hostname =~ /chazxplmapp02/ )   { $color = 'green' }
if ( $hostname =~ /chazewbp01/    )   { $color = 'green' }
if ( $hostname =~ /chazewbp02/    )   { $color = 'green' }
if ( $hostname =~ /chazxmax01/    )   { $color = 'green' }
if ( $hostname =~ /chazxsapr01/   )   { $color = 'green' }
if ( $hostname =~ /chazxweb02/    )   { $color = 'green' }
if ( $hostname =~ /chazxwpgp01/   )   { $color = 'green' }
if ( $hostname =~ /chazxwpgp02/   )   { $color = 'green' }
if ( $hostname =~ /auhrsftp01/    )   { $color = 'green' }
if ( $hostname =~ /ausolaris01/   )   { $color = 'green' }
if ( $hostname =~ /auxhrsftp01/   )   { $color = 'green' }
if ( $hostname =~ /auhrsftp01/    )   { $color = 'green' }
if ( $hostname =~ /audrgzp01/     )   { $color = 'green' }

system("umount /home/mcole");

$results .= $df;
my $line = "status+25h $machine.$test $color $results";
print "$line\n";
# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
