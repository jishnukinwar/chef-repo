#!/usr/bin/perl

my $WORKSPACE = $ARGV[0];
my $livepath= $ARGV[1];
my $contextname=$ARGV[2];
my $srcmodulename=$ARGV[3];
my $jirano=$ARGV[4];

if( $livepath =~ m/^\// )
{
	print "Livepath path should not start with / ";
	exit 0;
}
else  {	print  "Correct livepath"; }
