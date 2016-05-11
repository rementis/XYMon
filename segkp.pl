#!/usr/local/bin/perl -w
use strict;

#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
#     |                                    | 
#     |  Check memory stack for processes  |
#     |                                    |
#     |           Martin Colello           |
#     |             04/01/2016             |
#     |                                    | 
#     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

#root@augzp09 { / }
#> 1160 $ kstat -n segkp
#module: vmem                            instance: 300   
#name:   segkp                           class:    vmem
#        alloc                           20868
#        contains                        0
#        contains_search                 0
#        crtime                          155.523277822
#        fail                            138
#        free                            4514
#        lookup                          2170
#        mem_import                      0
#        mem_inuse                       2143133696
#        mem_total                       2147483648
#        populate_fail                   0
#        populate_wait                   0
#        search                          23645
#        snaptime                        1701247.67680326
#        vmem_source                     0
#        wait                            261911

chomp(my $server = `hostname`);
$server =~ s/\.amkor\.com//g;
if ( $server =~ /augzp09/ ) {
  $server = 'chazerpp01';
}
if ( $server =~ /augzp06/ ) {
  $server = 'chazbpr01';
}
chomp(my $date   = `date`);
my $test         = 'segkp';
my $color        = 'green'; # Set default status to green.
my $results      = "\n\n";
my $machine      = "$server,amkor,com";

my $raw_results = `/usr/bin/kstat -n segkp`;
$raw_results =~ /mem_inuse\s+(\d+)/;
my $mem_in_use = $1;
$raw_results =~ /mem_total\s+(\d+)/;
my $mem_total  = $1;

$results .= "Kernel page memory for process stack.\n(Measured from global zone)\n\n";
$results .= "MemInUse : $mem_in_use\n";
$results .= "MemTotal : $mem_total\n";
$results .= "\n\n";

my $line    = "status $machine.$test $color $results";
print "$line\n";

print "\n\n$raw_results\n";

# Send to hobbit
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");

