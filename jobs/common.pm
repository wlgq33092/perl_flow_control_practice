#! /usr/bin/perl

use POSIX qw(:sys_wait_h);

package common;

my $config;
my $name2job;

sub set_config {
    $config = $_[0];
}

sub set_jobs {
    $name2job = shift;
}

sub run_condition {
    my $job_name = shift;
    my $condition = shift;
    my @args = @_;

    print "stwu run condition args: $_\n" foreach (@args);
    print "run condition:\n";
    print "job name: $job_name, condition: $condition, args: @args.\n";

    my $job = $name2job->{$job_name};

    my $jobtype = $job->{type};
    my $module = $jobtype . ".pm";

    require $module;

    return $job->$condition(@args);
}

my $job_result = {
    "joba" => 1,
    "jobb" => 1,
    "jobc" => 1,
    "END"  => 1,
    "job1" => 1,
    "job2" => 1,
    "job3" => 1,
    "job4" => 1,
    "job5" => 1,
    "job6" => 1,
    "job7" => 1
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

sub run_to_done {
    my $pid = shift;
    my $ret = waitpid($pid, WNOHANG);
    if ($pid == $ret) {
        return 1;
    } else {
        return 0;
    }
}

sub async_run {
    my $cmd = shift;

    my $grandchild;
    my $pid = fork();
    if ($pid > 0) {
        return $pid;
    } elsif (0 == pid) {
        exec $cmd;
    } else {
        print "Fork child process for async run error.\n";
    }
}

package TfelxCommon;

sub submitjob {

}

1;
