#! /usr/bin/perl

use strict;
use Data::Dumper;
use Cwd;
use XML::Simple;

use flow_parser;

require "job_config.pm";
require "LogUtil.pm";
require "engine_builder.pm";
require "flow_parser.pm";

package FlowEngine;

sub new {
    my $class = shift;
    my $config = shift;
    my $flow_log = shift;
    my $flow = {
        config => $config,
        log    => $flow_log
    };

    my $jobtype = $config->get_cmdline_result()->get_T();
    $flow_log->log_print("Flow job type is $jobtype.\n");
    my $engine_builder = EngineKernelBuilder->new($jobtype);
    $flow->{engine} = $engine_builder->build($config, $flow_log);
    $flow->{job_builder} = EngineJobBuilder->new();

    bless $flow, __PACKAGE__;
    return $flow;
}

sub run {
    my $self = shift;

    # run engine kernel
    my $engine = $self->{engine};
    $engine->run($self->{name2job}, $self->{config});
}

sub build_jobs {
    my $self = shift;

    my $flow_result = $self->{config}->get_flowxml_result();
    my $jobs_conf = $flow_result->get_all_jobs_conf();
    my $start_jobs = $flow_result->get_start_jobs();
    my %name2job;
    my $builder = $self->{job_builder};
    foreach my $job_conf (@{$jobs_conf}) {
        #LogUtil::dump("build job, job conf:\n", $job_conf);
        # my $job = $builder->build_job($job_conf->{type}, $job_conf->{name}, $self->{config});
        my $job = $builder->build_job($job_conf->{type}, $job_conf->{name}, $job_conf);
        #LogUtil::dump("after building:\n", $job);
        print "job name after building is: $job_conf->{name}\n";
        $name2job{$job_conf->{name}} = $job;
    }

    # build DONE job
    my $DONE_job = $builder->build_job("DONE", "DONE", $self->{config});
    $name2job{DONE} = $DONE_job;

    $self->{name2job} = \%name2job;
    LogUtil::dump("name2job after build:\n", $self->{name2job});
}

sub DESTROY {
    print "flow destroy\n";
}

1;
