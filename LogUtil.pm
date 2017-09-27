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

1;
