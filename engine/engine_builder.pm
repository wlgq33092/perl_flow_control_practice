#! /usr/bin/perl

use strict;

package EngineJobBuilder;

sub new {
    my $class = shift;
    my $job_config = shift;
    my $builder = {
        "config" => $job_config
    };

    bless $builder, $class;
    return $builder;
}

sub load_job {
    my $self = shift;
    my $job_module = shift;
    my $name = shift;
    my $job_config = shift;
    #$job_module = "JOB::" . $job_module;
    my $job_module_file = $job_module . ".pm";
    print "Flow, load_job, job_module is $job_module\n";

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

sub build_jobs {
    my $self = shift;
    my $config_file = shift;

    my $parser = flow_parser->new($config_file);
    $self->{jobs_config} = $parser->parse();
    #LogUtil::dump("build jobs, job config:\n", $self->{jobs_config});

    foreach my $job_config (@{$self->{jobs_config}}) {
        my $job_type = $job_config->{type}[0];
        my $job_name = $job_config->{name}[0];
        #print "build jobs: job type is $job_type\n";
        my $job = $self->load_job($job_type, $job_name, $job_config);
        $self->{jobs}->{$job_name} = $job;
        $job->next();
    }
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
    my $jobtype = $self->{jobtype};

    if ($jobtype ne "BatchSMO") {
        return &FMOEngine::new;
    } else {
        return &BatchSMOEngine::new;
    }
}

1;
