#! /usr/bin/perl

use XML::Simple;

package flow_parser;

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
        $name2job{$job->{name}} = $job;
    }

    #LogUtil::dump("self opts:\n", $self->{opts});
    foreach my $item (@jobs) {
        my $depends = $item->{depend};
        my $type = $item->{type};
        foreach my $depend_str (@{$depends}) {
            #print "depend_str is $depend_str\n";
            my @depend_array = split /\s+(and|or)\s+/, $depend_str;
            foreach my $depend (@depend_array) {
                #print "depend is $depend\n";
                if (grep /^$depend$/, @{$self->{opts}}) {
                    print "get opts $depend, ignore it.\n";
                } elsif ($depend =~ /^*.*$/) {
                    my ($name, $cond) = split /\./, $depend;
                    #print "get depend str: name is $name, cond is $cond\n";
                    $name2job{$name}->{next}->{$cond} = $item->{name};
                } else {
                    die "invalid depend str $depend, please check the flow.xml file.\n";
                }
            }
        }
    }

    foreach my $job (@jobs) {
        #LogUtil::dump("job $job->{name}:\n", $job);
    }

    return \@jobs;
}

1;
