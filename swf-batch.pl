#!/usr/bin/perl -w
use strict;
use warnings;

use File::Find::Rule;
use Getopt::Long::Descriptive;

################################################################################
# get command line options
################################################################################
my ($opt, $usage) = describe_options(
  '%c %o',
  # Strings will make $opt->strings TRUE
  ['strings|s',	"extract strings using swfstrings"],
  # JPEG will make $opt->jpeg TRUE
  ['jpeg|j', 	"perform jpeg extraction"],
  # PNG will make $opt->png TRUE
  ['png|p',	"perform png extraction"],
  # Print out a help function to show usage
  ['help|h',	"print usage message and exit", { shortcircuit => 1 } ],
);
print($usage->text), exit if $opt->help;
################################################################################
# first get the file dumped to rawtext
#
#for all lines with < and > on the line cut all text after final >
# example with grep and cut
# grep '<.*>' 5.swfdump-t.rawtext | cut -d '>' -f 2
#
################################################################################
# subs
################################################################################
#
sub run_swfstrings($){
	# 
	my $filename = shift;
	my $command;
	#print "DEBUG:run_swfstrings($filename)";
	$command ="swfstrings $filename > $filename.strings.txt";
	print "Running:$command\n";
	`$command`;
}

sub run_swfextract($){
	# 
	my $filename = shift;
	my @swfextract_output;
	# 
	my $quant;
	my @items;
	my $type;
	my $t;
	#print "DEBUG:run_swfextract($filename)\n";
	@swfextract_output = `swfextract $filename`;
	# shift off the first item
	my $firstitem = shift(@swfextract_output);	
	foreach my $line (@swfextract_output){
		# if there are one or more jpegs to extract 
		# and the option indicates to extract them
		# matching pattern: [-j]... or [-p]... at beginning of line
		if ($line =~ m/^\s\[\-(j|p)\]/) {
			# regex match variable $1
			print "matched $1\n";
			# store in a scalar
			$t = $1;
			if (($t eq "j") and ($opt->jpeg)) {
				#print "DEBUG: jpeg section\n";
				$type = "jpeg";
			} elsif (($t eq "p") and ($opt->png)) {
				#print "DEBUG: png section\n";
				$type = "png";
			}else{
				# jump to the next $line of @swfextract_output
				next;
			}
			print $line;
			# split line by spaces
			my @tokens = split / /, $line;
			my $i = 0;
			# take the 2nd element as quantity scalar contextualization
			$quant = $tokens[2];
			print "want $quant items off of the end of a $#tokens length array\n";
			@items = splice(@tokens,-$quant,$quant);
			# remove commas and carriage returns from each token
			foreach (@items) { chomp; s/,$//g; }
			foreach (@items) { 
				print "extracting $type ".$_." from".$filename."\n"; 
				my $command = "swfextract -$t $_ -o $filename.$_.$type $filename";
				print "Running".$command."\n";
				`$command`;
			}

		}
	}
}

sub walk_filelist(@) {
	my @filelist = @_;
	my @swfextract_output;
	foreach my $file (@filelist){
		print "\nFile:".$file."\n";
		run_swfstrings($file) if ($opt->strings);
		@swfextract_output = run_swfextract($file) if ($opt->jpeg or $opt->png);
		# check for jpeg if $opt->jpeg
		# check for png if $opt->png
	}
}
###############################################################################
# main flow
###############################################################################
# 
# For Each .swf file in current directory
my @swffiles = File::Find::Rule->file()->name( '*.swf' ) # extension .swf
				->mindepth(1)->maxdepth(1) # at this depth
				->in( '.' ); # current directory
print "Number of SWF Files in Current Directory:".($#swffiles+1)."\n";
if ($#swffiles+1 > 0) {
	walk_filelist(@swffiles);
} else {
	print "no .swf files to process\n";
};
###############################################################################
__END__
# Place extracted text according to name
# Place extracted image according to name
#
#  Generate strings from the .swf file using swfstrings
#  Prettify the output somewhat
#  use swfextract to get inventory of jpeg and pdf files
# jpegs by using the [-j] arg with the numbers
# pngs by using the [-p] arg with the numbers
#
###############################################################################
