#!/usr/local/bin/perl
use strict;

chomp(my $server = `hostname`);
$server =~ s/\.amkor\.com//g;
my $color   = 'green';
my $machine = "$server,amkor,com";
my $test    = 'cm';
my $uname   = `uname -a`;

if ( $uname =~ /Linux/ ) {
  my $data = `free -g`;
  $data =~ /Mem:\s+(\d+)/;
  my $memory_size = $1;
  $memory_size = "$memory_size".'gb';
  
  $data = `cat /proc/cpuinfo | grep processor | wc`;
  $data =~ /\s+(\d+)/;
  my $cpu = $1;

  my $results = "\n\n";
  $results .= "Memory: $memory_size\n";
  $results .= "CPU:    $cpu\n";

  my $line = "status+25h $machine.$test $color $results";

  # Send to XYMon
  print "$line\n";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
  exit;
}

my $data = `prtconf 2> /dev/null`;

$data =~ /Memory size:\s(\d+)\s(\w+)/;

my $memory_size = "$1"." "."$2";

$data = `psrinfo -v`;

$data =~ /The\s(\w+)\sprocessor\soperates\sat\s(\d+)\s(\w+)/;

my $processor_type = "$1"." "."$2"." "."$3";

chomp(my $num_cpus = `psrinfo | wc -l`);

$num_cpus =~ s/\s//g;

chomp(my $physical = `psrinfo -p`);



#$results .= sprintf("\n%-20s %7s %7s \n", "Totals","$ora_total","$sap_total");

my $hw_type_file = "/usr/local/admin/scripts/local_zone_hw_type/$server";
my $hw_type;

if ( -e $hw_type_file ) {
  $hw_type = `cat /usr/local/admin/scripts/local_zone_hw_type/$server`;
} else {
  $hw_type = "\n";
}


my $results = sprintf("%-20s \n","Hardware Config");
$results .=   sprintf("%-20s %-7s \n","Memory Size:","$memory_size");
$results .=   sprintf("%-20s %-7s \n","Processor Type:","$processor_type");
$results .=   sprintf("%-20s %-7s \n","Number of cpus:","$physical");
$results .=   sprintf("%-20s %-7s \n","Number of cores:","$num_cpus");
$results .=   "\n\n";
$results .=   "$hw_type";

my $line = "status+25h $machine.$test $color $results";

# Send to XYMon
system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");


