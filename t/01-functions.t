#!/usr/bin/env perl

#-------------------------------------------------------------------#
# Unit tests for individual subroutines from the 'lowercase' script #
#-------------------------------------------------------------------#

use warnings;
use strict;
use autodie qw(:all);
use File::Temp qw(tempfile);
use Test::More tests => 16;

# Make the subroutines from the 'lowercase' script available as L::* :

eval 'package L { sub { ' .
     read_file((__FILE__ =~ s|[^/]+$||r).'../lowercase') .
     '} }';


# Run tests for simple functions:

is L::shellquote("foo bar"), "'foo bar'", "shellquote adds needed quotes";
is L::shellquote("foo.txt"), "foo.txt",   "shellquote avoids unneeded quotes";
is L::shellquote("./a/b c"), "'a/b c'",   "shellquote cleans up relative paths";

is L::PL(0, "cat"),          "0 cats",    "PL with n=0";
is L::PL(1, "cat"),          "1 cat",     "PL with n=1";
is L::PL(2, "cat"),          "2 cats",    "PL with n=2";


# Run tests for the 'for_lines' function:

my @testcases = (
    # 1) file with line-length > blocksize at beginning:
    [[ map { chr(65 + $_) x 3**$_ } reverse 0..9 ]                       ],
    
    # 2) file with line-length > blocksize at end, and no trailing newline:
    [[ map { chr(65 + $_) x 3**$_ } 0..9         ], no_final_newline => 1],
    
    # 3) file with run-of-empty-lines > blockize, and control characters:
    [[ map { ('') x 3**$_, chr($_) } 0..9        ]                       ],
    
    # 4) empty file:
    [[                                           ], no_final_newline => 1],
);

for my $i (1..@testcases) {
    my $file = create_temp_file(@{$testcases[$i - 1]});
    my $lines = $testcases[$i - 1][0];
    
    is_deeply for_lines_list($file), $lines,
              "for_lines reading file $i front-to-back";
    
    is_deeply for_lines_list($file, {reverse => 1}), [reverse @$lines],
              "for_lines reading file $i back-to-front";
}

is_deeply for_lines_list('printf "A\nB\nC\nD\nE"', {pipe => 1}),
          [qw(A B C D E)],
          "for_lines reading from pipe";

is_deeply for_lines_list('printf "A\0B\0C\0D\0E"', {pipe => 1, nl => "\0"}),
          [qw(A B C D E)],
          "for_lines reading from pipe with custom separator";


# Helper functions:

sub for_lines_list {
    my @lines;
    L::for_lines(@_, sub { push @lines, shift });
    \@lines
}

sub read_file {
    my $file = shift;
    open my $fh, '<', $file;
    local $/ = undef;
    my $text = <$fh>;
    close $fh;
    $text;
}

sub create_temp_file {
    my ($lines, %opt) = @_;
    my ($fh, $name) = tempfile(UNLINK => 1);
    print {$fh} $_, "\n" for @$lines[0 .. $#{$lines} - 1];
    print {$fh} @$lines[-1] if @$lines;
    print {$fh} "\n" unless $opt{no_final_newline};
    close $fh;
    -e $name or die "Could not create temp file '$name'";
    $name;
}
