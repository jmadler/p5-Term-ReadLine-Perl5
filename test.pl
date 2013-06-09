#! /usr/bin/perl -w
# Give an argument to use stdin, stdout instead of console
# If argument starts with /dev, use it as console
# If argument is '--no-print', do not print the result.

BEGIN{ $ENV{PERL_RL} = 'Perl' };	# Do not test TR::Gnu !
use lib './lib';
use Term::ReadLine;

use Carp;
$SIG{__WARN__} = sub { warn Carp::longmess(@_) };

my $non_interactive =
    (defined($ENV{PERL_MM_NONINTERACTIVE}))
    ? $ENV{PERL_MM_NONINTERACTIVE} :
     ($ENV{PERL_MM_USE_DEFAULT} || $ENV{AUTOMATED_TESTING});
if ($non_interactive) {
    no strict; no warnings;
    print "1..0 # skip: not interactive; " .
    "\$ENV{PERL_MM_NONINTERACTIVE}='$ENV{PERL_MM_NONINTERCTIVE}' \$ENV{AUTOMATED_TESTING}='$ENV{AUTOMATED_TESTING}'\n";
  exit;
}

if (!@ARGV) {
  $term = new Term::ReadLine 'Simple Perl calc';
} elsif (@ARGV == 2) {
  open(IN,"<$ARGV[0]");
  open(OUT,">$ARGV[1]");
  $term = new Term::ReadLine 'Simple Perl calc', \*IN, \*OUT;
} elsif ($ARGV[0] =~ m|^/dev|) {
  open(IN,"<$ARGV[0]");
  open(OUT,">$ARGV[0]");
  $term = new Term::ReadLine 'Simple Perl calc', \*IN, \*OUT;
} else {
  $term = new Term::ReadLine 'Simple Perl calc', \*STDIN, \*STDOUT;
  $no_print = $ARGV[0] eq '--no-print';
}
$prompt = "Enter arithmetic or Perl expression: ";
if ((my $l = $ENV{PERL_RL_TEST_PROMPT_MINLEN} || 0) > length $prompt) {
  $prompt =~ s/(?=:)/ ' ' x ($l - length $prompt)/e;
}
$OUT = $term->OUT || STDOUT;
%features = %{ $term->Features };
if (%features) {
  @f = %features;
  print $OUT "Features present: @f\n";
  #$term->ornaments(1) if $features{ornaments};
} else {
  print $OUT "No additional features present.\n";
}
print $OUT "\n  Flipping rl_default_selected each line.\n";
print $OUT <<EOP;

	Hint: Entering the word
		exit
	would exit the test. ;-)  (If feature 'preput' is present,
	this word should be already entered.)

EOP

while ( defined ($_ = $term->readline($prompt, "exit")) ) {
  $res = eval($_);
  if ($@) {
     warn $@ ;
  } elsif (defined($res)) {
      print $OUT $res, "\n" unless $no_print;
  } else {
      print $OUT "expression evaluated to undef\n";
  }
  $term->addhistory($_) if /\S/ and !$features{autohistory};
  $readline::rl_default_selected = !$readline::rl_default_selected;
}
