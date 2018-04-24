#! /usr/bin/perl

use strict;

use GetOpt::Long qw(:config_no_ignore_case);
use Test::More;
use base qw(Test::Class);
#use Test::Class;

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
require "parser_result.pm";

my $test_job_config;
my $test_switcher_config;
my $test_cmdline_result;

sub make_result : Test(startup) {
    my $test_job_config_ref = {
        name => "job1",
        type => "joba",
        path => "path/to/job"
    };
    my $test_flow_config_ref = {
        name => "job1",
        next => "job2"
    };
    $test_job_config = JobConfiguration->new($test_flow_config_ref, $test_job_config_ref);

    my $test_switcher_ref = {
        name => "switcher1",
        type => "normal",
        condition => "job1.finish",
        caseY => "job2",
        caseN => "DONE"
    };
    $test_switcher_config = SwitcherConfiguration->new($test_switcher_ref);
}

sub shutdown : Test(shutdown) {
    print "Test result finish.\n";
}

sub test_job_configuration_result : Test {
    can_ok($test_job_config, qw/get_name get_type get_path get_next/);
    is($test_job_config->get_name(), "job1", "job name test");
    is($test_job_config->get_type(), "joba", "job type test");
    is($test_job_config->get_path(), "path/to/job", "job path test");
    is($test_job_config->get_next(), "job2", "job next test");
}

sub test_switcher_configuration_result : Test {
    can_ok($test_switcher_config, qw/get_name get_type get_condition get_caseY get_caseN/);
    is($test_switcher_config->get_name(), "switcher1", "switcher name test");
    is($test_switcher_config->get_type(), "normal", "switcher type test");
    is($test_switcher_config->get_condition(), "job1.finish", "switcher condition test");
    is($test_switcher_config->get_caseY(), "job2", "switcher caseY test");
    is($test_switcher_config->get_caseN(), "DONE", "switcher caseN test");
}

sub test_main {
    Test::Class->runtests;
}

&test_main;
