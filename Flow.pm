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
    LogUtil::dump("build jobs, job config:\n", $self->{jobs_config});

    foreach my $job_config (@{$self->{jobs_config}}) {
        my $job_type = $job_config->{type};
        my $job_name = $job_config->{name};
        print "build jobs: job type is $job_type\n";
        my $job = $self->load_job($job_type, $job_name, $job_config);
        $self->{jobs}->{$job_name} = $job;
        $job->next();
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

    my $xml1 = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml";
    my $parser = flow_parser->new($xml1);
    my $jobs = $parser->parse();

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
