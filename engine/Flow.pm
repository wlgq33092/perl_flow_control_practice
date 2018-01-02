#! /usr/bin/perl

use strict;
use Data::Dumper;
use Cwd;
use XML::Simple;

use flow_parser;

require "job_config.pm";
require "LogUtil.pm";

my $pwd = &getcwd;
chomp $pwd;
my $job_path = $pwd . "/jobs/";
unshift @INC, $job_path;

package Flow;

my %flow_jobs = ();

sub new {
    my $flow = {
        "name"  => "flow",
        "jobs_config"  => [],
        "types" => [],
        "jobs"  => {}
    };
    bless $flow, "Flow";
    return $flow;
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

sub append_job {
    my $self = shift;
    my $job_module = shift;
    push $self->{"jobs"}, $job_module->new();
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

sub run {
    my $self = shift;
    my %obj = %{$self};

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
    print "flow destroy\n";
}

1;
