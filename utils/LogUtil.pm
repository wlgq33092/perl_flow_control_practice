#! /usr/bin/perl

use Data::Dumper;

package LogUtil;

sub dump {
    my $prefix = shift;
    my $dump_obj = shift;

    if (ref $dump_obj eq "HASH") {
        print $prefix, &main::Dumper(%{$dump_obj});
    } elsif (ref $dump_obj eq "ARRAY") {
        print $prefix, &main::Dumper(@{$dump_obj});
    } else {
        print $prefix, &main::Dumper($dump_obj);
    }
}

sub print_hash {
    my $my_hash = shift;
    my $name = shift;
    my %target = %{$my_hash};

    print "print hash $name start:\n";
    foreach my $key (keys %target) {
        print "key is $key, value is $target{$key}\n";
    }
    print "print hash $name end.\n";
}

sub print_array {
    my $my_array = shift;
    my $name = shift;
    my @target = @{$my_array};

    print "print array $name start:\n";
    foreach my $item (@target) {
        print "$item\n";
    }
    print "print array $name end.\n";
}


package LogJob;

sub new {
    my $class = shift;
    my $file = shift;

    my $obj = {
        "file" => $file
    };

    my $fd;
    open($fd, ">$file") || die "Create job log error.\n";

    $obj->{handler} = $fd;

    bless $obj, $class;
}

sub log_print {
    my $self = shift;
    my $msg = shift;
    my $fd = $self->{handler};

    print $fd $msg;
}

sub DESTROY {
    my $self = shift;
    close($self->{handler});
}

1;
