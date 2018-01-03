#! /usr/bin/perl

use XML::Simple;

package ParserResult;

sub new {
    my $class = shift;
    my $res = {};

    bless $res, $class;
    return $res;
}

package CMDLineResult;

sub new {
    my $class = shift;
    my $raw = shift;
    my $res = {};

    bless $res, $class;
    return $res;
}

package PJCResult;

sub new {
    my $class = shift;
    my $raw = shift;
    my $res = {};

    bless $res, $class;
    return $res;
}

package FlowXMLResult;

sub new {
    my $class = shift;
    my $raw = shift;
    my $res = {};

    bless $res, $class;
    return $res;
}

1;
