#! /usr/bin/perl

use strict;

use Getopt::Long qw(:config no_ignore_case);

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

require "flow_engine.pm";
require "flow_parser.pm";
require "common.pm";

my $flow_log = LogFlow->new($srcdir . "/test/flow.log");

sub main {
    print "main\n";

    # run flow parser
    my $parser = FlowParser->new();
    my $parser_res = $parser->parse();

    # set parser result to TflexCommon and Common

    # run flow engine
    my $engine = FlowEngine->new($parser_res, $flow_log);
    $engine->build_jobs();
    common::set_jobs($engine->{name2job});
    common::set_config($parser_res);

    $engine->run();
}

sub Test_CMDLineResult {
    require "parser_result.pm";
    my %test_opts = (
        a => "aa",
        b => "bb",
        c => "cc",
        d => "dd"
    );

    my $test_opts_ref = {
        a => "aa",
        b => "bb",
        c => "cc",
        d => "dd"
    };

    my $res = CMDLineResult->new($test_opts_ref);
    #$res->insert();
    my $a = $res->get_a();
    my $b = $res->get_b();
    print "$a, $b\n";
}

#&Test_CMDLineResult;
&main;
