#! /usr/bin/perl

use strict;
use XML::Simple;
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
    my $parser_res = &ParserResult::new;

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
    die "Don't have flow.xml path, flow will exit.\n"
        unless exists $cmdline_res->get_flowxml();
    my $flowxml_parser = FlowXMLParser->new($cmdline_res->get_flowxml());
    my $flowxml_res = $flowxml_parser->parse();
    $parser_res->set_res("flowxml_res", $flowxml_res);

    return $parser_res;
}

package CMDLineParser;

sub new {
    my $class = shift;
    my $args_ref = shift; # just pass @ARGV here
    my @opt_list = ("O=s", "C=i", "P=i");

    my $parser = {
        "args" => $args_ref,
        "opts" => \@opt_list
    };

    bless $parser, $class;
    return $parser;
}

sub parse {
    my $self = shift;
    my @args = @{$self->{args}};
    my @opt_list = @{$self->{opts}};

    my %opts;
    my $ret = GetOptionsFromArray(\@args, \%opts, \@opt_list);
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
        my @words = quotewords("=", 0, $line);
        %opts{$words[0]} = $words[1];
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
    my @jobs;
    my %name2job;
    my $xml = &main::XMLin($self->{config_file}, ForceArray => 1);
    my $job_items = $xml->{job};
    my @types;
    #LogUtil::dump("flow is:\n", $jobs);
    foreach my $item (@{$job_items}) {
        my $job = {
            "name"   => $item->{name}->[0],
            "type"   => $item->{type}->[0],
            "depend" => [],
            "next"   => {}
        };
        foreach my $condition (@{$item->{condition}}) {
            push $job->{depend}, $condition;
        }
        #LogUtil::dump("job $job->{name}:\n", $job);
        push @jobs, $job;
        foreach my $key (keys %{$item}) {
            next if $key eq "condition";
            $job->{$key} = $item->{$key};
        }

        $name2job{$job->{name}->[0]} = $job;
    }

    #LogUtil::dump("self opts:\n", $self->{opts});

    # get next here
    foreach my $item (@jobs) {
        my $depends = $item->{depend};
        my $type = $item->{type};
        foreach my $depend_str (@{$depends}) {
            #print "depend_str is $depend_str\n";
            my @depend_array = split /\s+(and|or)\s+/, $depend_str;
            foreach my $depend (@depend_array) {
                print "depend is $depend\n";
                if (grep /^$depend$/, @{$self->{opts}}) {
                    print "get opts $depend, ignore it.\n";
                } elsif ($depend =~ /^*.*$/) {
                    my ($name, $cond) = split /\./, $depend;
                    print "get $item->{name}->[0] depend str: name is $name, cond is $cond\n";
                    unless (exists $name2job{$name}->{next}->{$cond}) {
                        $name2job{$name}->{next}->{$cond}->[0] = $item->{name}->[0];
                    } else {
                        push $name2job{$name}->{next}->{$cond}, $item->{name}->[0];
                    }
                } else {
                    die "invalid depend str $depend, please check the flow.xml file.\n";
                }
            }
        }
    }

    foreach my $job (@jobs) {
        LogUtil::dump("job $job->{name}[0]:\n", $job);
    }

    return \@jobs;
}

1;
