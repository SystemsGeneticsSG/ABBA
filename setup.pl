#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Std;

my %options=();
getopts("fad:", \%options);


my $dir;
unless(defined($options{d})){
	$dir = "";
}


try_load('Text::xSV');
try_load('SQL::Abstract');
try_load('DBI');
try_load('Data::Dumper');
try_load('File::Path');
try_load('File::Basename');
try_load('Getopt::Std');


mkdir $dir."images" unless -d $dir."images";
mkdir $dir."dbs" unless -d $dir."dbs";
mkdir $dir."data" unless -d $dir."data";
mkdir $dir."output" unless -d $dir."output";
mkdir $dir."tmp" unless -d $dir."tmp";
mkdir $dir."cluster" unless -d $dir."cluster";


my @test_inputs = (["https://www.dropbox.com/s/8v2f2yt3w1h6fmy/chr1_both.in?dl=1","ch1_both.in"],["https://www.dropbox.com/s/jwlmd2e8ingp4fh/chr2_both.in?dl=1","chr2_both.in"]["https://www.dropbox.com/s/8neq4v5w211d4g0/chr3_both.in?dl=1","ch3_both.in"],["https://www.dropbox.com/s/i8abvcuaqp83z5y/chr4_both.in?dl=1","ch4_both.in"],["https://www.dropbox.com/s/a4cg9d3yhyfzewc/chr5_both.in?dl=1","ch5_both.in"],["https://www.dropbox.com/s/7lpm14s9qnhjjsm/chr6_both.in?dl=1","ch6_both.in"],["https://www.dropbox.com/s/adw69lflo2u93ps/chr7_both.in?dl=1","ch7_both.in"],["https://www.dropbox.com/s/wtfvv7zjlaaydoe/chr8_both.in?dl=1","ch8_both.in"],["https://www.dropbox.com/s/43wb910d150ghj5/chr9_both.in?dl=1","ch9_both.in"],["https://www.dropbox.com/s/qukm8bt9vhtj2kn/chr10_both.in?dl=1","ch10_both.in"],["https://www.dropbox.com/s/e19xjenya3t49mc/chr11_both.in?dl=1","ch11_both.in"],["https://www.dropbox.com/s/azyqyjulpdtcrwv/chr12_both.in?dl=1","ch12_both.in"],["https://www.dropbox.com/s/l6md7xzsrzi37cj/chr13_both.in?dl=1","ch13_both.in"],["https://www.dropbox.com/s/yiuxooq2q7cwnxl/chr14_both.in?dl=1","ch14_both.in"],["https://www.dropbox.com/s/dhxqdhl0mhw6ea3/chr15_both.in?dl=1","ch15_both.in"],["https://www.dropbox.com/s/dy7gh728py62tb2/chr16_both.in?dl=1","ch16_both.in"],["https://www.dropbox.com/s/xsg5rj3we8mh2tr/chr17_both.in?dl=1","ch17_both.in"],["https://www.dropbox.com/s/99ox0hf8fjo6jqf/chr18_both.in?dl=1","ch18_both.in"],["https://www.dropbox.com/s/0t5zuh396wfmvko/chr19_both.in?dl=1","ch19_both.in"],["https://www.dropbox.com/s/b047xpqt6mjx0dj/chr20_both.in?dl=1","ch20_both.in"],["https://www.dropbox.com/s/pi88s4a4h2s9w48/chrX_both.in?dl=1","chx_both.in"]);


if($options{f}){
	mkdir $dir."input" unless -d $dir."input";
	foreach my $file (@test_inputs){
		my @file = @{$file};
		my @command = ("wget","--output-document=".$dir."input/$file[1]",$file[0]);
		system(@command);
	}
}


my @test_annotations = (["https://www.dropbox.com/s/bhtk8wmxeueeis6/rn4.sqlite?dl=1","rn4.sqlite"]);
if($options{a}){
	mkdir $dir."annotations" unless -d $dir."annotations";
	foreach my $file (@test_annotations){
		my @file = @{$file};
		my @command = ("wget","--output-document=".$dir."annotations/$file[1]",$file[0]);
		system(@command);
	}
}

sub try_load {
  my $mod = shift;

  eval("use $mod");

  if ($@) {
    #print "\$@ = $@\n";
    die "Error: $mod is not installed, try cpanm install $mod\n";
  } else {
    return(1);
  }
}
