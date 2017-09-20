#! /usr/bin/perl

package common;

my $job_result = {
    "joba" => 1,
    "jobb" => 1,
    "jobc" => 1
};

my $job_def_count = {
    "job1" => 0,
    "job2" => 1,
    "job3" => 2
};

sub get_job_result {
    my $job = shift;
    return $job_result->{$job};
}

sub get_def_count {
    my $job = shift;
    return $job_def_count->{$job};
}

1;
