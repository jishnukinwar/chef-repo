#!/usr/bin/perl
#

#use diagnostics -verbose;

use Modules::Constants;
use DBI;
use DBD::mysql;
use Data::Dumper;

my $WORKSPACE = $ARGV[0];
my $project_nm= $ARGV[1];
my $srcmodulename=$ARGV[2];
my $ticketno=$ARGV[3];
my $proddeliverable=$ARGV[4];
my $BUILD_ID=$ARGV[5];
print "BUILD_ID-$BUILD_ID\n";


my $rel_db ="REL";
my $reldbhost ="192.168.33.71";
my $reluser ="reluser";
my $relpassword ="rel\@567";chomp($relpassword);


my $datetmp=`date +%Y%m%d%S`;chomp($datetmp);
my $tmpbuilddir="/tmp/".$datetmp;
my $tarpath="$WORKSPACE/packages";
my $tarrepopath="/data/jenkins-finaltar";

chdir($tarpath);
my @files = glob("*.tar.gz");

$rel_dsn = "dbi:mysql:$rel_db:$reldbhost:3306";chomp $rel_dsn;
$rel_dbh = DBI->connect($rel_dsn,$reluser,$relpassword)  or die "Connection Error: $DBI::errstr\n";

$query="select livepath from enviornment_details where project_nm like '$project_nm'";
print  "$query\n";
 	$sth = $rel_dbh->prepare("$query")  or die "Can't prepare SQL statement: $DBI::errstr\n";
  	$sth->execute     or die "Can't execute SQL statement: $DBI::errstr\n";
	 my $livepath = $sth->fetchrow_array();

$query="select livecontext_nm from enviornment_details where project_nm like '$project_nm'";
print  "$query\n";
 	$sth = $rel_dbh->prepare("$query")  or die "Can't prepare SQL statement: $DBI::errstr\n";
  	$sth->execute     or die "Can't execute SQL statement: $DBI::errstr\n";
	 my $livecontextname = $sth->fetchrow_array();
	#$rel_dbh->disconnect        or warn "Error disconnecting: $DBI::errstr\n";

my $pkgnm="CCR_"."$ticketno"."-"."$livecontextname"."Build".".tar.gz";
foreach $file ( grep {-e} @files ) 
{
    $cmd="echo '$file' |  awk -F'Build' '{print \$2}' | awk -F'.tar' '{print \$1}'";
    ($newout,$stat)=&unixCommand($cmd);
  push(@buildnos,$newout);
}
@sortno=sort {$a <=> $b} @buildnos;
$len=$#sortno;
        $newbuildno=$sortno[$len]+1;
     $pkgnm="CCR_"."$ticketno"."-"."$livecontextname"."Build"."$newbuildno".".tar.gz";

print "Create tmp env\n";
$cmd="mkdir -p $tmpbuilddir/$livepath";
print "$cmd\n";
($out,$stat)=&unixCommand($cmd);

print "Copying the code to tmp dir\n";
$cmd="cp -r $WORKSPACE/$srcmodulename/target/*$proddeliverable  $tmpbuilddir/$livepath";
print "$cmd\n";
($out,$stat)=&unixCommand($cmd);

print "Change dir -$tmpbuilddir\n";
chdir($tmpbuilddir);
print "Create Tar-$tmpbuilddir\n";
$cmd="tar zcvf $tmpbuilddir/$pkgnm `find $livepath -type f | tr '[\\n]' '[ ]'`";
($out,$stat)=&unixCommand($cmd);
print "$cmd\n";

$cmd="mkdir -p $tarpath";
($out,$stat)=&unixCommand($cmd);
print "$cmd\n";

$cmd="cp $tmpbuilddir/$pkgnm   $tarpath";
($out,$stat)=&unixCommand($cmd);
print "$cmd\n";

$cmd="mkdir -p $WORKSPACE/$BUILD_ID";
($out,$stat)=&unixCommand($cmd);
print "$cmd\n";

$cmd="cp $tmpbuilddir/$pkgnm   $WORKSPACE/$BUILD_ID";
($out,$stat)=&unixCommand($cmd);
print "$cmd\n";

sub unixCommand
{                                        #unixCommand subroutine
  local($cmd,$dieOnError,$reverse) = @_;
  local($out,$status,$erMessage);
  print STDERR "\nunixCommand:in : $dieOnError,$cmd\n" if ($debug);
  chop($out = `$cmd 2>&1`);
  $status = $? >> 8;
  if ($reverse) {
    if ($status) {
        $status = 0;
       } else {
      $status = 1;
             }
        }
   if ($dieOnError eq '1') {
         $erMessage = $out;
     } else {
   $erMessage = "$dieOnError";
     }
    die "$erMessage (exit=$status)" if (($status) && ($dieOnError));
   print STDERR "unixCommand:out:$out,$status\n" if ($debug);
   ($out,$status);
}
