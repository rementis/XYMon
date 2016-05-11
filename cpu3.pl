#!/usr/local/bin/perl -w
use strict;

###########################################
#                                         #
# Make sure all cpu's are online          #
#                                         #
# Martin Colello 10/2007                  #
#                                         #
# Added support for linux - MCOLE 12/2011 #
#                                         #
###########################################

my $uname = `uname -a`;
my $command;
my $command2;
my @results3;
my $results;
my $hostname;
if ( $uname =~ /Linux/ ) { 
  chomp($hostname = `hostname -s`);
  my $checkme = '/usr/sbin/x86info'; 
  exit unless ( -e $checkme );
  $command  = '/usr/sbin/x86info -a | head -30';
  $command2 = '/usr/sbin/x86info -a';
  @results3 = `$command2`;
} else {
  chomp($hostname = `hostname`);
  $command  = '/usr/sbin/psrinfo';
}
chomp(my @results = `$command`);
my $numbercpus = @results;
my @results2 = `$command`;
my $color = 'green';
#chomp(my $hostname = `hostname`);
my $machine = "$hostname,amkor,com";
my $test = 'cpu3';
if ( $uname =~ /Linux/ ) { 
  $results = "\n\nAll cpu's are online.\n\n@results3";
} else {
  $results = "\n\nAll cpu's are online.\n\n@results2";
}

if ( $uname !~ /Linux/ ) {
  my @state;

  foreach(@results) {
      push @state, $_;
  }

  chomp(@state);

  foreach(@state) {
    if ( $_ !~ /on-line/ ) {
      $color = 'red';
      $results = "\n\nCPU or core is not online, please alert Unix team.\n\n@results2";
    }
  }
} else {
  my @state;
  foreach ( @results ) {
    my $line = $_;
    if ( $line =~ /^#\s+\d\s+\w+\s+/ ) {
      push @state, $line;
    }
  }
  foreach ( @state ) {
    my $line = $_;
    if ( $line !~ /usable/ ) {
      $color = 'red';
      $results = "\n\nCPU or core is not online, please alert Unix team.\n\n@results2";
    }
  }
}
my $saptag = '/saptag';  
if ( ($numbercpus < 2) and (-e $saptag) ) {
  $color = 'yellow';
}
my $line = "status $machine.$test $color $results";
$line = substr($line,0,10000);

print "$line\n";

system("echo \"$line\" | /usr/local/admin/scripts/hobbit/send_to_hobbit.ksh");
