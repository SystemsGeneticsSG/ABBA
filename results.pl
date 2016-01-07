#!/usr/bin/perl
my $project = $ARGV[0] || 'ABBAtest';
my $path = $ARGV[1] || '';
#,$species,$outdir,$window,$average_diff,$sd,$cpg_density,$type
my $species = $ARGV[2] || 'rn4';
my $average_diff = $ARGV[3] || 0.3333;
my $sd = $ARGV[4] || 2;
my $cpg_density = $ARGV[5] || 0.01;
my $type = $ARGV[6] || 'length';
my $filename = "output/$project"."_results.html";
open FILE,">$path"."$filename";
use DBI;

my %dmrs = %{get_dmrs($project,$path)};


sub get_dmrs {
	my $project = shift;
	my $path = shift;
	my %dmrs;
	my $db_handle = DBI -> connect("DBI:SQLite:$path"."dbs/$project.sqlite");
	my $sth = $db_handle->prepare("select * from DMR_data where abs(avg_diff) > $average_diff and abs(avg_diff) > $sd*sd and type = '$type' and DMRCpGDensity > $cpg_density;");
	$sth->execute();
	 while (my @temp = $sth->fetchrow_array ) {
	 	$dmrs{$temp[0]."_".$temp[1]."_".$temp[2]}=\@temp;
	 }
	 return(\%dmrs);
}



print FILE <<EOF;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <title>Results | ABBA</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.10/css/jquery.dataTables.min.css">    <link href="../css/bootstrap.min.css" rel="stylesheet">
    <link href="../css/font-awesome.min.css" rel="stylesheet">
    <link href="../css/animate.min.css" rel="stylesheet"> 
    <link href="../css/lightbox.css" rel="stylesheet"> 
	<link href="../css/main.css" rel="stylesheet">
	<link href="../css/responsive.css" rel="stylesheet">
    

    <script src="../js/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="../js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../js/lightbox.js"></script>    
    <!--[if lt IE 9]>
	    <script src="js/html5shiv.js"></script>
	    <script src="js/respond.min.js"></script>
    <![endif]-->       
    </head><!--/head-->
    <script>
    \$(document).ready(function() {
    \$('#example').DataTable();
    });
    </script>
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
                    	<h1>$project IS COMPLETE...</h1>
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
            <h3>DMRs identified by ABBA:</h3>
            <table id="example" class="display" width="100%" cellspacing="0">
        <thead>
            <tr>
                <th>Chr</th>
                <th>Start</th>
                <th>End</th>
                <th>#CpGs</th>
                <th>Average Diff.</th>
                <th>Type</th>
                <th>Length</th>
                <th>CpG Density</th>
                <th>sd</th>
                <th></th>
            </tr>
        </thead>
        <tfoot>
            <tr>
                <th>Chr</th>
                <th>Start</th>
                <th>End</th>
                <th>#CpGs</th>
                <th>Average Diff.</th>
                <th>Type</th>
                <th>Length</th>
                <th>CpG Density</th>
                <th>sd</th>
                <th></th>
            </tr>
        </tfoot>
        <tbody>
            

EOF

foreach my $dmr (keys %dmrs){
print FILE <<EOF;
    <tr>
                <td>$dmrs{$dmr}->[0]</td>
                <td>$dmrs{$dmr}->[1]</td>
                <td>$dmrs{$dmr}->[2]</td>
                <td>$dmrs{$dmr}->[3]</td>
                <td>$dmrs{$dmr}->[5]</td>
                <td>$dmrs{$dmr}->[6]</td>
                <td>$dmrs{$dmr}->[7]</td>
                <td>$dmrs{$dmr}->[8]</td>
                <td>$dmrs{$dmr}->[9]</td>
                <td><a href="$project/$dmr.pdf.RDatafancy.png" data-lightbox="dmrs">View Image</a></td>
            </tr>
EOF
}
                
print FILE <<EOF;
</tbody>
    </table>

    
            </div>
        </div>
    </section>
    

    <footer id="footer">
        
    </footer>
    <!--/#footer-->



</body>
</html>

EOF

1;