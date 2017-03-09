#!/usr/bin/perl
use warnings;
use strict;
open FILE,$ARGV[0];
my %file;
while(<FILE>){
	chomp;
	my @line = split("\t",$_);
	if(exists($file{$line[1]}{$line[0]."\t".$line[1]."\t".$line[2]."\t".'b'})){
		my @b = @line[4..$#line];
		my @a = @{$file{$line[1]}{$line[0]."\t".$line[1]."\t".$line[2]."\t".'b'}};
		my @c;
		$c[@c] = $a[@c] + $b[@c] while defined $a[@c] or defined $b[@c];
		$file{$line[1]}{$line[0]."\t".$line[1]."\t".$line[2]."\t".'b'} = \@c;
	}else{
		my @b = @line[4..$#line];
		$file{$line[1]}{$line[0]."\t".$line[1]."\t".$line[2]."\t".'b'} = \@b;
	}
}

foreach my $s (sort { $a <=> $b } keys %file){
foreach my $chr (keys %{$file{$s}}){
	print $chr."\t".join("\t",@{$file{$s}{$chr}})."\n";
}
}