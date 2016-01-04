# ABBA
Aproximate Bayes for Bisulphite sequecing Analysis is perl program for analysis WGBS data. The program can be run locally or spread over a cluster using the qsub system. 

### Installation
To use ABBA you will are required to have Perl installed and the ability to install packages using CPAN or CPANM. In the situation where you do not have sudo access we recommend that you install PerlBrew and use CPANM to manage your perl libraries, for details see <http://perlbrew.pl> or follow the following instructions:
#### Step 1: Install PerlBrew (Optional)
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
There are number of perl libraries that are required, please install these as follows:
```sh
$ cpanm Text::xSV
$ cpanm SQL::Abstract
$ cpanm DBI

```

#### Step 3: Install SQLlite3
ABBA uses SQLite in order to store and process locations. It can be installed as follows:
```sh
sudo apt-get install sqlite3 libsqlite3-dev
```


```sh
$ git clone [git-repo-url] dillinger
$ cd dillinger
$ npm i -d
$ mkdir -p downloads/files/{md,html,pdf}
$ gulp build --prod
$ NODE_ENV=production node app
```

### Plugins

Dillinger is currently extended with the following plugins

* Dropbox
* Github
* Google Drive
* OneDrive

Readmes, how to use them in your own application can be found here:

* [plugins/dropbox/README.md] [PlDb]
* [plugins/github/README.md] [PlGh]
* [plugins/googledrive/README.md] [PlGd]
* [plugins/onedrive/README.md] [PlOd]

### Development

Want to contribute? Great!

Dillinger uses Gulp + Webpack for fast developing.
Make a change in your file and instantanously see your updates!

Open your favorite Terminal and run these commands.

First Tab:
```sh
$ node app
```

Second Tab:
```sh
$ gulp watch
```

(optional) Third:
```sh
$ karma start
```

### Docker, N|Solid and NGINX

More details coming soon.

#### docker-compose.yml

Change the path for the nginx conf mounting path to your full path, not mine!

### Todos

 - Write Tests
 - Rethink Github Save
 - Add Code Comments
 - Add Night Mode

License
----

MIT
