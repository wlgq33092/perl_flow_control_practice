#! /usr/bin/perl

use strict;

require "parser_result.pm";
require "flow_parser.pm";

package FMOEngineKernel;

sub new {
    my $class = shift;
    my $config = shift;
    my $flow_log = shift;
    my $flow = {
        "name"  => "flow",
        "log" => $flow_log,
        "jobs_config"  => $config,
        "types" => [],
        "jobs"  => {}
    };
    bless $flow, __PACKAGE__;
    return $flow;
}

# get next job's name by job name
sub get_next_jobs {
    my $self = shift;
    my $job = shift;

    my $name = $job->{name};

    my @inherit = $job->{ISA};
    print "isa: $_\n" foreach (@inherit);

    if ($job->{type} eq 'switcher') {
        return $job->next();
    }

    my $flow_config = $self->{jobs_config};

    my $flowxml_config = $flow_config->get_flowxml_result();
    my $job_config = $flowxml_config->{name2job}->{$name};

    return $job_config->get_next();
}

sub job_status {
    my $self = shift;
    my $job = shift;

    $self->{log}->log_print("check running job $job->{name} status.\n");

    if ($job->finish()) {
        return qw/finish/;
    }
    if ($job->abort()) {
        return qw/abort/;
    }
    return qw/running/;
}

sub run {
    my $self = shift;
    my $name2job = shift;
    my $flow_config = shift;

    my $log = $self->{log};
    my $flowxml_config = $flow_config->get_flowxml_result();
    my $start_jobs_ref = $flowxml_config->get_start_jobs();
    my @start_jobs = @{$start_jobs_ref};

    my (@ready_jobs, @done_jobs);
    my %running_jobs;
    while (1) {
        foreach my $start_job (@start_jobs) {
            print "engine kernel: run job $start_job. total start job num $#start_jobs\n";
            my $job = $name2job->{$start_job};
            #LogUtil::dump("engine kernel job:\n", $job);
            if ($job->prepare()) {
                $log->log_print("setup job $job->{name} success.\n");
            } else {
                die "setup job $job->{name} fail.\n";
            }
            if ($job->submit()) {
                $log->log_print("submit job $job->{name} success.\n");
            } else {
                die "submit job $job->{name} fail.\n";
            }

            $running_jobs{$start_job} = $job;

            # check if next job is switch. If it is, run it.
            # my $next_jobs_name = $self->get_next_jobs($start_job);
            # my $next_jobs = $name2job->{$next_jobs_name};
            # if (ref $next_jobs eq "switcher") {
            #     $running_jobs{$next_jobs->{name}} = $next_jobs;
            # }

            # if ($start_job ne "DONE") {
            #     my $next_jobs_name = $self->get_next_jobs($start_job);
            #     my $next_jobs = $name2job->{$next_jobs_name};
            #     $log->log_print("next job is $next_jobs->{name}.\n");
            #     push @ready_jobs, $next_jobs;
            # }
            #foreach my $next_job (@{$next_jobs}) {
            #    push @ready_jobs, $next_job;
            #}
        }

        # cleanup start_jobs
        $log->log_print("cleanup start job array here.\n");
        sleep 3;
        @start_jobs = ();

        # check if job finish or abort
        foreach my $jobname (keys %running_jobs) {
            $log->log_print("check running job: $jobname.\n");
            my $job = $name2job->{$jobname};
            my $status = $self->job_status($job);
            if ($status eq "finish") {
                if ($jobname eq "DONE") {
                    $log->log_print("flow run to done.\n");
                    exit 0;
                }

                $log->log_print("$jobname run to done.\n");
                push @done_jobs, $jobname;
                my $next_jobs = $self->get_next_jobs($job);
                $log->log_print("next job is $next_jobs.\n");
                push @start_jobs, $next_jobs;
                delete $running_jobs{$jobname};
            } elsif ($status eq "abort") {
                die "job $jobname abort, flow abort.\n";
            }
        }
    }
}

sub DESTROY {

}

package BatchSMOEngine;

sub new {
    my $class = shift;
    my $engine = {};

    bless $engine, $class;
    return $engine;
}

sub run {
    # will do something here
}

sub DESTROY {

}

1;
