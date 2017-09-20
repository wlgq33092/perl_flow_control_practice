#! /usr/bin/perl

#use strict;
use Data::Dumper;
#require "common.pm";
require "job_config.pm";

my $pwd = `pwd`;
chomp $pwd;
my $job_path = $pwd . "/jobs/";
unshift @INC, $job_path;

package Flow;

my %flow_jobs = ();

sub new {
    my $flow = {
        "name" => "flow"
    };
    #$flow{jobs} = ();
    #$flow{name} = "flow";
    bless $flow, "Flow";
    return $flow;
}

sub load_job {
    my $self = shift;
    my $job_module = shift;
    #$job_module = "JOB::" . $job_module;
    my $job_module_file = $job_module . ".pm";
    print "Flow, load_job, job_module is $job_module\n";

    require $job_module_file;

    return $job_module->new();
}

sub append_job {
    my $self = shift;
    my $job_module = shift;
    push $self->{"jobs"}, $job_module->new();
}

sub build_flow {
    my $self = shift;
    $self->{start} = "job1";

    my $job1 = JobConfig->new("joba");
    my $job2 = JobConfig->new("jobb");
    my $job3 = JobConfig->new("jobc");

    $job1->insert_next_table("finish", "job2");
    $job2->insert_next_table("finish", "job3");

    %flow_jobs = (
        "start" => $job1,
        "job1"  => $job1,
        "job2"  => $job2,
        "job3"  => $job3
    );

    print "build_flow finish\n";
}

sub run {
    my $self = shift;
    my %obj = %{$self};
    #my $flow_jobs = $self->{flow_jobs};
    #print "run: self start job name is $start_job_name\n";
    #my $start_job_name = $self->{start};
    foreach my $key (keys %flow_jobs) {
        print "stwu debug: flow jobs keys is $key\n";
    }
    print "run flow, self name is $obj{name}\n";

    my $start_job = $flow_jobs{"start"};
    print "run job: start_job is $start_job->{job}->{name}\n";

    my $cur_job_conf = $start_job;
    my $job_type = $cur_job_conf->{type};
    print "run, job_type is $job_type\n";
    my $cur_job = $job_type->new();
    while (1) {
        print "current job conf is $cur_job_conf->{job}->{name}\n";
        my $conditions = $cur_job_conf->get_next_table();
        foreach my $condition (keys %{$conditions}) {
            print "condition is $condition, finish res is $cur_job->$condition\n";
            if ($cur_job->$condition()) {
                my $next_job_name = $cur_job_conf->get_next_table()->{$condition};
                $cur_job_conf = $flow_job{$next_job_name};
                last;
            }
        }
    }
}

sub DESTROY {
    print "flow destroy\n";
}

1;
