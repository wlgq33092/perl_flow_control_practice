#! /usr/bin/perl

use strict;
use warnings;
use XML::LibXML;
use Data::Dumper;
use FindBin qw($Bin);

unshift @INC, "$Bin/../utils";

require "LogUtil.pm";

package FlowLogicChecker;

sub new {
    my $class = shift;
    my $flowxml = shift;

    my $checker = {
        flowxml => $flowxml
    };

    my $dom = XML::LibXML->load_xml( location => $flowxml, line_numbers => 1 );
    $checker->{dom} = $dom;

    bless $checker, $class;
    return $checker;
}

sub check {
    my $self = shift;
    my $dom = $self->{dom};

    my ($root_node) = $dom->findnodes("/FMO");
    my $root_node_name = $root_node->nodeName;
    $self->{root_node} = $root_node_name;
    print "root node name: $root_node_name\n";
    my @switcher_nodes = $dom->findnodes("/$root_node_name/flow/switcher");
    my @switcher_names;
    push @switcher_names, $_->to_literal foreach (@switcher_nodes);
    my $switcher_truth_table = $self->generate_truth_table(\@switcher_names);

    $self->generate_dependency();
}

sub generate_truth_table {
    my $self = shift;
    my $switcher_names_ref = shift;
    my @switcher_names = @{$switcher_names_ref};

    print "hello\n";
}

sub get_node_value {
    my $self = shift;
    my $node = shift;
    my $tag = shift;

    my ($tag_node) = $node->findnodes($tag);
    my $value = $tag_node->to_literal;
    $value =~ s/^\s*(.*)\s*$/$1/g;
    return $value;
}

sub generate_dependency {
    my $self = shift;
    my $dom = $self->{dom};
    my $root_node = $self->{root_node};
    my $jobs_info = {};

    my @job_nodes = $dom->findnodes("/$root_node/flow/job");
    foreach my $job_node (@job_nodes) {
        my $name = $self->get_node_value($job_node, 'name');
        print "job node name: $name\n";
        my @next_nodes = $job_node->findnodes("next");
        my @next_jobs;
        push @next_jobs, $_->to_literal foreach @next_nodes;
        $jobs_info->{$name}->{next} = \@next_jobs;

        my @depend_nodes = $dom->findnodes("/$root_node/flow/job/next[text()='$name']/.. | \
                                            /$root_node/flow/trigger/next[text()='$name']/.. | \
                                            /$root_node/flow/switcher/caseY[text()='$name']/..");
        my @negative_depend_nodes = $dom->findnodes("/$root_node/flow/switcher/caseN[text()='$name']/..");

        my @depends;
        foreach my $depend_node (@depend_nodes) {
            my $depend_job_name = $self->get_node_value($depend_node, 'name');
            print "depend job name: $depend_job_name\n";
            my $condition = $depend_job_name . ".done";
            my @depend = ('Y', $condition);
            push @depends, \@depend;
        }
        foreach my $depend_node (@negative_depend_nodes) {
            my $depend_job_name = $self->get_node_value($depend_node, 'name');
            print "depend job name: $depend_job_name\n";
            my $condition = $depend_job_name . ".done";
            my @depend = ('N', $condition);
            push @depends, \@depend;
        }

        $jobs_info->{$name}->{depend} = \@depends;
    }

    LogUtil::dump("jobs info:\n", $jobs_info);
}

1;
