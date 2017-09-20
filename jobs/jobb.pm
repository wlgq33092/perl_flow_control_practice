#! /usr/bin/perl

require "common.pm";

package jobb;

sub new {
    my $job = {
        "name" => "jobb"
    };
    print "$job->{name} is created\n";
    bless $job, "jobb";
    return $job;
}

sub next {
    my $self = shift;
    print "$self->{name} run next\n";
    return 1;
}

sub DESTROY {
    my $self = shift;
    print "$self->{name} destroy\n";
}

sub finish {
    my $self = shift;
    return common::get_job_result($self->{name});
}

1;
