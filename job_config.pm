#! /usr/bin/perl

package JobConfig;

my %next = {};
my $job;
sub new {
    my $class = shift;
    my $type = shift;
    my $job_config = {};
    $job_config->{start} = 0;
    $job_config->{end} = 0;
    $job_config->{type} = $type;
    $job_config->{job} = $type->new();
    $job_config->{next} = ();
    #$job = $type->new();
    print "job_config: type is $job_config->{type}\n";
    bless $job_config, "JobConfig";
    return $job_config;
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
    my %obj = %{$self};

    print "job config: insert next table, $condition, $nextjob\n";
    $next{$condition} = $nextjob;
}

sub get_next_table {
    return \%next;
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
