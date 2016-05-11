#!/usr/local/bin/perl -w
use strict;
use Sys::Hostname;

###############################################
#                                             #
# Check for data load calc times              #
#                                             #
# Martin Colello                              #
# 08/08/2012                                  #
#                                             #
###############################################

chomp(my $server       = hostname());
chomp(my $gl           = `cat /opt/Hyperion/data/planning/SapPBU/logs/SapPBU_GL_load.log | grep SapAggGL.csc`);
chomp(my $skf          = `cat /opt/Hyperion/data/planning/SapPBU/logs/SapPBU_SKF_load.log | grep SapAggST.csc`);
chomp(my $date         = `date`);
my $color              = 'green';        # Set default status to green.
my $test               = 'load';
my $results            = "\n\n";
$results              .= "Calc Times\n\n";
$gl =~ /\[(\d+\.\d+)\]/;
$gl = $1;
$skf =~ /\[(\d+\.\d+)\]/;
$skf = $1;

$results .= "gl : $gl\n";
$results .= "skf : $skf\n";
$results .= "\n\n"; 


my $machine = "$server,amkor,com";
my $line    = "status $machine.$test $color $results";

#print "$line\n";

system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
