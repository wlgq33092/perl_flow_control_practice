#! /usr/bin/perl

use strict;

use GetOpt::Long qw(:config_no_ignore_case);
use Test::More;

my $srcdir;
if (defined $ENV{FLOWDIR}) {
    $srcdir = $ENV{FLOWDIR};
} else {
    $srcdir = "/Users/wuge/my_practice/perl_practice/flow_control_practice";
}

unshift @INC, "$srcdir/engine";
unshift @INC, "$srcdir/parser";
unshift @INC, "$srcdir/utils";
unshift @INC, "$srcdir/jobs";

require "ScriptJob.pm";
require "flow_parser.pm";

# cmd to run:
# ./TestScriptJob.pl -P 1 -O pjc=/Users/wuge/my_practice/perl_practice/flow_control_practice/test/pjc.txt,flowxml=/Users/wuge/my_practice/perl_practice/flow_control_practice/test3.xml

my $parser = FlowParser->new();
my $config = $parser->parse();


my $job = ScriptJob->new("script1", $config);

$job->setup();
$job->submit();

while (1) {
    sleep 1;
    if ($job->done()) {
        if ($job->is_my_job()) {
            print "my job run to done.\n";
        } else {
            print "flow failed, not my job.\n";
        }
        last;
    }
}

print "job run to done\n";
