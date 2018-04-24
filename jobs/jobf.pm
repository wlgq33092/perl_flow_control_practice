#! /usr/bin/perl

require "common.pm";

package jobf;

sub new {
    my $class = shift;
    my $name = shift;
    my $job_config = shift;
    my $job = {
        type   => __PACKAGE__,
        name   => $name,
        config => $job_config,
        done   => 0
    };
    print "$class is created\n";
    my $log_file = "./test/$name" . ".log";
    my $log = LogJob->new($log_file);
    $job->{log} = $log;
    bless $job, $class;
    return $job;
}

sub next {
    my $self = shift;
    my $job_config = $self->{config};

    #print "$self->{type} run next\n";
    my $nexts = $job_config->{next};
    LogUtil::dump("job $self->{name} of type $self->{type} next:\n", $nexts);
    return 1;
}

sub DESTROY {
    my $self = shift;
    my $log = $self->{log};
    $log->log_print("$self->{type} destroy\n");
}

sub abort {
    return 0;
}

sub prepare {
    my $self = shift;
    my $log = $self->{log};
    $log->log_print("run job type: $self->{type}, name: $self->{name} prepare.\n");
    return 1;
}

sub submit {
    my $self = shift;
    my $name = $self->{name};
    $self->{pid} = common::async_run("../test.sh 5 $name");
    return 1;
}

sub finish {
    my $self = shift;

    if ($self->{done} == 1) {
        return 1;
    }

    my $pid = $self->{pid};
    print "check if done: pid is $self->{pid}, my pid is $pid\n";
    $self->{done} = common::run_to_done($pid);

    return $self->{done};
}


sub percentage {
    my $self = shift;
    my $per = shift;
    my $stage = shift;

    my $log = $self->{log};

    $log->log_print("percentage $per stage $stage\n");

    return 1;
}

sub done {
    return 1;
}

1;
