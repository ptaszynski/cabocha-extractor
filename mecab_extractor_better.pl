#!/usr/bin/perl
use strict;
use warnings;
use utf8;                                   # source is in UTF-8
use open ':encoding(UTF-8)', ':std';       # make STDIN/STDOUT/STDERR UTF-8
use MeCab;
use Encode qw(decode);


# this is where we'll save output files
my $output_dir_prefix = "output/";

# Open the raw MeCab output file in append mode
open my $fh0, '>>:encoding(UTF-8)', $output_dir_prefix . "00_mecab.txt" or die "Cannot open ${output_dir_prefix}00_mecab.txt: $!";

while (<>) {
    # Skip empty lines or lines containing only whitespace
    next if /^\s*$/;

    my @final_output;

    my $input = $_;
    $input =~ tr/\!/！/;
    $input =~ tr/\?/？/;
    chomp $input;
    my $input_mecab = $input;
    push(@final_output, $input);

    #mecab trick.
    my @input_lemmas;
    my @found_interjections;
    my @input_lemma_no_emo;
    my @input_tokens;
    my @input_pos;
    my @input_tokenpos;
    my @input_lemmapos;
    my @raw_mecab_output_sentence; # store raw MeCab output for the current sentence

    my $mecab = MeCab::Tagger->new("-d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd");
    my $node = $mecab->parseToNode($input_mecab);
    for( ; $node; $node = $node->{next} ) {
        next unless defined $node->{surface};

    # decode to Perl’s internal form
    my $midasi_raw    = $node->{surface};
    my $feature_raw   = $node->{feature};

    # decode
    my $midasi  = decode("UTF-8", $midasi_raw);
    my $feature = decode("UTF-8", $feature_raw);

    # now we can safely split the feature on commas, since it's Unicode
    my ($hinsi,$kijutsu,$genkei) = (split(/,/, $feature))[0,1,6];

    push @raw_mecab_output_sentence, "$midasi\t$feature";
    push @input_tokens,  $midasi;


        if ($genkei eq '*'){
            $genkei = $midasi;
        }

        push (@input_lemmas, $genkei);
        push (@input_pos, $hinsi);
        push (@input_tokenpos, $midasi.'|'.$hinsi);
        push (@input_lemmapos, $genkei.'|'.$hinsi);
}

# Append the raw MeCab output for the current sentence to fh0 (file 0)
print $fh0 join("\n", @raw_mecab_output_sentence), "\nEOS\n";

# The original script removes the first and last tokens/lemmas/pos.
# This is usually to remove the BOS (Beginning of Sentence) and EOS (End of Sentence)
# nodes that MeCab adds. We captured the raw output *including* BOS/EOS above,
# but the subsequent processing in this script (and likely the next ones)
# expects them removed, so we keep this part.
shift @input_tokens; pop @input_tokens;
shift @input_lemmas; pop @input_lemmas;
shift @input_pos; pop @input_pos;
shift @input_tokenpos; pop @input_tokenpos;
shift @input_lemmapos; pop @input_lemmapos;

my $input_tokens = join (' ', @input_tokens);
my $input_lemmas = join (' ', @input_lemmas);
my $input_pos = join (' ', @input_pos);
my $input_tokenpos = join (' ', @input_tokenpos);
my $input_lemmapos = join (' ', @input_lemmapos);

open(my $fh1, '>>:encoding(UTF-8)', $output_dir_prefix . "01_tokenized.txt")
  or die "Cannot open " . $output_dir_prefix . "01_tokenized.txt: $!";
print $fh1 "$input_tokens\n";
close $fh1;

open(my $fh2, '>>:encoding(UTF-8)', $output_dir_prefix . "02_lemmatized.txt")
  or die "Cannot open " . $output_dir_prefix . "02_lemmatized.txt: $!";
print $fh2 "$input_lemmas\n";
close $fh2;

open(my $fh3, '>>:encoding(UTF-8)', $output_dir_prefix . "03_pos.txt")
  or die "Cannot open " . $output_dir_prefix . "03_pos.txt: $!";
print $fh3 "$input_pos\n";
close $fh3;

open(my $fh4, '>>:encoding(UTF-8)', $output_dir_prefix . "04_tokenPOS.txt")
  or die "Cannot open " . $output_dir_prefix . "04_tokenPOS.txt: $!";
print $fh4 "$input_tokenpos\n";
close $fh4;

open(my $fh5, '>>:encoding(UTF-8)', $output_dir_prefix . "05_lemmaPOS.txt")
  or die "Cannot open " . $output_dir_prefix . "05_lemmaPOS.txt: $!";
print $fh5 "$input_lemmapos\n";
close $fh5;

}

# Close the raw MeCab output file after processing all sentences
close $fh0;

__END__
