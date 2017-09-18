#! /usr/bin/perl

require "common.pm";

package joba;

sub new {
    my $job = {
        "name" => "joba"
    };
    print "joba is created\n";
    bless $job, "joba";
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
    return get_job_result($self->{name});
}

sub prepare {
    return 1;
}

sub submit {
    return 1;
}

sub done {
    return 1;
}

1;
