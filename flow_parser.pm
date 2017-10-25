#! /usr/bin/perl

use XML::Simple;

package flow_parser;

sub new {
    my $class = shift;
    my $config_file = shift;
    my $parser = {
        "config_file" => $config_file
    };

    bless $parser, $class;
    return $parser;
}

sub parse {
    my $self = shift;
    my @jobs;
    my $xml = &main::XMLin($self->{config_file}, ForceArray => 1);
    my $jobs = $xml->{job};
    #LogUtil::dump("flow is:\n", $jobs);
    foreach my $item (@{$jobs}) {
        my $job = {
            "name"   => $item->{name}->[0],
            "type"   => $item->{type}->[0],
            "depend" => [],
            "next"   => {}
        };
        foreach my $condition (@{$item->{condition}}) {
            push $job->{depend}, $condition;
        }
        LogUtil::dump("job $job->{name}:\n", $job);
        push @jobs, $job;
    }
}

1;
