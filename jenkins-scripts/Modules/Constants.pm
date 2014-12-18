package Modules::Constants;

use strict;
use base qw(Exporter);

#use File::Basename;

@Modules::Constants::EXPORT = qw(rel_db);
@Modules::Constants::EXPORT_OK   = qw(
	reldbhost
	reluser
	relpassword
	);

use constant rel_db =>"REL";
use constant reldbhost =>"192.168.33.71";
use constant reluser =>"reluser";
use constant relpassword =>"rel@567";


1;
