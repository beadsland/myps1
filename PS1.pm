package PS1;

use warnings;
use strict;
use diagnostics;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(fw_utf utf tput exe ign esc os_cmd ctl_seq);

# We favor speed over interpolation.
## no critic (ProhibitConstantPragma)
use constant ESC => '\\033';

sub fw_utf { # Line wrapping fix for full length CJK characters.
  my ($sym) = @_;
  return tput('sc') . ' ' . tput('rc') . utf($sym);
}

sub utf {
  my ($sym) = @_;
  my $spc = ' ';

  # Atom's terminal SUBTRACTS one (1) from line length for each
  # astral plane codepoint (nevermind that said glyph is delimited
  # as ignored). Adding an extra space before restoring cursor is
  # sufficient to force terminal panel to wrap correctly.
  $spc = '  ' if (length($sym) > 3 && $ENV{'TERM_PROGRAM'}
               && $ENV{'TERM_PROGRAM'} eq 'platformio-ide-terminal');

  return tput('sc') . $spc . tput('rc') . ign($sym)
}

sub tput { my ($arg) = @_; return ign(exe('tput ' . $arg)) }
sub exe { my ($cmd) = @_; return '$(' . $cmd . ')' }
sub ign { my ($txt) = @_; return esc('[') . $txt . esc(']') }
sub esc { my ($txt) = @_; return '\\' . $txt }

# operating system controls
sub os_cmd {
  my ($num, $txt) = @_;
  return ESC . "]$num;$txt" . esc('a');
}

# control sequence [introducer]
sub ctl_seq {
  my ($cmd_ltr, $n, $m) = @_;
  return ESC . "[$n" . ($m ? ";$m" : '') . $cmd_ltr;
}

1;
