#!/usr/bin/perl -w
use strict;
use warnings;

use File::Find::Rule;
use Getopt::Long::Descriptive;
use Data::Dumper;

###########################################################################
# get command line options
###########################################################################
my ($opt, $usage) = describe_options(
  '%c %o <some-arg>',
  # Strings will make $opt->strings TRUE
  ['strings|s',	"extract strings using swfstrings"],
  # JPEG will make $opt->jpeg TRUE
  ['jpeg|j', 	"attempt jpeg extraction"],
  # PNG will make $opt->png TRUE
  ['png|p',	"attempt png extraction"],
  [ 'help|h',	"print usage message and exit", { shortcircuit => 1 } ],
);
print($usage->text), exit if $opt->help;
###########################################################################
# first get the file dumped to rawtext
#
#for all lines with < and > on the line cut all text after final >
# example with grep and cut
# grep '<.*>' 5.swfdump-t.rawtext | cut -d '>' -f 2
#
###########################################################################
# subs
###########################################################################
#
sub run_swfstrings($){
	# 
	my $filename = shift;
	print "DEBUG:run_swfstrings($filename)";
	`swfstrings $filename > $filename.swfstrings.out`;
}

sub run_swfextract($){
	# 
	my $filename = shift;
	my @swfextract_output;
	print "DEBUG:run_swfextract($filename)\n";
	@swfextract_output = `swfextract $filename`;
	# shift off the first item
	my $firstitem = shift(@swfextract_output);	
	foreach my $line (@swfextract_output){
		#
		print $line;
		# if there are one or more jpegs to extract
		# [-j]
		# if there are one or more pngs to extract
		# [-p]
	}
}

sub walk_filelist(@) {
	my @filelist = @_;
	my @swfextract_output;
	foreach my $file (@filelist){
		print "\nFile:".$file."\n";
		run_swfstrings($file);
		@swfextract_output = run_swfextract($file);
	}
}
###########################################################################
# main flow
###########################################################################
# 
# For Each .swf file in current directory
my @swffiles = File::Find::Rule->file()
				->name( '*.swf' )
				->mindepth(1)
				->maxdepth(1)
				->in( '.' );
print "Number of SWF Files in Current Directory:".($#swffiles+1);
walk_filelist(@swffiles);

# Place extracted text according to name
# Place extracted image according to name
#
#  Generate strings from the .swf file using swfstrings
#  Prettify the output somewhat
#  use swfextract to get inventory of jpeg and pdf files
# jpegs by using the [-j] arg with the numbers
# pngs by using the [-p] arg with the numbers
#
