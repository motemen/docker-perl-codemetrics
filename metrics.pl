#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Perl::Metrics::Simple;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

sub usage {
    print STDERR qq(metrics.pl [--format "json" | "sensu"] <path>\n);
    exit 2;
}

GetOptions (
    'format=s' => \(my $format = 'json'),
    'prefix=s' => \(my $prefix = 'source.'),
) or usage();

my $time = time;

my $FORMATTER = {
    json => sub {
        my $result = shift;
        return JSON->new->utf8->pretty->encode($result) . "\n";
    },
    sensu => sub {
        my $result = shift;
        my @lines;
        foreach my $key (sort keys %$result) {
            push @lines, join "\t", ($key, $result->{$key}, $time);
        }
        return join("\n", @lines) . "\n";
    },
};

my $formatter = $FORMATTER->{$format} or usage();

my $path = shift or usage();

my $metrics = Perl::Metrics::Simple->new->analyze_files($path);

my $result = {
    "${prefix}count.file"             => 0+$metrics->file_count,
    "${prefix}count.func"             => 0+$metrics->sub_count,
    "${prefix}count.line"             => 0+$metrics->lines,
    "${prefix}count.package"          => 0+$metrics->package_count,
    "${prefix}func_complexity.max"    => 0+$metrics->summary_stats->{sub_complexity}->{max},
    "${prefix}func_complexity.mean"   => 0+$metrics->summary_stats->{sub_complexity}->{mean},
    "${prefix}func_complexity.median" => 0+$metrics->summary_stats->{sub_complexity}->{median},
    "${prefix}func_length.max"        => 0+$metrics->summary_stats->{sub_length}->{max},
    "${prefix}func_length.mean"       => 0+$metrics->summary_stats->{sub_length}->{mean},
    "${prefix}func_length.median"     => 0+$metrics->summary_stats->{sub_length}->{median},
};

print $formatter->($result);
