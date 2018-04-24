#! /usr/bin/perl

use strict;
use warnings;
use XML::LibXML;

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
    my $root_node_name = $root_node->to_literal;
    print "root node name: $root_node_name\n";
    my @switcher_nodes = $dom->findnodes("/$root_node_name/flow/switcher");
    my @switcher_names;
    push @switcher_names, $_->to_literal foreach (@switcher_nodes);
    my $switcher_truth_table = $self->generate_truth_table(\@switcher_names);
}

sub generate_truth_table {
    my $self = shift;
    my $switcher_names_ref = shift;
    my @switcher_names = @{$switcher_names_ref};

    print "hello\n";
}

1;
