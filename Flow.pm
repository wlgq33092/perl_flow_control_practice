#! /usr/bin/perl

require "common.pm";

package Flow;

sub new {
    my $flow = {};
    $flow->{"jobs"} = ();
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

1;
