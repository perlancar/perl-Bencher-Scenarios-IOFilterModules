package Bencher::Scenario::IOFilterModules::Writing;

# DATE
# VERSION

use strict;
use warnings;
use File::Temp qw(tempfile);

our $scenario = {
    summary => 'Benchmark writing with filter that does nothing',

    description => <<'_',

Each participant will write `chunk_size` bytes (0, 1, and 1024) for 1000 times.

_

    modules => {
    },

    participants => [
        {
            module => 'Text::OutputFilter',
            code_template => <<'_',
open *FH0, ">", <tempfile> or die "Can't open: $!";
tie  *FH , "Text::OutputFilter", 0, *FH0, sub { $_[0] };
my $chunk = "a" x <chunk_size>;
for (1..1000) { print FH $chunk }
close FH;
die "Incorrect file size" unless (-s <tempfile>) == <chunk_size> * 1000;
_
        },
        {
            module => 'Tie::Handle::Filter',
            code_template => <<'_',
open *FH0, ">", <tempfile> or die "Can't open: $!";
tie  *FH , "Tie::Handle::Filter", *FH0, sub { @_ };
my $chunk = "a" x <chunk_size>;
for (1..1000) { print FH $chunk }
close FH;
die "Incorrect file size" unless (-s <tempfile>) == <chunk_size> * 1000;
_
        },
        {
            name => 'PerlIO::via',
            module => 'PerlIO::via::as_is',
            code_template => <<'_',
open my($fh), ">:via(as_is)", <tempfile>;
my $chunk = "a" x <chunk_size>;
for (1..1000) { print $fh $chunk }
close $fh;
die "Incorrect file size" unless (-s <tempfile>) == <chunk_size> * 1000;
_
        },
        {
            name => 'raw',
            code_template => <<'_',
open my($fh), ">", <tempfile>;
my $chunk = "a" x <chunk_size>;
for (1..1000) { print $fh $chunk }
close $fh;
die "Incorrect file size" unless (-s <tempfile>) == <chunk_size> * 1000;
_
        },
    ],

    # generate datasets
    before_list_datasets => sub {
        my %args = @_;
        my $scenario = $args{scenario};
        my $seq = 0;
        for my $chunk_size (0, 1, 1024) {
            my ($fh, $filename) = tempfile();
            push @{ $scenario->{datasets} }, {
                name => "chunk_size=$chunk_size",
                args => {chunk_size => $chunk_size, tempfile => $filename},
                seq => $seq++,
            };
        }
    },

    # generated dynamically
    datasets => undef,
};

1;
# ABSTRACT:

=head1 SEE ALSO
