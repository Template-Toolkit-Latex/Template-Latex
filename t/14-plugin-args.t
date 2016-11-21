#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/14-plugin-args.t
#
# Test the Latex filter with PDF output. Because of likely variations in
# installed fonts etc, we don't verify the entire PDF file. We simply
# make sure the filter runs without error and the first four characters
# of the output file have the correct value "%PDF".
#
# Written by Craig Barratt <craig@arraycomm.com> 
# Updated for the Template-Latex distribution by Andy Wardley.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
#========================================================================

use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use lib ( abs_path("$Bin/../lib"), "$Bin/lib" );
use Template::Latex;
use Test::More;


my $run_tests = ($ENV{LATEX_TESTING} && $ENV{XELATEX_TESTING})
   || $ENV{ALL_TESTING};

if (! $run_tests){
    plan skip_all => 
	'Tests skipped, XELATEX_TESTING and LATEX_TESTING or ALL_TESTING not set';
}

# On some versions of LaTeX::Driver, xelatex is the default PDF output
# format, while on others, it is pdflatex.

# On version 0.200.4, passing the preferred format (LATEX_FORMAT) to
# Template::Latex doesn't work.

# This test implements 2 documents either one of which should fail
# if the arguments aren't passed correctly.


my $tt;
my $out;

my $source = <<HERE;
[% TRY;
out = FILTER latex
 %]
\\documentclass{article}
\\begin{document}
\\section{Introduction}
\\badmacro
This is the introduction.
\\end{document}
[% END;
 out | head(100, 1);
 CATCH latex;
    "ERROR: \$error";
 END
%]
HERE

    # We're running the above document because of the error message, which
    # contains the processor effectively used.
    # The format specifies we want to use pdflatex
$tt = Template::Latex->new({
    LATEX_FORMAT => 'pdf(pdflatex)',
			   });
$tt->process(\$source, undef, \$out);
is($out,<<EXPECT,'running pdflatex');
ERROR: latex error - pdflatex exited with errors:
! Undefined control sequence.
l.5 \\badmacro

EXPECT

$out = '';
$tt = Template::Latex->new({
    LATEX_FORMAT => 'pdf(xelatex)',
			   });
$tt->process(\$source, undef, \$out);
is($out,<<EXPECT,'running xelatex');
ERROR: latex error - xelatex exited with errors:
! Undefined control sequence.
l.5 \\badmacro

EXPECT

done_testing();
