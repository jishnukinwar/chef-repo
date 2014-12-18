#!/usr/bin/perl

#rsync -a -v  -e ssh kapila.narang@192.168.27.128:/git/search searchi

@list=qw(dam-api-search-reports dam-batch-1.0 dam-build-1.0 dam-bulkingestion-1.0  dam-documentation-1.0 dam-feedingestion-1.0 DAM-html dam-imageprocessing-1.0 dam-search-1.0 dam-test);

foreach $module (@list)
{
$cmd="git clone --mirror ssh://192.168.27.128/git/search/dam/".$module.".git";
($out,$stat)=&unixCommand($cmd);
print "$cmd,$out\n";

chdir($module.".git");
$cmd="git remote set-url origin ssh://git.timesinternet.in/git/search/dam/".$module.".git";
($out,$stat)=&unixCommand($cmd);
print "$cmd,$out\n";

$cmd="git push -f origin";
($out,$stat)=&unixCommand($cmd);
print "$cmd,$out\n";

}
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

