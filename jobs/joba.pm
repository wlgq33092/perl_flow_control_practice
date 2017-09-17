#! /usr/bin/perl

require "common.pm";

package joba;

sub new {
    my $job = {
        "name" => "joba"
    };
    print "joba is created\n";
    bless $job, "joba";
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

1;
