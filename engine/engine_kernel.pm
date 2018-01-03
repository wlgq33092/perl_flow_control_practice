#! /usr/bin/perl

use strict;

package FMOEngine;

sub new {
    my $flow = {
        "name"  => "flow",
        "jobs_config"  => [],
        "types" => [],
        "jobs"  => {}
    };
    bless $flow, __PACKAGE__;
    return $flow;
}

sub run {
    my $self = shift;
    my $objref = shift;
    my %obj = %{$objref};

    my $xml1 = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml";
    my $parser = flow_parser->new($xml1);
    #my $jobs = $parser->parse();
    my $jobs = $self->{jobs_config};

    my @running_jobs = ();
    my @ready_jobs = ();
    foreach my $job (@{$jobs}) {
        push @ready_jobs, $job if $job->{depend}->[0] eq "start";
    }
    LogUtil::dump("start, ready jobs:\n", \@ready_jobs);
    while (1) {
        # run jobs here
        # first, prepare a job, then submit it,
        # then wait it run to done
        foreach my $job (@ready_jobs) {
            my $job_name = $job->{name}->[0];
            my $ready_job = $self->{jobs}->{$job_name};
            $ready_job->prepare();
            my $submit_success = $ready_job->submit();
            die "submit job failed, flow exit.\n" unless $submit_success;
            push @running_jobs, $ready_job;
        }
        @ready_jobs = ();

        last if @running_jobs == 0;
        my @finished = ();
        for (my $i = 0; $i < @running_jobs; $i = $i + 1) {
            my $running_job = $running_jobs[$i];
            if ($running_job->finish()) {
                #splice @running_jobs, $i, 1;
                push @finished, $i;
                my $nexts = $running_job->{config}->{next}->{finish};
                LogUtil::dump("running jobs, nexts:\n", $nexts);
                foreach my $next (@{$nexts}) {
                    push @ready_jobs, $self->{jobs}->{$next};
                }
            }
        }
        #last;
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
