#!/usr/bin/env perl
use strict;
use warnings;
use rlib '../lib';

use Test::More;

BEGIN {
  use_ok( 'Term::ReadLine::Perl5' );
}

require 'Term/ReadLine/readline.pm';

# stop reading ~/.inputrc
$ENV{'INPUTRC'} = '/dev/null';

note("CharSize()");
$readline::_rl_japanese_mb = 1;
$readline::line = '"ABCt !@#$%{}';
for (my $i=0; $i<length($readline::line); $i++)
{
    is(readline::CharSize($i), 1,
       "should be single character at position $i: " .
       substr($readline::line, $i, 1));
}

my $double_chars = '';
for (my $i=0; $i<4; $i++) {
    $double_chars .= chr(0x81 + $i)
}
$readline::line = $double_chars;

for (my $i=0; $i<length($readline::line); $i += 2)
{
    is(readline::CharSize($i), 2,
       "double character at position $i: " .
       substr($readline::line, $i, 2));
}

note("end_of_line() only");
$readline::line = 'Moving along this line';
$readline::D    = 0;
ok(!readline::at_end_of_line(),
   "position $readline::D is not at the end of line '$readline::line'");

$readline::D = length($readline::line);
ok(readline::at_end_of_line(),
   "position $readline::D is at the end of line '$readline::line'");

note("F_ForwardChar only");
$readline::D = 0;
readline::F_ForwardChar(1);
is($readline::D, 1, "Moving a single character from position 0");
readline::F_ForwardChar(3);
is($readline::D, 4, "Moving a 3 characters from position 1");
readline::F_ForwardChar(100);
is($readline::D, length($readline::line), "Moving a past the end of the line");

$readline::line = 'a' . $double_chars . 'b';
$readline::D = 0;
readline::F_ForwardChar(1);
is($readline::D, 1, "Moving again a single character from position 0");
readline::F_ForwardChar(1);
is($readline::D, 3, "Moving one double from position 1");
readline::F_ForwardChar(1);
is($readline::D, 5, "Moving another double from position 1");
readline::F_ForwardChar(1);
is($readline::D, 6, "Moving a single after a double from position 5");


done_testing();
