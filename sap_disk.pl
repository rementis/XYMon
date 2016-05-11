#!/usr/local/bin/perl -w
use strict;

################################
#                              #
# bb script sap_disk           #
#                              #
# Check for sap filesystems    #
# usage percentage             #
#                              #
# Martin Colello               #
# 10/17/2005                    #
#                              #
################################

my $uname = `uname -a`;
if ( $uname =~ /Linux/ ) {
  exit;
}
my $data = '';
my $color = 'green';
my $test = 'sap_dsk';

# Get machine name
my $server = `uname -a`;
my @server = split / /, $server;
$server = $server[1];
my $machine = "$server,amkor,com";

# Get list of directories
my @files = `df -k | more`;

# Grep out only sap related mount points
my @ora_dirs;
foreach (@files) {
        if (/chaznas03/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ or /sapdata_qas /}
        if (/chaznas04/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ }
        if (/chaznas07/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ }
        if (/chaznas08/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ }
        if (/chaznas09/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ }
        if (/chaznas10/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ }
        if (/chaznas11/) { push @ora_dirs, $_ unless /shared/ or /unix_share/ or /unix_data/ }
                 }
# Get output of df -k
foreach (@ora_dirs) {
        my @dfk = split / /, $_;
        my $percent;
        foreach(@dfk) {
                if (/%/) {
                        s/%//g;# Remove the % sign
                        $percent = $_;
                                if ($percent > 96) {# Test to see if we hit 97.
                                        $color = 'red';# If so, color is red.
                                                    }
                        $data = $data . "$dfk[0] is at $percent percent.\n";# add line to $data
                         }
                      }
}#end of foreach(@ora_dirs)
        
my $date = `date`;
my $line = "status $machine.$test $color $date$data";# set line to deliver to bb

system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
