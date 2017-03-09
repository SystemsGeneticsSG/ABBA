#!/usr/bin/perl
use warnings;
use strict;

open FILE,$ARGV[0];
my $prev;
while(<FILE>){
	my @line = split("\t",$_);
	if($. == 1){
		$prev = $line[1];
		print $_;
		}else{
		my $current = $line[1];
		unless(($current - $prev) <= 1){
			print $_;
		}
		$prev = $current;
		}
}