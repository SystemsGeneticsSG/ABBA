#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Std;
use File::Basename;
use File::Path qw(make_path);
use Data::Dumper;
use DBI;
use Text::xSV;
use SQL::Abstract;
#where are the input files
#USAGE perl ABBA.pl -f /media/localdata/rackham/WGBSdata/test_dir/ -s 3000 -m 50 -n 2 -r 4 -t 1 -c 1 -p ABBAtest -a rn4 -o /home/rackham/Documents/gdrive/workspace/WGBSsim/tmp/ -w 0 -d 0 -z 0 -y 0 -e length
my %options=();
getopts("hf:vs:m:n:r:t:c:p:a:o:w:d:z:y:e:i:x:b:g:j:k:", \%options);

if($options{v}){
	print "-f Analysising the files in $options{f}\n" if defined $options{f};
	print "-s split the data with the following $options{s} distance\n" if defined $options{f};
	print "-m require $options{m} CpGs in a file\n" if defined $options{f};
	print "-n there are $options{n} samples in the files\n" if defined $options{n};
	print "-r there are $options{r} replicates in the files\n" if defined $options{r};
	print "-t the min number of reads to be considered as reliable CpG is $options{t}\n" if defined $options{t};
	print "-c the min of reliable CpGs to be considered as reliable CpG is $options{c}\n" if defined $options{c};
	print "-p the project is $options{p}\n" if defined $options{p};
	print "-a the species is $options{a}\n" if defined $options{a};
	print "-o the outdir is $options{o}\n" if defined $options{o};
	print "-w the window size is $options{w}\n" if defined $options{w};
	print "-d the average difference is $options{d}\n" if defined $options{d};
	print "-z the sd is $options{z}\n" if defined $options{z};
	print "-y the cpgdensity is $options{y}\n" if defined $options{y};
	print "-e the type is $options{e}\n" if defined $options{e};
	print "-i the iniation point is $options{i}\n" if defined $options{i};
	print "-b the full path to the directory for this script when executed on a node is required if you are going to use the qsub option\n" if defined $options{b};
	print "-g the chromosome if running in qsub\n" if defined $options{g};
	print "-j the path to Rscript if you don't want to use the system version\n" if defined $options{g};
	print "-k the size of instance to request \n" if defined $options{k};
}
if ($options{h})
{
  do_help();
}
my $init = $options{i} || 0;
our $stage = 1;
our $path = $options{b} || "./";
our $rpath = $options{j} || "";
our $nodes = $options{k} || 8;
my $min = $options{m} || 50;
my $size = $options{s} || 3000;
my $thresh = $options{t} || 1;
my $min_count = $options{c} || 4;
my $dir = $options{f};
my $project = $options{p} ||  int(rand(1000));
mkdir "output/$project" unless -d "output/$project";
mkdir "data/$project" unless -d "data/$project";
my $species = $options{a} || 'rn4';
my $outdir = $options{o} || "output/$project/";
my $window = $options{w} || 1000;
my $average_diff = $options{d} || 0.33333;
my $sd = $options{z} || 2;
my $cpg_density = $options{y} || 0.01;
my $n = $options{n} || 2;
my $r = $options{r};
unless(defined($r)){
	die "Error: You must provide -r the number of repliacates in each sample\n";
}

my $type = $options{e} || 'length';

	unless(defined($project)){
		$project = 'ABBAtest';
	}
if($init eq 'qsub_executing'){
	run_all_files_chr($options{g},$project,$options{n},$options{r});
}else{
unless($init eq 'replot_dmrs'){
my %files_to_run;
unless($init eq 'qsub_recover'){
	create_database($project);
}
if($init eq 'qsub_recover'){
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	system("cat data/$project/*.for_inla > data/$project/all.forinla");
	system("sed -i '1s/^/chr,meth,total,a_start,b_start,id,group_id,start_loc,total2\\n/' data/$project/all.forinla");
	load_csv_to_database("data/$project/all.forinla",$db_handle,'raw_data');
	$db_handle->disconnect();
}

my $checked = check_directory($dir);
update_db($project,$stage,'files have been checked','progress');
$stage = $stage+1;
if($checked){
	%files_to_run = %{prepare_in_files($dir,$min,$size,\%files_to_run,$thresh,$min_count)};
	my $sum = 0;
	foreach my $chr (keys %files_to_run){
		$sum = $sum + scalar(@{$files_to_run{$chr}})
	}
	update_db($project,$stage,"There are $sum files to process",'progress');
	$stage = $stage + 1;
}

unless($init eq 'qsub_recover'){
	if($init eq 'qsub_setup'){
		#setup the qsub file
		foreach my $chr (keys %files_to_run){
				if(defined($path)){
				#my @command = ("qsub -pe smp 8","/gpfs/eplab/INLA/R/run_inla_alone.sh","/gpfs/eplab/INLA/ALL/".$chr."/".$size."/both/",$options{n},$options{r},"binomial",$options{x});
				#system(@command)
				my @command = ("qsub","-pe","smp","$nodes","-N",$chr, "-o","cluster/".$chr.".output", "-e","cluster/".$chr.".error","perl",$path."ABBA.pl","-i qsub_executing","-p $project","-n $n","-r $r","-g $chr","-j $rpath");
				system(@command);
				}else{
					die "Error: You must provide the full path to ABBA.pl if you want to use qsub\n";
				}
			
		}
		#print/run the qsub command to run and then exit
		exit;
	}else{
		run_inla_on_all_files(\%files_to_run,$n,$r,$project);
	}
}


run_fdr_on_combined_files($project);
}
#my @chrs = keys %files_to_run;
my @chrs = @{get_chrs($project)};
extract_DMRs(\@chrs,$project);
update_db($project,$stage,"DMRs has been extracted",'progress');
$stage = $stage + 1;
plot_DMRs($project,$species,$outdir,$window,$average_diff,$sd,$cpg_density,$type);
update_db($project,$stage,"DMRs have been plotted",'progress');
$stage = $stage + 1;
my @command = ('perl','results.pl',"$project","$path","$species","$average_diff","$sd","$cpg_density","$type");
system(@command);
my @command = ('sed','s/|/\t/g',"output/".$project."/top_hits.txt",">dmrs.bed");
system(@command);

}

sub update_db {
	my $project = shift;
	my $stage = shift;
	my $value = shift;
	my $table = shift;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	$db_handle -> do("INSERT INTO $table VALUES ('$stage','$value');");
	$db_handle->disconnect();
	update_progress_page($project,$path);
}

sub get_chrs {
	my $project = shift;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	my $sth = $db_handle->prepare("select distinct(stage) from file_ticker;");
	my @chrs;
	$sth->execute();
	 while (my @temp = $sth->fetchrow_array ) {
	 	push(@chrs,$temp[0]);
	 }
	 $db_handle->disconnect();
	 return(\@chrs);
}


sub plot_DMRs {
	my $project = shift;
	my $species = shift;
	my $outdir = shift;
	my $window = shift;
	my $average_diff = shift;
	my $sd = shift;
	my $cpg_density = shift;
	my $type = shift;
	#print STDERR ('sh','R/top_hits.sh',"$path"."dbs/"."$project".".sqlite","$species"."_annotation","$project","$outdir","$window","$path"."annotations/"."$species".".sqlite","$average_diff","$sd","$cpg_density","$type",$rpath);
	my @command = ('sh','R/top_hits.sh',"$path"."dbs/"."$project".".sqlite","$species"."_annotation","$project","$outdir","$window","$path"."annotations/"."$species".".sqlite","$average_diff","$sd","$cpg_density","$type",$rpath);
	system(@command);
	@command = ($rpath."Rscript","R/plot_fancy_figures.R","$outdir");
	system(@command);
}

sub get_files_to_process {
	my $project = shift;
	my $chr = shift;
	my @files;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	my $sth = $db_handle->prepare("select file from files_to_process where chr = '$chr';");
	$sth->execute();
	 while (my @temp = $sth->fetchrow_array ) {
	 	push(@files,$temp[0]);
	 }
	 $db_handle->disconnect();
	 return(\@files);
}

sub update_progress_page {
	my $project = shift;
	my $path = shift;
	my @command = ("perl",$path."progress.pl",$project,$path);
	system(@command);
}


sub load_csv_to_database {
	my $filename = shift;
	my $dbh = shift;
	my $table = shift;
	# setup csv file
	my $csv = new Text::xSV;
	$csv->open_file("$filename");
	$csv->read_header();
	my $sql = SQL::Abstract->new;
	$dbh->do('begin');
	my $max_commit  = 1000;
	my $inserted    = 0;
	# process csv rows
	while (my %fieldvals = $csv->fetchrow_hash) {

	    # SQL::Abstract sets up the DBI variables
	    my($stmt, @bind) = $sql->insert($table, \%fieldvals);

	    # insert the row
	    my $sth = $dbh->prepare($stmt);
	    $inserted += $sth->execute(@bind);

	    # commit every once in a while
	    unless ($inserted % $max_commit) {
	        $dbh->do('commit');
	        $dbh->do('begin');
	    }
	}

	$dbh->do('commit');
}
sub create_database {
	my $project = shift;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	$db_handle -> do("DROP TABLE IF EXISTS raw_data");
	$db_handle -> do("CREATE TABLE raw_data (chr CHAR(5), meth INT, total INT, a_start INT, b_start INT, id INT, group_id INT, start_loc INT, total2 INT);");
	$db_handle -> do("DROP TABLE IF EXISTS inla_smooth");
	$db_handle -> do("CREATE TABLE inla_smooth (chr CHAR(5), start_loc INT, diff FLOAT, a FLOAT, b FLOAT);");
	$db_handle -> do("CREATE INDEX `rawdata_chr_lk` ON `raw_data` (`chr` ASC);");
	$db_handle -> do("CREATE INDEX `rawdata_start_lk` ON `raw_data` (`start_loc` ASC);");
	$db_handle -> do("CREATE INDEX `inla_chr_lk` ON `inla_smooth` (`chr` ASC);");
	$db_handle -> do("CREATE INDEX `inla_start_lk` ON `inla_smooth` (`start_loc` ASC);");
	$db_handle -> do("DROP TABLE IF EXISTS DMR_data");
	$db_handle -> do("CREATE TABLE DMR_data (chr char(5),start_loc INT,stop_loc INT, size INT, density FLOAT, avg_diff FLOAT, type char(20), DMRlength INT, DMRCpGDensity FLOAT, sd FLOAT);");
	$db_handle -> do("CREATE INDEX `dmr_chr_lk` ON `DMR_data` (`chr` ASC);");
	$db_handle -> do("CREATE INDEX `dmr_start_lk` ON `DMR_data` (`start_loc` ASC);");
	$db_handle -> do("CREATE INDEX `dmr_stop_lk` ON `DMR_data` (`stop_loc` ASC);");
	$db_handle -> do("DROP TABLE IF EXISTS progress");
	$db_handle -> do("CREATE TABLE progress (stage tinytext, value tinytext);");
	$db_handle -> do("DROP TABLE IF EXISTS file_ticker");
	$db_handle -> do("CREATE TABLE file_ticker (stage TINYTEXT, counter INT);");
	$db_handle -> do("DROP TABLE IF EXISTS files_to_process");
	$db_handle -> do("CREATE TABLE files_to_process (chr TINYTEXT, file INT);");
	$db_handle->disconnect();
}

sub extract_DMRs {
	my $chrs = shift;
	my $project = shift;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	foreach my $chr (@{$chrs}){
		my @command=($rpath.'Rscript','R/extract.R',"data/$project/$chr.bed.sorted","$chr","data/$project/all.bed_fdr.RData");
  		system(@command);
  		if (-e "data/$project/$chr".".bed.sorteddensity.DMRs.bed"){
  		system("sed -i '1s/^/chr,start_loc,stop_loc,size,density,avg_diff,type,DMRlength,DMRCpGDensity,sd\\n/' data/$project/$chr".".bed.sorteddensity.DMRs.bed");
  		load_csv_to_database("data/$project/$chr".".bed.sorteddensity.DMRs.bed",$db_handle,'DMR_data');
  		}
  		if (-e "data/$project/$chr".".bed.sortedlength.DMRs.bed"){
  		system("sed -i '1s/^/chr,start_loc,stop_loc,size,density,avg_diff,type,DMRlength,DMRCpGDensity,sd\\n/' data/$project/$chr".".bed.sortedlength.DMRs.bed");
  		load_csv_to_database("data/$project/$chr".".bed.sortedlength.DMRs.bed",$db_handle,'DMR_data');
  		}
	}  
	$db_handle->disconnect();
}

sub run_fdr_on_combined_files {
	my $project = shift;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	system("cat data/$project/*.sorted > data/$project/all.bed");
	system("cat data/$project/*.for_inla > data/$project/all.for_sql");
	system("cut -d, -f1,2,5,8,9 data/$project/all.bed > data/$project/all.bed.for_sql");
	system("sed -i '1s/^/chr,start_loc,diff,a,b\\n/' data/$project/all.bed.for_sql");
	load_csv_to_database("data/$project/all.bed.for_sql",$db_handle,'inla_smooth');
	my @command = ($rpath."Rscript","R/run_FDR_indep.R","data/$project/all.bed");
	update_db($project,$stage,"FDR has been run",'progress');
	$stage = $stage + 1;
	system(@command);
	$db_handle->disconnect();
}

sub run_inla_on_all_files {
	my $files_to_run = shift;
	my %files_to_run = %{$files_to_run};
	my $n = shift;
	my $r = shift;
	my $project = shift;
	
	
	foreach my $chr (keys %files_to_run){
		run_all_files_chr($chr,$project,$n,$r);
	}
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	system("cat data/$project/*.for_inla > data/$project/all.forinla");
	system("sed -i '1s/^/chr,meth,total,a_start,b_start,id,group_id,start_loc,total2\\n/' data/$project/all.forinla");
	load_csv_to_database("data/$project/all.forinla",$db_handle,'raw_data');
	$db_handle->disconnect();
	update_db($project,$stage,"ABBA has been run",'progress');
	$stage = $stage + 1;
}

sub run_all_files_chr {
	my $chr = shift;
	my $project = shift;
	my $n = shift;
	my $r = shift;
	my $dir;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	my $count = 0;
	my $files_array = get_files_to_process($project,$chr);
	update_db($project,$chr,($count/scalar(@{$files_array})),'file_ticker');
	foreach my $file (@{$files_array}){
		
		print("$chr\t$file\n");
		my @command = ($rpath."Rscript","R/run_inla_alone.R","$file","$n","$r","binomial","> /dev/null");
		system(@command);
		if ( $? == -1 ){
  			print "command failed: $!\n";
		}else{
  			system("sed -i 1d $file"."binomial.bed");
  			system("sed -i 's/^/$chr,/g' $file"."binomial.bed");
  		}
  		$dir = dirname($file);
  		$count = $count + 1;
		update_db($project,$chr,($count/scalar(@{$files_array})),'file_ticker') if (($count % 10)==0);	
	}
	
	system("cat $dir/*binomial.bed > data/$project/$chr.bed");
	system("cat $dir/*for_inla.txt > data/$project/$chr.for_inla");
	system("sed -i 's/^/$chr,/g' data/$project/$chr.for_inla");
	system("sort -t, -g -k2 data/$project/$chr.bed > data/$project/$chr.bed.sorted");
	$db_handle->disconnect();
}

sub prepare_in_files {
	my $dir = shift;
	my $min = shift;
	my $size = shift;
	my $files_to_run = shift;
	my $threshold = shift;
	my $min_count = shift;
	my @files = glob "$dir*.in";
	my @directories_to_process;
	foreach my $file (@files) {
		my($filename, $dirs, $suffix) = basename($file,".in");
		my ($chr,$strand) = extract_file_details($filename);
		
		my $directory = $dir.$chr."/".$size."/".$strand;
		make_path($directory);
		my $files = split_data_for_INLA($file,$size,$directory,$chr,$min,$strand,$threshold,$min_count);
		$files_to_run->{$chr} = $files;
	}
	return($files_to_run);
}
 


sub extract_file_details {
  my $file = shift;
  my @data = split("_",$file);
  my $chr = $data[0];
  my $strand = $data[1];
  return($chr,$strand);


}

sub check_directory {
  my $dir = shift;
  if (-d $dir) {
    	# directory called dir exists
    	my @files = glob "$dir*.in";
    	if(scalar(@files)==0){
    		die "Error: $dir contains no .meth files\n";
    	}else{
    		foreach my $file (@files){
    			my $file_check = check_file($file);
    			if($file_check == 0){
    				die "Error: There is a problem with the file ".$dir."/".$file.". Please refer to help for formatting instructions\n";
    			}
    		}
    	}
	}
	elsif ($dir) {
		die "Error: $dir is not a directory\n";
    	#exists but is not a directory
	}
	else {
		die "Error: $dir is not a directory\n";
    	# nothing called exists
	}
	return(1)
}

sub check_file {
	my $file = shift;
	open THEFILE, "<$file";
	my $first_line = <THEFILE>;
	my @line = split("\t",$first_line);
	if(scalar(@line)<7){
    	die "Error: $file is not in the valid format\n";
    }
	close THEFILE;
	return(1)

}


sub split_data_for_INLA {
	my ($file,$size,$outdir,$chr,$min,$strand,$threshold,$min_count) = @_;
	open INFILE,$file;
	
	my $reg_block = 1;
	my $count = 0;
	my $prev;
	my @prev;
	my @files;
	my $filehandle = $outdir."/$reg_block".".in";
	open FILE,">$filehandle" or die;
	update_db($project,$chr,$filehandle,'files_to_process');
	push(@files,$filehandle);
	while(<INFILE>){

		unless($. == 1){
		chomp;
		my $data = $_;
		my @line = split('\t',$_);
		(my $cnt,my $l)=check_line(\@line,$threshold,'c');

			unless($cnt<$min_count){
				if(defined($prev)){
				if(($line[1]-$prev)<$size){
					$count = $count+1;
				}else{
					unless($count < $min){
						#unlink("$outdir"."$reg_block".".in")
					
					$count = 1;
				close FILE;
				$reg_block++;
				$filehandle = $outdir."/$reg_block".".in";
				open FILE,">$filehandle" or die;
				push(@files,$filehandle);
				update_db($project,$chr,$filehandle,'files_to_process');
					}
				}
				if($line[1]==$prev){
					for ($count = 5; $count >= scalar(@line); $count++) {
						unless(($line[$count]eq'NA') || ($prev[$count] eq 'NA')){
							print "prev\n";
							$prev[$count] = $line[$count]+$prev[$count];
						}
					}
				}else{
					#print STDERR join("\t",@prev)."\n";
					print FILE join("\t",@prev);
					print FILE "\n";
					@prev = @{$l};
					$prev = $line[1];
				}
				}else{
					@prev = @{$l};
					$prev = $line[1];
				}
			}
		}
	}
	return(\@files);
}

sub check_line {
    my ($line,$threshold,$type,$start) = @_;
    unless(defined($thresh)){
    	$thresh = 2;
    }
    unless(defined($type)){
    	$type = 'b';
    }
    unless(defined($start)){
    	$start = 5;
    }
    
    #1	chr10	2	0	0	0	0	0	0	0	0	0	2	0	0	0	2	0	0
    my @array = @{$line};
   	#@array = @array[ $start .. $#array ];
    my $i = $start;
    my $test = 0;
    while($i < (scalar(@array)-1)){
    	my $j = $i + 1;
    	if($type eq 'b'){
    	if(($array[$i]+$array[$j])>$threshold){
    		$test = $test + 1;
    	}
    	}elsif($type eq 'c'){
    	if(($array[$i])>$threshold){
    		$test = $test + 1;
    	}	
    	}
    	if($array[$i] == 0){
    		if(($array[$j] == 0)){
    			$array[$i] = 'NA';
    			$array[$j] = 'NA';
    		}
    	}
    	$i = $i+2
    }
    return($test,\@array);
}


sub do_help {
	print "##################################################################################\n\n";
  	print "Welcome to ABBA: Aproximate Bayes for whole-genome Bisiluphite sequencing Analysis\n\n";
  	print "##################################################################################\n\n";
  	print "please use the following command line options:\n\n";
  	print "\t-f\t is the directory containing the files to process. The format and names of these files is important please refer to the online help\n\n";
  	print "\t-s\t is the number of base pairs with which to split the data, ie a value of 3000 will split the data whenever a gap of at least 3000bp occurs between two CpGs.\n\n";
	print "\t-m\t is the number of CpGs required to be in a file, if a split occurs and the file has not reached this length then nothing will happen. It is essentially the minimum file size permitted.\n\n";
	print "\t-n\t is the number samples in the files, this should almost always be 2\n\n";
	print "\t-r\t is the number of replicates in the files. At present this number must be the same for each sample.\n\n";
	print "\t-t\t is the min number of reads to be considered as reliable CpG in a replicate.\n\n";
	print "\t-c\t is the min of reliable CpGs to be accross all samples to be considered as reliable CpG site for analysis.\n\n";
	print "\t-p\t is the project name\n\n";
	print "\t-a\t is the genome version of the species being analysed, eg rn4\n\n";
	print "\t-o\t is the output directory where the final images and bed files will be stored\n\n";
	print "\t-w\t is the window size to place around each DMR when plotting the results.\n\n";
	print "\t-d\t is the average difference of DMR to be considered.\n\n";
	print "\t-z\t is the number of sd the difference has to be from the mean to be considered a DMR.\n\n";
	print "\t-y\t is the cpgdensity required to be considered a DMR.\n\n";
	print "\t-e\t is the type of DMR to extract\n\n";
	print "\t-i\t is the iniation point for the program, this can be used to recover from a crash or to run using qsub, please see online instructions for details\n\n";
 	print "\t-j\t the full path to RScript which is required if you are going to use the qsub option\n\n";
	print "\t-b\t the full path to run_inla_alone.sh which is required if you are going to use the qsub option\n\n";
  exit
}





