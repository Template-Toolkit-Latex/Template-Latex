#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/02-latex2pdf.t
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
use Template;
use Template::Test;
use Template::Test::Latex;

my $run_tests = $ENV{XELATEX_TESTING} || $ENV{ALL_TESTING};

my $ttcfg = {
    FILTERS => {
        head => [ \&head_factory, 1],
    }
};

if ($run_tests){
    test_expect(\*DATA, $ttcfg);
} else {
    skip_all 'Tests skipped, XELATEX_TESTING and ALL_TESTING not set';
}

# Grab just the first $len bytes of the input, and optionally convert
# to a hex string if $hex is set

sub head_factory {
    my($context, $len, $hex) = @_;
    $len ||= 72;
    return sub {
        my $text = shift;
        return $text if length($text) < $len;
        $text = substr($text, 0, $len);
        $text =~ s/(.)/sprintf("%02x", ord($1))/eg if $hex;
        return $text;
    }
}

__END__
-- test --
[% USE Latex;
   out = FILTER latex(format="pdf(xelatex)")
-%]
\documentclass{article}
\begin{document}
\section{Introduction}
This is the introduction.
\end{document}
[% END -%]
[% out | head(4) %]
-- expect --
%PDF


-- test --
[% USE Latex format="pdf(xelatex)";
   out = FILTER latex
-%]
\documentclass{article}
\begin{document}
\section{Introduction}
This is the introduction.
\end{document}
[% END -%]
[% out | head(4) %]
-- expect --
%PDF


-- test --
[% USE Latex;
   TRY; 
     out = FILTER latex("pdf(xelatex)") 
-%]
\documentclass{article}
\begin{document}
\section{Introduction}
\badmacro
This is the introduction.
\end{document}
[%   END; 
     out | head(100, 1);
   CATCH latex;
     "ERROR: $error";
   END
-%]
-- expect --
ERROR: latex error - xelatex exited with errors:
! Undefined control sequence.
l.4 \badmacro

