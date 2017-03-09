#!/usr/bin/perl
my $project = $ARGV[0];
my $path = $ARGV[1];
my $filename = 'output/progress.html';
open FILE,">$path"."$filename";
use DBI;

my %progress = %{get_files_processed($project,$path)};

my %stages = %{get_stages_processed($project,$path)};

sub get_files_processed {
	my $project = shift;
	my $path = shift;
	my %progress;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	my $sth = $db_handle->prepare("select stage,max(counter) from file_ticker group by stage;");
	$sth->execute();
	 while (my @temp = $sth->fetchrow_array ) {
	 	$progress{$temp[0]}=$temp[1];
	 }
	 return(\%progress);
}

sub get_stages_processed {
	my $project = shift;
	my $path = shift;
	my %progress;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	my $sth = $db_handle->prepare("select * from progress");
	$sth->execute();
	 while (my @temp = $sth->fetchrow_array ) {
	 	$progress{$temp[0]}=$temp[1];
	 }
	 return(\%progress);
}

my $total_progress = int((scalar(keys %stages)/6)*100);

print FILE <<EOF;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <title>Progress | ABBA</title>
    <link href="../css/bootstrap.min.css" rel="stylesheet">
    <link href="../css/font-awesome.min.css" rel="stylesheet">
    <link href="../css/animate.min.css" rel="stylesheet"> 
    <link href="../css/lightbox.css" rel="stylesheet"> 
	<link href="../css/main.css" rel="stylesheet">
	<link href="../css/responsive.css" rel="stylesheet">

    <!--[if lt IE 9]>
	    <script src="../js/html5shiv.js"></script>
	    <script src="../js/respond.min.js"></script>
    <![endif]-->       
    </head><!--/head-->

<body>
	<header id="header">      
        <div class="container">
            <div class="row">
                <div class="col-sm-12 overflow">
                   <div class="social-icons pull-right">
                        <ul class="nav nav-pills">
                            <li><a href=""><i class="fa fa-twitter"></i></a></li>
                        </ul>
                    </div> 
                </div>
             </div>
        </div>
        <div class="navbar navbar-inverse" role="banner">
            <div class="container">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>

                    <a class="navbar-brand" href="index.html">
                    	<h1>$project IS RUNNING...</h1>
                    </a>
                    
                </div>
                <div class="collapse navbar-collapse">
                    <ul class="nav navbar-nav navbar-right">
                        <li class="active"><a href="index.html">Home</a></li>
                        <li><a href="README.html ">Installation</a></li>
                        <li><a href="README.html ">Running ABBA</a></li>
                        <li class="dropdown"><a href="#">Further Details <i class="fa fa-angle-down"></i></a>
                            <ul role="menu" class="sub-menu">
                                <li><a href="http://systemsgeneticssg.github.io/ABBA/">GitHub</a></li>
                                <li><a href="https://github.com/SystemsGeneticsSG/ABBA">Source Code</a></li>
                                <li><a href="http://systems-genetics.net/">Systems Genetics SG</a></li>
                            </ul>
                        </li>                                             
                                           
                    </ul>
                </div>
            </div>
        </div>
    </header>
    <!--/#header-->

    
   <section id="services">
        <div class="container">
            <div class="row">
            <h2>Overall algorithm progress:</h2>
                <div class="progress">

                    <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="$total_progress"aria-valuemin="0" aria-valuemax="100" style="width:$total_progress%">
                    
                    <span class="sr-only">$total_progress% Complete</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="container">
            <div class="row">
            <h3>Chromosome file processing progress:</h3>
EOF

foreach my $chr (keys %progress){
	my $val = int($progress{$chr}*100);
                print FILE '<div class="col-sm-1 text-center">';
                print FILE "<h3>$chr</h3>";
                    print FILE '<div class="progress">';
                       print FILE ' <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="70"aria-valuemin="0" aria-valuemax="100" style="width:';
                       print FILE "$val";
                       print FILE '%">';
                       print FILE ' <span class="sr-only">';
                       print FILE "$val"; 
                       print FILE 'Complete</span>';
                        print FILE '</div>';
                  print FILE '  </div>';
               print FILE ' </div>';
}
                
print FILE <<EOF;
            </div>
        </div>
    </section>
    <section id="services">
        <div class="container">
            <div class="row">
                <div class="col-sm-4 text-center padding">
                    <div class="single-service">
                        <div>
EOF
							if(exists($stages{1})){
                            	print FILE '<img src="images/home/icon1.png" alt="">';
                        	}else{
                        	 	print FILE '<img src="images/home/icon2.png" alt="">';	
                        	}
print FILE <<EOF;
                        </div>
                        <h2>Stage 1</h2>
                        <p>Check format.</p>
                    </div>
                </div>

                <div class="col-sm-4 text-center padding">
                    <div class="single-service">
                        <div>
EOF
							if(exists($stages{2})){
                            	print FILE '<img src="images/home/icon1.png" alt="">';
                        	}else{
                        	 	print FILE '<img src="images/home/icon2.png" alt="">';	
                        	}
print FILE <<EOF;
                        </div>
                        <h2>Stage 2</h2>
                        <p>Prepare files</p>
                    </div>
                </div>
                 <div class="col-sm-4 text-center padding">
                    <div class="single-service">
                        <div>
EOF
							if(exists($stages{3})){
                            	print FILE '<img src="images/home/icon1.png" alt="">';
                        	}else{
                        	 	print FILE '<img src="images/home/icon2.png" alt="">';	
                        	}
print FILE <<EOF;
                        </div>
                        <h2>Stage 3</h2>
                        <p>Run ABBA</p>
                    </div>
                </div>
                <div class="col-sm-4 text-center padding">
                    <div class="single-service">
                        <div>
EOF
							if(exists($stages{4})){
                            	print FILE '<img src="images/home/icon1.png" alt="">';
                        	}else{
                        	 	print FILE '<img src="images/home/icon2.png" alt="">';	
                        	}
print FILE <<EOF;
                        </div>
                        <h2>Stage 4</h2>
                        <p>Calculate FDR</p>
                    </div>
                </div>
                 <div class="col-sm-4 text-center padding" data-wow-duration="1000ms" data-wow-delay="600ms">
                    <div class="single-service">
                        <div>
EOF
							if(exists($stages{5})){
                            	print FILE '<img src="images/home/icon1.png" alt="">';
                        	}else{
                        	 	print FILE '<img src="images/home/icon2.png" alt="">';	
                        	}
print FILE <<EOF;
                        </div>
                        <h2>Stage 5</h2>
                        <p>Extract DMRs</p>
                    </div>
                </div>
                <div class="col-sm-4 text-center padding">
                    <div class="single-service">
                        <div>
EOF
							if(exists($stages{6})){
                            	print FILE '<img src="images/home/icon1.png" alt="">';
                        	}else{
                        	 	print FILE '<img src="images/home/icon2.png" alt="">';	
                        	}
print FILE <<EOF;
                        </div>
                        <h2>Stage 6</h2>
                        <p>Plot DMRs</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!--/#services-->

    <footer id="footer">
        
    </footer>
    <!--/#footer-->

    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/bootstrap.min.js"></script>
    <script type="text/javascript" src="js/lightbox.min.js"></script>
    <script type="text/javascript" src="js/wow.min.js"></script>
    <script type="text/javascript" src="js/main.js"></script>   
</body>
</html>

EOF

1;