package Modules::Util;

use Exporter;
use Data::Dumper;

@ISA = qw(Exporter);
@EXPORT = qw(
          unixCommand
	 );

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

1;
