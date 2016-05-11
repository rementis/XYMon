#!/usr/local/bin/perl -w
use strict;

########################################
#                                      #
# Check capacity percentage per volume #
# and turn hobbit test red if over 89% #
#                                      #
# Martin Colello                       #
# 04/28/2011                           #
#                                      #
# MCOLE - Added ignore capability      #
# 03/02/2012                           #
#                                      #
# MCOLE - Changed sorting to list      #
# in order of percentage full          #
# 04/05/2012                           #
#                                      #
########################################

my $uname        = `uname`;
my $test         = 'capacity';
my @filers       = `cat /usr/local/admin/scripts/dashboard/globalfilers.work`;
my $ignore_list  = "These volumes ignored:\n";
$ignore_list    .= `cat /usr/local/admin/scripts/hobbit/nas_volume_ignore_list`;
$ignore_list     =~ s/#Add one volume per line to ignore//g;
chomp(@filers);

my @time_data = localtime(time);
my $hour      = $time_data[2];

my $results;
my $green_results;
my $color = 'green';

foreach( @filers ) {

  my @green_results;
  my $filer = $_;
  print "Working on $filer...\n";
  my $machine = "$filer,amkor,com";
  my @lines;

  if ( $filer =~ /asclst01|adrsclst01/ ) { 
    @lines = `ssh -o StrictHostKeyChecking=no -i /usr/local/admin/snapdot/.ssh/id_dsa -l snapdot $filer df -h | grep -v snap`;
  } else {
    @lines = `rsh $filer df -h | grep -v snap`;
  }

  chomp(@lines);

  foreach( @lines ) {
    my $line = $_;
    if ( $line =~ /Filesystem/ ) { next };
    $line =~ /^\/vol\/(\w+)\/\s+\w+\s+\w+\s+\w+\s+(\d+)/;
    my $volume  = $1;

    # Ignoring Simpana volumes as per KLOUX - 7/7/2014
    if ( $volume =~ /CVLib_UMA_P1_UMA_T/ ) { next }
    if ( $volume =~ /CVLib_WMA_P1_WMA_T/ ) { next }

    my $percent = $2;
    my $percentsign = "$percent"."%";
    $green_results = sprintf("\n%5s %-20s",$percentsign,$volume);
    push @green_results, $green_results;
      if ( $ignore_list =~ /$volume\s/ ) { 
        $color = 'yellow';
        next;
      }
      if ( ($hour == 0)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 1)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 2)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 3)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 4)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 5)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 6)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 7)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 8)  and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 9)  and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 10) and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 11) and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 12) and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 13) and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 14) and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 15) and ($percent > 88) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 16) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 17) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 18) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 19) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 20) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 21) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 22) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
      if ( ($hour == 23) and ($percent > 89) ) {$results .= "\n$volume\t"."$percent"."%"}
    }

  if ( $results ) { 
    $color = 'red';
  } else {
    $color = 'green' unless ( $color =~ /yellow/ );
    $green_results = "";
    if ( $color =~ /yellow/ ) {
      $green_results .= "\n$ignore_list\n\n";
    }
    @green_results = reverse sort(@green_results);
    chomp(@green_results);
    foreach(@green_results){
      $green_results .= "$_";
    }
    $results = "\n\nAll volumes ok.\n\n$green_results";
  }

  my $line    = "status $machine.$test $color $results";

  #print "$line\n";
  system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");

  $results       = '';
  $green_results = '';
  $color         = 'green';
}
