#! /usr/bin/perl

package JobConfig;

sub new {
    my $job_config = {};
    my %next = {};
    bless $job_config, "JobConfig";
}

sub parse {
    my $self = shift;
    my $config_file = shift;
    return 1;
}

sub insert_next_table {
    my $self = shift;
    my $condition = shift;
    my $nextjob = shift;

    $self->{next}->{$condition} = $nextjob;
}

sub set_type {
    my $self = shift;
    my $type = shift;

    $self->{type} = $type;
}

sub set_start {
    my $self = shift;

    $self->{start} = 1;
}

sub set_end {
    my $self = shift;

    $self->{end} = 1;
}

sub DESTROY {
    return 1;
}

1;
