#! /usr/bin/perl

require "common.pm";

package jobpy;

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
    my $name = $self->{name};
    return py_setup($name);
}

sub submit {
    my $self = shift;
    my $name = $self->{name};
    return py_submit($name);
}

sub finish {
    return py_finish();
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

use Inline Python => << "END_OF_PYTHON_CODE";

import os;

def py_setup(name):
    print "set up job " + name + " success"
    os.system("echo hello")
    return 1

def py_submit(name):
    print "submit python job " + name + " success."
    return 1

def py_finish():
    print "python job finish."
    return 1

END_OF_PYTHON_CODE

1;
