#! /usr/bin/perl

package JobConfig;

sub new {
    my $job_config = {};
    my %job1 = {
        "next" => \%job2;
    };
    bless $job_config, "JobConfig";
}

sub DESTROY {
    return 1;
}
