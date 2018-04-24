#! /usr/bin/perl

use strict;
use Component;

require "common.pm";
require "Component.pm";
require "LogUtil.pm";
require Exporter;

package switcher;

our @ISA = qw/Component/;

sub new {
    my $class = shift;
    my $name = shift;
    my $job_config = shift;
    my $job = {
        type   => __PACKAGE__,
        name   => $name,
        config => $job_config,
        YES     => 0
    };

    print "$class is created, condition is $job_config->{condition}\n";
    my $log_file = "./test/$name" . ".log";
    my $log = LogJob->new($log_file);
    $job->{log} = $log;
    bless $job, $class;
    return $job;
}

sub next {
    my $self = shift;
    my $config = $self->{config};

    print "switcher next: $config->{caseY}, $config->{caseN}\n";

    if ($self->{YES} == 1) {
        return $config->{caseY};
    } else {
        return $config->{caseN};
    }
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
    # my $name = $self->{name};
    # $self->{pid} = common::async_run("../test.sh 5 $name");
    return 1;
}

sub finish {
    my $self = shift;

    return 1 if $self->{YES} == 1;

    my $config = $self->{config};
    my $condition = $config->{condition};

    print "switcher: $self->{name}, condition is $condition.\n";

    # $self->{YES} = $self->SUPER::check_condition($condition);
    $self->{YES} = Component::check_condition($self, $condition);
    return $self->{YES};
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
