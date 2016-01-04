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

my @test_inputs = ("https://www.dropbox.com/s/8v2f2yt3w1h6fmy/chr1_both.in?dl=0","https://www.dropbox.com/s/jwlmd2e8ingp4fh/chr2_both.in?dl=0")

if($options{f}){
	foreach my $file (@test_inputs){
		my @command = ("wget","-0 ".$dir."/input/",$file);
		system(@command);
	}
}


my @test_annotations = ("https://www.dropbox.com/s/bhtk8wmxeueeis6/rn4.sqlite?dl=0");
if($options{a}){
	foreach my $file (@test_annotations){
		my @command = ("wget","-0 ".$dir."/annotations/",$file);
		system(@command);
	}
}