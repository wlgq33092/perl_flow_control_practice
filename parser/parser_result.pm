#! /usr/bin/perl

use strict;
use XML::Simple;
use Text::ParseWords;

package ParserResultBuilder;

sub build {
    my $package = shift;
    my $opts_ref = shift;
    my %opts = %{$opts_ref};

    # foreach my $conf (keys %opts) {
    #     print "stwu builder: $conf $opts{$conf}\n";
    # }

    no strict 'refs';
    foreach my $key (keys %opts) {
        *{$package."::get_$key"} = sub {
            my $self = shift;
            return $self->{$key};
        }
    }
}

package ParserResult;

sub new {
    my $class = shift;
    my $res = {};

    bless $res, $class;
    return $res;
}

sub set_res {
    $_[0]->{$_[1]} = $_[2];
}

sub get_result {
    my $self = shift;
    my $name = shift;
    if (exists $self->{$name}) {
        return $self->{$name};
    } else {
        return undef;
    }
}

sub get_cmdline_result {
    my $self = shift;
    return $self->get_result("cmdline_res");
}

sub get_pjc_result {
    my $self = shift;
    return $self->get_result("pjc_res");
}

sub get_flowxml_result {
    my $self = shift;
    return $self->get_result("flowxml_res");
}

package CMDLineResult;

my $has_pjc_file = 0;
my $has_flowxml_file = 0;

sub new {
    my $class = shift;
    my $raw = shift;
    my %opts = %{$raw};
    my $res = {
        type => "CMDLineResult",
        opts => \%opts
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

    my @words = &main::parse_line(",", 0, $joboptions);
    foreach my $word (@words) {
        my @args = &main::parse_line("=", 0, $word);
        if ($args[0] eq "pjc") {
            $has_pjc_file = 1;
        } elsif ($args[0] eq "flowxml") {
            $has_flowxml_file = 1;
        }
        no strict 'refs';
        *{caller()."::get_$args[0]"} = sub {
            return $args[1];
        }
    }
}

sub has_file {
    my $self = shift;
    my $file = shift;

    return 1 if -e $file;
    return 0;
}

sub has_pjc {
    my $self = shift;
    return 0 unless $has_pjc_file;
    return $self->has_file($self->get_pjc());
}

sub has_flowxml {
    my $self = shift;
    return 0 unless $has_flowxml_file;
    return $self->has_file($self->get_flowxml());
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

    ParserResultBuilder::build(__PACKAGE__, $opts_ref);
}

package FlowXMLResult;

sub new {
    my $class = shift;
    my $xml = shift;
    my $res = {
        start         => [],
        name2job      => {},
        name2switcher => {}
    };

    my @startjobs = sort @{$xml->{flow}->[0]->{start}->[0]->{name}};
    #LogUtil::dump("start jobs:\n", @startjobs);
    $res->{start} = \@startjobs;

    FlowXMLResult::format_jobs($res, $xml);
    FlowXMLResult::format_switchers($res, $xml);

    bless $res, $class;
    return $res;
}

sub assign_value {
    my ($self, $config, $tag, $value) = @_;
    if (exists $config->{$tag}) {
        # print "assign value, tag $tag exists.\n";
        my $old_value = $config->{$tag};
        if (ref $old_value eq "ARRAY") {
            push $old_value, $value;
            $config->{$tag} = $old_value;
        } else {
            my @new_value = ($old_value, $value);
            $config->{$tag} = \@new_value;
        }
    } else {
        # print "assign value, tag $tag doesn't exist.\n";
        $config->{$tag} = $value;
    }
}

sub generate_job_config {
    my $self = shift;
    my $raw_job_config = shift;
    my $job_config = {};

    # LogUtil::dump("generate job config:\n", $raw_job_config);
    foreach my $tag (keys %{$raw_job_config}) {
        my $value_ref = $raw_job_config->{$tag};
        # LogUtil::dump("generate, value:\n", $value_ref);
        my @value_array = @{$value_ref};
        foreach my $value (@value_array) {
            my $tmp_value;
            if (ref $value eq "HASH") {
                $value = generate_job_config($self, $value);
            }
            assign_value($self, $job_config, $tag, $value);
        }
    }

    return $job_config;
}

sub format_jobs {
    my $self = shift;
    my $xml = shift;

    my %jobs_name2job;
    foreach my $job (@{$xml->{jobs}->[0]->{job}}) {
        # LogUtil::dump("job job:\n", $job);
        my $tags = generate_job_config($self, $job);
        # LogUtil::dump("job tags:\n", $tags);
        $jobs_name2job{$job->{name}->[0]} = $tags;
    }

    my %flow_name2job;
    foreach my $type (keys %{$xml->{flow}->[0]}) {
        print "stwu: format jobs, type is $type.\n";
        next if $type eq 'start';
        my $jobs = $xml->{flow}->[0]->{$type};
        foreach my $job (@{$jobs}) {
            my $tags = generate_job_config($self, $job);
            $tags->{type} = $type if $type ne 'job';
            # LogUtil::dump("job tags:\n", $tags);
            $flow_name2job{$job->{name}->[0]} = $tags;
        }
    }

    my %name2job;
    my @jobsconf;
    foreach my $name (keys %flow_name2job) {
        my $jobconf = JobConfiguration->new($flow_name2job{$name}, $jobs_name2job{$name});
        $name2job{$name} = $jobconf;
    }

    $self->{name2job} = \%name2job;
    LogUtil::dump("format jobs:\n", \%name2job);
}

sub format_switchers {
    my $self = shift;
    my $xml = shift;
    my %name2switcher;

    foreach my $switcher (@{$xml->{flow}->[0]->{switcher}}) {
        my %switcher_tags;
        my @tags;
        if (defined $switcher->{condition}) {
            @tags = qw/name condition caseY caseN/;
        } else {
            @tags = qw/name periodic_condition caseY caseN/;
        }

        foreach my $tag (@tags) {
            $switcher_tags{$tag} = $switcher->{$tag}->[0];
        }

        $name2switcher{$switcher_tags{name}} = SwitcherConfiguration->new(\%switcher_tags);
    }

    $self->{name2switcher} = \%name2switcher;
}

sub get_job_conf {
    my $self = shift;
    my $name = shift;

    return $self->{name2job}->{$name};
}

sub get_all_jobs_conf {
    my $self = shift;
    my @jobs_conf;

    foreach my $jobname (keys %{$self->{name2job}}) {
        push @jobs_conf, $self->{name2job}->{$jobname};
    }

    return \@jobs_conf;
}

sub get_switcher_conf {
    my $self = shift;
    my $name = shift;

    return $self->{name2switcher}->{$name};
}

sub get_start_jobs {
    my $self = shift;
    return $self->{start};
}

package JobConfiguration;

sub new {
    my $class = shift;
    my $flow_config = shift;
    my $job_config = shift;

    my $config = {};

    foreach my $conf (keys %{$flow_config}) {
        $config->{$conf} = $flow_config->{$conf};
    }
    foreach my $conf (keys %{$job_config}) {
        $config->{$conf} = $job_config->{$conf};
    }

    bless $config, $class;

    ParserResultBuilder::build(__PACKAGE__, $flow_config);
    ParserResultBuilder::build(__PACKAGE__, $job_config);

    return $config;
}

package SwitcherConfiguration;

sub new {
    my $class = shift;
    my $switcher_config = shift;
    my ($type, $condition);
    if (defined $switcher_config->{condition}) {
        $type = "normal";
        $condition = $switcher_config->{condition};
    } elsif (defined $switcher_config->{periodic_condition}) {
        $type = "periodic";
        $condition = $switcher_config->{periodic_condition};
    }
    my $switcher = {
        name => $switcher_config->{name},
        type => qw/switcher/,
        condition => $condition,
        caseY => $switcher_config->{caseY},
        caseN => $switcher_config->{caseN}
    };

    $switcher_config->{type} = $type;

    bless $switcher, __PACKAGE__;

    ParserResultBuilder::build(__PACKAGE__, $switcher_config);

    return $switcher;
}

1;
