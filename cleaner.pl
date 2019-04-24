#!/usr/bin/perl
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");
use open ':std', ':encoding(UTF-8)';

my $filename = $ARGV[0];
my @output;

while (<>) {
utf8::decode($_);
my $input = $_;
chomp $input;
$input =~ s/^ | $//g;
$input =~ s/  / /g;
push (@output, $input."\n");
}

open(FILE_1, ">", "$filename") or die "Cannot open $file: $!";
print FILE_1 @output;
close FILE_1;

__END__
