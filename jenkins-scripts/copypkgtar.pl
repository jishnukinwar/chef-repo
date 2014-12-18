#!/usr/bin/perl

use Modules::Util;

my $WORKSPACE = $ARGV[0];
my $JOB_NAME=$ARGV[1];
my $uploadtorepo=$ARGV[2];
my $pkgnm=$ARGV[3];
my $projectname=$ARGV[4];

if ($#ARGV < 4 )
{
    print "Error! Lessser input arguments entered!\n";
    exit(-1);
}

my $tarpath="$WORKSPACE/packages";
my $tarrepopath="/data/jenkins-finaltar/";

if($uploadtorepo =~ /yes/i)
{
 $pkgpath=$tarrepopath.$projectname."/".$JOB_NAME;
if(! -e $pkgpath)
{
	$cmd="mkdir -p $pkgpath";
 	($out,$stat)=&unixCommand($cmd);
	# print "$cmd,$out\n";
}
 $cmd="cp $WORKSPACE/packages/$pkgnm $pkgpath";
 ($out,$stat)=&unixCommand($cmd);
 print "$cmd,$out\n";
}

