#! /usr/bin/perl

use strict;
use XML::Simple;
use Text::ParseWords;

package ParserResult;

sub new {
    my $class = shift;
    my $res = {};

    bless $res, $class;
    return $res;
}

sub set_res {
    my $self = shift;
    my $name = shift;
    my $res = shift;
    $self->{$name} = $res;
}


package CMDLineResult;

sub new {
    my $class = shift;
    my $raw = shift;
    my %opts = %{$raw};
    my $res = {
        "type" => "CMDLineResult",
        "opts" => \%opts
    };

    CMDLineResult->insert(\%opts);

    bless $res, __PACKAGE__;
    return $res;
}

sub insert {
    my $self = shift;
    my $opts_ref = shift;
    my %opts = %{$opts_ref};

    no strict 'refs';
    foreach my $key (keys %opts) {
        if ($key eq "O") {
            CMDLineResult->parse_joboptions($opts{$key});
            next;
        }
        *{caller()."::get_$key"} = sub {
            return $opts{$key};
        }
    }
}

sub parse_joboptions {
    my $self = shift;
    my $joboptions = shift;

    my @words = parse_line(",", 0, $joboptions);
    foreach my $word (@words) {
        my @args = parse_line("=", 0, $word);
        no strict 'refs';
        *{caller()."::get_$args[0]"} = sub {
            return $args[1];
        }
    }
}

sub has_pjc {
    my $self = shift;
    return exists $self->get_pjc();
}

package PJCResult;

sub new {
    my $class = shift;
    my $raw = shift;
    my $res = {};

    PJCResult->insert($raw);

    bless $res, $class;
    return $res;
}

sub insert {
    my $self = shift;
    my $opts_ref = shift;
    my %opts = %{$opts_ref};

    no strict 'refs';
    foreach my $key (keys %opts) {
        *{caller()."::get_$key"} = sub {
            return %opts{$key};
        }
    }
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
