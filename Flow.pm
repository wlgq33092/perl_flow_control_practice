#! /usr/bin/perl

require "common.pm";
require "job_config.pm";

package Flow;

my $pwd = `pwd`;
chomp $pwd;
my $job_path = $pwd . "/jobs/";
unshift @INC, $job_path;

print "stwu debug: $_\n" foreach (@INC);

sub new {
    my $flow = {};
    $flow{"jobs"} = ();
    my %flow_jobs = {};
    bless $flow, "Flow";
}

sub DESTROY {
    print "flow destroy\n";
}

sub load_job {
    my $self = shift;
    my $job_module = shift;
    #$job_module = "JOB::" . $job_module;
    my $job_module_file = $job_module . ".pm";
    print "Flow, load_job, job_module is $job_module\n";

    require "$job_module_file";

    return $job_module->new();
}

sub append_job {
    my $self = shift;
    my $job_module = shift;
    push $self->{"jobs"}, $job_module->new();
}

sub build_flow {
    my $self = shift;

    my $job1 = JobConfig->new();
    my $job2 = JobConfig->new();
    my $job3 = JobConfig->new();
    $self->{start} = "job1";

    $flow_jobs{"job1"} = \$job1;
    $flow_jobs{"job2"} = \$job2;
    $flow_jobs{"job3"} = \$job3;

    $job1->insert_next_table("finish", "job2");
    $job2->insert_next_table("finish", "job3");
}

sub run {
    my $self = shift;
    my $flow_jobs = $self->{flow_jobs};
    my $start_job_name = $self->{start};
    my $start_job = $flow_jobs->{$start_job_name};
}

1;
