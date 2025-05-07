#!/usr/bin/perl
#use threads;
#use threads::shared;
#use re::engine::RE2 -max_mem => 8<<23; #64MiB
use utf8;
# use MeCab; # MeCab is used in the previous script, not this one
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");
# use Encode; # Not used in this script snippet

# this is where we'll save output files
my $output_dir_prefix = "output/";

# Open the raw Cabocha output file in append mode with UTF-8 encoding
open(FILE_0_CABOCHA, "+>>:utf8", $output_dir_prefix . "00_cabocha.txt") or die "Cannot open " . $output_dir_prefix . "00_cabocha.txt: $!";

my @input_chunks;
my @input_dependency;
my @input_chunksNER;
my @input_depNER;

my @input_tokenNER;
my @input_lemmaNER;

while (<>) {
        # Skip empty lines or lines containing only whitespace
    next if /^\s*$/;
#    utf8::decode($_);
    my $input = $_;

    # Write the raw input line to the new file before any modifications
    print FILE_0_CABOCHA $input;

    # Original modifications and processing start here
    $input =~ tr/\!/！/;
    $input =~ tr/\?/？/;
    $input =~ tr/\#/＃/;
    $input =~ tr/\./．/;

    chomp $input;

    # Assign input to variables for different processing paths
    my $input_chunks_var = $input;
    my $input_dependency_var = $input;
    my $input_chunksNER_var = $input;
    my $input_depNER_var = $input;
    my $input_tokenNER_var = $input;
    my $input_lemmaNER_var = $input;


    # only chunks
    $input_chunks_var =~ s/^\* 0.+$//;
    $input_chunks_var =~ s/^\*.+$/ /;
    $input_chunks_var =~ s/^(.+?)(\s|\t).+$/$1/;
    $input_chunks_var =~ s/^EOS$/\n/;
    push (@input_chunks, $input_chunks_var); # Push the processed scalar variable


    # dependency
    $input_dependency_var =~ s/^\* 0 (\-?[0-9]{1,}D).+$/$1｜/;
    $input_dependency_var =~ s/^\* [0-9]{1,} (\-?[0-9]{1,}D).+$/ $1｜/;
    $input_dependency_var =~ s/^(.+?)(\s|\t).+$/$1/;
    $input_dependency_var =~ s/^EOS$/\n/;
    push (@input_dependency, $input_dependency_var); # Push the processed scalar variable


    # chunks with named entities
    $input_chunksNER_var =~ s/^\* 0.+$//;
    $input_chunksNER_var =~ s/^\*.+$/ /;
    $input_chunksNER_var =~ s/^(.+?)(\s|\t).+(\s|\t)B\-(.+)$/$4/;
    $input_chunksNER_var =~ s/^(.+?)(\s|\t).+(\s|\t)I\-(.+)$//;
    $input_chunksNER_var =~ s/^(.+?)(\s|\t).+(\s|\t)O$/$1/;
    $input_chunksNER_var =~ s/^EOS$/\n/;
    push (@input_chunksNER, $input_chunksNER_var); # Push the processed scalar variable


    # dependency with named entities
    $input_depNER_var =~ s/^\* 0 (\-?[0-9]{1,}D).+$/$1｜/;
    $input_depNER_var =~ s/^\* [0-9]{1,} (\-?[0-9]{1,}D).+$/ $1｜/;
    $input_depNER_var =~ s/^(.+?)(\s|\t).+(\s|\t)B\-(.+)$/$4/;
    $input_depNER_var =~ s/^(.+?)(\s|\t).+(\s|\t)I\-(.+)$//;
    $input_depNER_var =~ s/^(.+?)(\s|\t).+(\s|\t)O$/$1/;
    $input_depNER_var =~ s/^EOS$/\n/;
    push (@input_depNER, $input_depNER_var); # Push the processed scalar variable


    # only tokens with NER

    # Copy input for tokenNER processing
    my $tokenNER_input = $input; # Use a separate variable for this processing path

    $tokenNER_input =~ s/^.+\t.+\t.+(ORGANIZATION|PERSON|LOCATION|ARTIFACT|DATE|TIME|MONEY|PERCENT)$/$1 /g;
    $tokenNER_input =~ s/^\* [0-9].+$//g;
    $tokenNER_input =~ s/^(.+?)\t.+\t.+$/$1 /g;
    $tokenNER_input =~ s/\s\n//;
    $tokenNER_input =~ s/^EOS$/\n/;

    push (@input_tokenNER, $tokenNER_input); # Push the processed scalar variable


    # Lemma with NER logic
    my $lemmaNER_input = $input; # Use a separate variable for this processing path

    if ($lemmaNER_input =~ /EOS/g) {
        push (@input_lemmaNER, "\n"); # Pushes a newline if EOS is found in the line
    }


    my @fields = split(/\t/, $lemmaNER_input); # Split by tab first (surface and feature)
    my $token_val = $fields[0] // ''; # Surface form
    my $feature_string = $fields[1] // ''; # Feature string
    my $ner_tag = $fields[2] // ''; # NER tag (B-TYPE or I-TYPE or O)

    my @feature_elements = split(/,/, $feature_string); # Split feature string by comma
    my $lemma_val = $feature_elements[6] // '*'; # Genkei (lemma) is the 7th field (index 6)

    # Clean up NER tag
    $ner_tag =~ s/^(B|I)\-//; # Remove B- or I- prefix

    # Apply logic based on NER tag or lemma/token
    if ($ner_tag =~ m/(ORGANIZATION|PERSON|LOCATION|ARTIFACT|DATE|TIME|MONEY|PERCENT)/g){
        push (@input_lemmaNER, $ner_tag.' '); # Push just the NER type if found
    } elsif ($lemma_val !~ m/\*/) { # If lemma is not '*'
        push (@input_lemmaNER, $lemma_val.' '); # Push the lemma
    } else { # If lemma is '*'
        push (@input_lemmaNER, $token_val.' '); # Push the token (surface form)
    }
    # End of original lemmaNER logic structure per line


} # End of while (<>) loop

# Close the raw Cabocha output file after processing all sentences
close FILE_0_CABOCHA;


foreach my $index (0 .. $#input_tokenNER){ # Use $#array for last index
    # Check if current element is an NER tag
    if ($input_tokenNER[$index]=~m/(ORGANIZATION|PERSON|LOCATION|ARTIFACT|DATE|TIME|MONEY|PERCENT)/g){
       my $indy = $index+1;
       # While the next element exists and is the same as the current NER tag
       while ($indy <= $#input_tokenNER && $input_tokenNER[$index] eq $input_tokenNER[$indy]){
          splice @input_tokenNER, $indy, 1; # Remove the duplicate at $indy
          # Note: When splicing, the array shrinks, so the element that was at $indy+1 is now at $indy.
          # The while loop condition will re-check the new element at $indy. This logic seems correct for removing consecutive duplicates.
       }
    }
}

foreach my $index (0 .. $#input_lemmaNER){ # Use $#array for last index
    # Check if current element is an NER tag
    if ($input_lemmaNER[$index]=~m/(ORGANIZATION|PERSON|LOCATION|ARTIFACT|DATE|TIME|MONEY|PERCENT)/g){
       my $indy = $index+1;
       # While the next element exists and is the same as the current NER tag
       while ($indy <= $#input_lemmaNER && $input_lemmaNER[$index] eq $input_lemmaNER[$indy]){
          # print "gotcha!\n"; # Debug print
          splice @input_lemmaNER, $indy, 1; # Remove the duplicate at $indy
          # Note: Similar logic for removing consecutive duplicates as above.
       }
    }
}

# Open and write to the output files (already in append mode)
# Added :utf8 layer to open calls for explicit UTF-8 handling
open(FILE_1, "+>>:utf8", $output_dir_prefix . "06_chunks.txt") or die "Cannot open " . $output_dir_prefix . "06_chunks.txt: $!";
print FILE_1 @input_chunks;
close FILE_1;

open(FILE_2, "+>>:utf8", $output_dir_prefix . "07_dependency.txt") or die "Cannot open " . $output_dir_prefix . "07_dependency.txt: $!";
print FILE_2 @input_dependency;
close FILE_2;

open(FILE_3, "+>>:utf8", $output_dir_prefix . "08_chunksNER.txt") or die "Cannot open " . $output_dir_prefix . "08_chunksNER.txt: $!";
print FILE_3 @input_chunksNER;
close FILE_3;

open(FILE_4, "+>>:utf8", $output_dir_prefix . "09_depNER.txt") or die "Cannot open " . $output_dir_prefix . "09_depNER.txt: $!";
print FILE_4 @input_depNER;
close FILE_4;

open(FILE_5, "+>>:utf8", $output_dir_prefix . "10_tokenNER.txt") or die "Cannot open " . $output_dir_prefix . "10_tokenNER.txt: $!";
print FILE_5 @input_tokenNER;
close FILE_5;

open(FILE_6, "+>>:utf8", $output_dir_prefix . "11_lemmaNER.txt") or die "Cannot open " . $output_dir_prefix . "11_lemmaNER.txt: $!";
print FILE_6 @input_lemmaNER;
close FILE_6;

__END__
