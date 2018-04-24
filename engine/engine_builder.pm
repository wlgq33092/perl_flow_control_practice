#! /usr/bin/perl

use strict;

require "engine_kernel.pm";

package EngineJobBuilder;

sub new {
    my $class = shift;
    my $job_config = shift;
    my $builder = {};

    bless $builder, $class;
    return $builder;
}

sub build_job {
    my $self = shift;
    my $job_module = shift;
    my $name = shift;
    my $job_config = shift;
    #$job_module = "JOB::" . $job_module;
    my $job_module_file = $job_module . ".pm";
    print "Flow, load_job, job_module is $job_module, name is $name\n";

    require $job_module_file;

    return $job_module->new($name, $job_config);
}

sub parse_condition {
    my $condition = shift;
    return "", "start" if $condition eq "start";
    my @statement = split /\./, $condition;
    LogUtil::dump("conditon:\n", \@statement);
    return $statement[0], $statement[1];
}

sub build_component {

}

package EngineKernelBuilder;

sub new {
    my $class = shift;
    my $jobtype = shift;

    my $builder = {
        "jobtype" => $jobtype
    };

    bless $builder, $class;

    return $builder;
}

sub build {
    my $self = shift;
    my $config = shift;
    my $log = shift;
    my $jobtype = $self->{jobtype};

    if ($jobtype ne "BatchSMO") {
        return FMOEngineKernel->new($config, $log);
    } else {
        return BatchSMOEngineKernel->new($config, $log);
    }
}

1;
