#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Std;

my %options=();
getopts("pfad:", \%options);


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
mkdir $dir."input" unless -d $dir."input";

my @test_inputs = (["https://www.dropbox.com/s/8v2f2yt3w1h6fmy/chr1_both.in?dl=1","chr1_both.in"],["https://www.dropbox.com/s/jwlmd2e8ingp4fh/chr2_both.in?dl=1","chr2_both.in"],["https://www.dropbox.com/s/8neq4v5w211d4g0/chr3_both.in?dl=1","chr3_both.in"],["https://www.dropbox.com/s/i8abvcuaqp83z5y/chr4_both.in?dl=1","chr4_both.in"],["https://www.dropbox.com/s/a4cg9d3yhyfzewc/chr5_both.in?dl=1","chr5_both.in"],["https://www.dropbox.com/s/7lpm14s9qnhjjsm/chr6_both.in?dl=1","chr6_both.in"],["https://www.dropbox.com/s/adw69lflo2u93ps/chr7_both.in?dl=1","chr7_both.in"],["https://www.dropbox.com/s/wtfvv7zjlaaydoe/chr8_both.in?dl=1","chr8_both.in"],["https://www.dropbox.com/s/43wb910d150ghj5/chr9_both.in?dl=1","chr9_both.in"],["https://www.dropbox.com/s/qukm8bt9vhtj2kn/chr10_both.in?dl=1","chr10_both.in"],["https://www.dropbox.com/s/e19xjenya3t49mc/chr11_both.in?dl=1","chr11_both.in"],["https://www.dropbox.com/s/azyqyjulpdtcrwv/chr12_both.in?dl=1","chr12_both.in"],["https://www.dropbox.com/s/l6md7xzsrzi37cj/chr13_both.in?dl=1","chr13_both.in"],["https://www.dropbox.com/s/yiuxooq2q7cwnxl/chr14_both.in?dl=1","chr14_both.in"],["https://www.dropbox.com/s/dhxqdhl0mhw6ea3/chr15_both.in?dl=1","chr15_both.in"],["https://www.dropbox.com/s/dy7gh728py62tb2/chr16_both.in?dl=1","chr16_both.in"],["https://www.dropbox.com/s/xsg5rj3we8mh2tr/chr17_both.in?dl=1","chr17_both.in"],["https://www.dropbox.com/s/99ox0hf8fjo6jqf/chr18_both.in?dl=1","chr18_both.in"],["https://www.dropbox.com/s/0t5zuh396wfmvko/chr19_both.in?dl=1","chr19_both.in"],["https://www.dropbox.com/s/b047xpqt6mjx0dj/chr20_both.in?dl=1","chr20_both.in"],["https://www.dropbox.com/s/pi88s4a4h2s9w48/chrX_both.in?dl=1","chrX_both.in"]);

my @paper_inputs = (["https://www.dropbox.com/s/9njlzztlsb5bsro/chr1.lambda.profile.corrected.CG?dl=0","chr1_both.in"],["https://www.dropbox.com/s/x6s2pxdu4xisav9/chr2.lambda.profile.corrected.CG?dl=0","chr2_both.in"],["https://www.dropbox.com/s/m4pjqxteizcu7cq/chr3.lambda.profile.corrected.CG?dl=0","chr3_both.in"],["https://www.dropbox.com/s/pjrtfo7b9qqanwf/chr4.lambda.profile.corrected.CG?dl=0","chr4_both.in"],["https://www.dropbox.com/s/45ad76wgx03hwow/chr5.lambda.profile.corrected.CG?dl=0","chr5_both.in"],["https://www.dropbox.com/s/gp3qgqpk0nhej2h/chr6.lambda.profile.corrected.CG?dl=0","chr6_both.in"],["https://www.dropbox.com/s/2ifx80lrf852cjd/chr7.lambda.profile.corrected.CG?dl=0","chr7_both.in"],["https://www.dropbox.com/s/o4ij868ar47h8jn/chr8.lambda.profile.corrected.CG?dl=0","chr8_both.in"],["https://www.dropbox.com/s/y3tpwucyddtcb6i/chr9.lambda.profile.corrected.CG?dl=0","chr9_both.in"],["https://www.dropbox.com/s/4t4lykb1xfajn78/chr10.lambda.profile.corrected.CG?dl=0","chr10_both.in"],["https://www.dropbox.com/s/dzi1z1hyhnzch2t/chr11.lambda.profile.corrected.CG?dl=0","chr11_both.in"],["https://www.dropbox.com/s/klqfwq8k9xcxibr/chr12.lambda.profile.corrected.CG?dl=0","chr12_both.in"],["https://www.dropbox.com/s/e53usaiq5ejv10m/chr13.lambda.profile.corrected.CG?dl=0","chr13_both.in"],["https://www.dropbox.com/s/dcg2m2er1vpgu4a/chr14.lambda.profile.corrected.CG?dl=0","chr14_both.in"],["https://www.dropbox.com/s/f2tmv8ru95vw6kz/chr15.lambda.profile.corrected.CG?dl=0","chr15_both.in"],["https://www.dropbox.com/s/4dxa6kowq5djq9p/chr16.lambda.profile.corrected.CG?dl=0","chr16_both.in"],["https://www.dropbox.com/s/mcj207bj0eq54pg/chr17.lambda.profile.corrected.CG?dl=0","chr17_both.in"],["https://www.dropbox.com/s/5ne59sfzmjfig3j/chr18.lambda.profile.corrected.CG?dl=0","chr18_both.in"],["https://www.dropbox.com/s/ls0k87o1zzsva3t/chr19.lambda.profile.corrected.CG?dl=0","chr19_both.in"],["https://www.dropbox.com/s/ucabhpenv0c99qh/chr20.lambda.profile.corrected.CG?dl=0","chr20_both.in"],["https://www.dropbox.com/s/pahc9nv7nfccu57/chrX.lambda.profile.corrected.CG?dl=0","chrX_both.in"]);


if($options{p}){
	mkdir $dir."input/rackham_et_al" unless -d $dir."input/rackham_et_al";
	foreach my $file (@paper_inputs){
		my @file = @{$file};
		my @command = ("wget","--output-document=".$dir."input/rackham_et_al/$file[1]",$file[0]);
		system(@command);
	}
}

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
