#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/12-template.t
#
# Test the Template::Latex module as a wrapper around Template.
#
# Written by Andy Wardley <abw@wardley.org>
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
use Template::Test;
use Template::Test::Latex;
use File::Spec;

my $run_tests = $ENV{LATEX_TESTING} || $ENV{ALL_TESTING};

my $out = 'output';
my $dir = -d 't' ? File::Spec->catfile('t', $out) : $out;

my $files = {
    blank => 'test2',
    pdf   => 'test2.pdf',
    ps    => 'test2.ps',
    dvi   => 'test2.dvi',
};
clean_file($_) for values %$files;
    
my $ttcfg = {
    OUTPUT_PATH  => $dir,
    LATEX_FORMAT => 'pdf',
    VARIABLES => {
        dir   => $dir,
        file  => $files,
        check => \&check_file,
    },
};

my $tt = Template::Latex->new($ttcfg);
if ($run_tests){
    test_expect(\*DATA, $tt);
} else {
    skip_all 'Tests skipped, LATEX_TESTING and ALL_TESTING not set';
}

sub clean_file {
    my $file = shift;
    my $path = File::Spec->catfile($dir, $file);
    unlink($file);
}

sub check_file {
    my $file = shift;
    my $path = File::Spec->catfile($dir, $file);
    return -f $path ? "PASS - $file exists" : "FAIL - $file does not exist";
}

__END__

-- test --
[% FILTER latex(file.pdf) -%]
\documentclass{article}
\begin{document}
This is a PDF document generated by 
Latex and the Template Toolkit.
\end{document}
[% END -%]
[% check(file.pdf) %]
-- expect --
-- process --
PASS - [% file.pdf %] exists

-- test --
[% FILTER latex(output=file.ps) -%]
\documentclass{article}
\begin{document}
This is a PostScript document generated by 
Latex and the Template Toolkit.
\end{document}
[% END -%]
[% check(file.ps) %]
-- expect --
-- process --
PASS - [% file.ps %] exists

-- test --
[% FILTER latex(file.dvi) -%]
\documentclass{article}
\begin{document}
This is a DVI document generated by 
Latex and the Template Toolkit.
\end{document}
[% END -%]
[% check(file.dvi) %]
-- expect --
-- process --
PASS - [% file.dvi %] exists

-- test --
[% FILTER latex(file.blank) -%]
\documentclass{article}
\begin{document}
This is a PDF document generated by 
Latex and the Template Toolkit.
\end{document}
[% END -%]
[% check(file.blank) %]
-- expect --
-- process --
PASS - [% file.blank %] exists

