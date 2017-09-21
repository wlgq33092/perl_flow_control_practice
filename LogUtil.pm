#! /usr/bin/perl

use Data::Dumper;

package LogUtil;

sub dump {
    my $self = shift;
    my $prefix = shift;
    my $dump_obj = shift;

    print $prefix, &main::Dumper($dump_obj);
}

1;
