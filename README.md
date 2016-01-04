# ABBA
Aproximate Bayes for Bisulphite sequecing Analysis is perl program for analysis WGBS data. The program can be run locally or spread over a cluster using the qsub system. 

### Installation
To use ABBA you will are required to have Perl installed and the ability to install packages using CPAN or CPANM. In the situation where you do not have sudo access we recommend that you install PerlBrew and use CPANM to manage your perl libraries, for details see <http://perlbrew.pl> or follow the following instructions. Please be aware that this may not be suitable for all situations, it is best to try with the system perl first and use this as a fall back.
#### Step 1: Install PerlBrew (Optional, only if your system perl is not usable)
First of all download the perlbrew files and execute them:
```sh
$ \curl -L http://install.perlbrew.pl | bash
```
Once it is installed follow the instructions to edit your .bash_profile and then install Perl using Perlbrew:

```sh
$ perlbrew install perl-5.16.0
```
This step will take some time to complete. Once it has you then need to install cpanm using perlbrew:

```sh
perlbrew install-cpanm
cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
```
#### Step 2: Install Required Perl Packages
There are number of perl libraries that are required, please install these from the command line as follows (alternatively you can use sudo cpan if your installation requires this):
```sh
$ cpanm Text::xSV
$ cpanm SQL::Abstract
$ cpanm DBI
$ cpanm Data::Dumper
$ cpanm File::Path
$ cpanm File::Basename
$ cpanm Getopt::Std
```

#### Step 3: Install SQLlite3
ABBA uses SQLite in order to store and process locations. It can be installed as follows:
```sh
sudo apt-get install sqlite3 libsqlite3-dev
```
#### Step 3: Install required R packages
ABBA uses R to perform much of the statisical analysis and plotting. In order to that the following libraries are required:
```R
install.packages("ggplot2")
install.packages("ggthemes")
install.packages("INLA", repos="http://www.math.ntnu.no/inla/R/stable")
```

### Development

Want to contribute? Great!

First off please contains @OwenRackham so you can be setup as a contributer to the package.

### Todos

 - Write Tests
 - Javascript DMR viewer
 - GO enrichment pipeline
 - Project name folder so that overwritting doesnt occur
 

License
----

MIT
