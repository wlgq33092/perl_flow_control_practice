#! /usr/bin/perl

use strict;
use Data::Dumper;
use Cwd;
use XML::Simple;

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
        "name" => "flow"
    };
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

sub build_jobs {
    my $self = shift;
    my $config_file = shift;

    my $xml = &main::XMLin($config_file);
    #LogUtil::dump("xml file:\n", $xml);

    my $jobs = $xml->{job};

    foreach my $job_name (keys %{$jobs}) {
        my $jobinfo = $jobs->{$job_name};
        unless (lc($job_name) eq "end") {
            my $job = JobConfig->new($jobinfo->{type});
            $job->{type} = $jobinfo->{type};
            $job->{conditions} = $jobinfo->{condition};
            $flow_jobs{$job_name} = $job;
            LogUtil::dump("job $job_name:\n", $flow_jobs{$job_name});
        }
    }
}

sub build_flow {
    my $self = shift;
    $self->{start} = "job1";

    my $job1 = JobConfig->new("joba");
    my $job2 = JobConfig->new("jobb");
    my $job3 = JobConfig->new("jobc");

    $job1->insert_next_table("finish", "job2");
    $job2->insert_next_table("finish", "job3");
    $job3->insert_next_table("finish", "END");

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

    my $cur_job_conf = $flow_jobs{"start"};
    my $job_type = $cur_job_conf->{type};
    print "run, job_type is $job_type\n";
    my $cur_job = $job_type->new();
    my $flow_finish = 0;
    while (1) {
        my $has_next = 0;
        #LogUtil::dump("current job conf:\n", $cur_job_conf);
        my $conditions = $cur_job_conf->get_next_table();
        #LogUtil::dump("print conditions:\n", $conditions);
        foreach my $condition (keys %{$conditions}) {
            if ($cur_job->$condition()) {
                my $next_job_name = $conditions->{$condition};
                LogUtil::dump("next job name:\n", $next_job_name);
                if ($next_job_name eq "END") {
                    $flow_finish = 1;
                    last;
                }
                $cur_job_conf = $flow_jobs{$next_job_name};
                $has_next = 1;
                last;
            }
        }
        if ($flow_finish) {
            print "flow run to done.\n";
            last;
        }
        if (0 == $has_next) {
            print "job abort before flow run to done\n";
            last;
        }
    }
}

sub DESTROY {
    print "flow destroy\n";
}

1;
