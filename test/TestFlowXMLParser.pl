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
require "LogUtil.pm";

my $test_flow_parser;
my $test_flowxml_result;

sub make_result : Test(startup) {
    my $test_config_file = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test2.xml";
    $test_flow_parser = FlowXMLParser->new($test_config_file);
    $test_flowxml_result = $test_flow_parser->parse();
}

sub shutdown : Test(shutdown) {
    print "Test result finish.\n";
}

sub test_job_configuration {
    my ($test_job_config, $exp_name, $exp_type, $exp_next) = @_;
    can_ok($test_job_config, qw/get_name get_type get_next/);
    is($test_job_config->get_name(), $exp_name, "job name test");
    is($test_job_config->get_type(), $exp_type, "job type test");
    is($test_job_config->get_next(), $exp_next, "job next test");
}

sub test_flowxml_parser : Test {
    can_ok($test_flowxml_result, qw/get_job_conf get_switcher_conf get_start_jobs/);

    my @test_flowxml_start_jobs = qw/job1/;
    is_deeply($test_flowxml_result->get_start_jobs(), \@test_flowxml_start_jobs, "compare start jobs");

    my $test_job1_ref = $test_flowxml_result->get_job_conf("job1");
    can_ok($test_job1_ref, qw/get_name get_type get_next/);
    is($test_job1_ref->get_name(), "job1", "job1 name test");
    is($test_job1_ref->get_type(), "joba", "job1 type test");
    # is($test_job1_ref->get_next(), "job2", "job1 next test");
    my @test_job1_next_job = qw/job2 job5/;
    is_deeply($test_job1_ref->{next}, \@test_job1_next_job, "job1 next test");
    #test_job_configuration($test_job1_ref, qw/job1 joba job2/);

    my $test_job2_ref = $test_flowxml_result->get_job_conf("job2");
    can_ok($test_job2_ref, qw/get_name get_type get_next/);
    is($test_job2_ref->get_name(), "job2", "job2 name test");
    is($test_job2_ref->get_type(), "jobb", "job2 type test");
    is($test_job2_ref->get_next(), "switcher1", "job2 next test");
    #test_job_configuration($test_job2_ref, qw/job2 jobb switcher1/);

    my $test_job3_ref = $test_flowxml_result->get_job_conf("job3");
    can_ok($test_job3_ref, qw/get_name get_type get_next/);
    is($test_job3_ref->get_name(), "job3", "job3 name test");
    is($test_job3_ref->get_type(), "jobc", "job3 type test");
    is($test_job3_ref->get_next(), "DONE", "job3 next test");
    #test_job_configuration($test_job3_ref, qw/job3 jobc DONE/);

    my $test_job4_ref = $test_flowxml_result->get_job_conf("job4");
    can_ok($test_job4_ref, qw/get_name get_type get_next/);
    is($test_job4_ref->get_name(), "job4", "job4 name test");
    is($test_job4_ref->get_type(), "jobd", "job4 type test");
    is($test_job4_ref->get_next(), "switcher2", "job4 next test");
    #test_job_configuration($test_job4_ref, qw/job4 jobd job3/);

    my $test_switcher1_ref = $test_flowxml_result->get_switcher_conf("switcher1");
    can_ok($test_switcher1_ref, qw/get_name get_type get_condition get_caseY get_caseN/);
    is($test_switcher1_ref->get_name(), "switcher1", "switcher1 name test");
    is($test_switcher1_ref->get_type(), "switcher", "switcher1 type test");
    is($test_switcher1_ref->get_condition(), "job2.has_defect", "switcher1 condition test");
    is($test_switcher1_ref->get_caseY(), "job3", "switcher1 caseY test");
    is($test_switcher1_ref->get_caseN(), "job4", "switcher1 caseN test");

    my $test_switcher2_ref = $test_flowxml_result->get_switcher_conf("switcher2");
    can_ok($test_switcher2_ref, qw/get_name get_type get_condition get_caseY get_caseN/);
    is($test_switcher2_ref->get_name(), "switcher2", "switcher2 name test");
    is($test_switcher2_ref->get_type(), "switcher", "switcher2 type test");
    is($test_switcher2_ref->get_condition(), "job4.no_defect", "switcher2 condition test");
    is($test_switcher2_ref->get_caseY(), "DONE", "switcher2 caseY test");
    is($test_switcher2_ref->get_caseN(), "job3", "switcher2 caseN test");
}

sub test_main {
    Test::Class->runtests;
}

&test_main;
