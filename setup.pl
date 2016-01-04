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



my @test_inputs = (["https://www.dropbox.com/s/8v2f2yt3w1h6fmy/chr1_both.in?dl=1","ch1_both.in"],["https://www.dropbox.com/s/jwlmd2e8ingp4fh/chr2_both.in?dl=1","chr2_both.in"]);

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
