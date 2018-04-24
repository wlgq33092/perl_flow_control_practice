#! /usr/bin/perl

use strict;
use XML::Simple;
use Text::ParseWords;
use Getopt::Long qw(:config no_ignore_case);

package FlowParser;

sub new {
    my $class = shift;

    my $cmdline_parser = CMDLineParser->new;

    my $parser = {
        "cmdline" => $cmdline_parser
    };

    bless $parser, $class;
    return $parser;
}

sub parse {
    my $self = shift;

    require "parser_result.pm";
    my $parser_res = ParserResult->new;

    # run command line parser first
    my $cmdline_parser = $self->{cmdline};
    my $cmdline_res = $cmdline_parser->parse();
    $parser_res->set_res("cmdline_res", $cmdline_res);

    # run pjc parser if exists
    if ($cmdline_res->has_pjc()) {
        my $pjc_parser = PJCParser->new($cmdline_res->get_pjc());
        my $pjc_res = $pjc_parser->parse();
        $parser_res->set_res("pjc_res", $pjc_res);
    }

    # run flow.xml parser
    my $test_res = $cmdline_res->has_flowxml();
    die "Don't have flow.xml path, flow will exit.\n"
        unless $cmdline_res->has_flowxml();
    my $flowxml_parser = FlowXMLParser->new($cmdline_res->get_flowxml());
    my $flowxml_res = $flowxml_parser->parse();
    $parser_res->set_res("flowxml_res", $flowxml_res);

    return $parser_res;
}



package CMDLineParser;

sub new {
    my $class = shift;
    my @opt_list = ("O=s", "C=i", "P=i", "d=s", "T=s");

    my $parser = {
        opts => \@opt_list
    };

    bless $parser, $class;
    return $parser;
}

sub parse {
    my $self = shift;
    my @opt_list = @{$self->{opts}};

    my %opts;
    my $ret = &main::GetOptions(\%opts, @opt_list);
    die "Parse command line error, flow will exit.\n" unless $ret;

    return CMDLineResult->new(\%opts);
}

package PJCParser;

sub new {
    my $class = shift;
    my $path = shift;

    my $parser = {
        path => $path
    };

    bless $parser, __PACKAGE__;
    return $parser;
}

sub parse {
    my $self = shift;
    my $path = $self->{path};
    my %opts;
    my $line;
    open FH, "<$path";
    while ($line = <FH>) {
        my @pair = &main::quotewords("=", 0, $line);
        $opts{$pair[0]} = $pair[1];
    }
    close FH;

    return PJCResult->new(\%opts);
}

package FlowXMLParser;

sub new {
    my $class = shift;
    my $config_file = shift;
    my $parser = {
        "config_file" => $config_file,
        "opts" => []
    };

    my @opts = qw /and or start/;
    $parser->{opts} = \@opts;
    bless $parser, $class;
    return $parser;
}

sub parse {
    my $self = shift;
    my $xml = &main::XMLin($self->{config_file}, ForceArray => 1);
    # my $xml = &main::XMLin($self->{config_file});

    LogUtil::dump("xml parser:\n", $xml);
    my $flowxml_res = FlowXMLResult->new($xml);

    return $flowxml_res;
}


1;
