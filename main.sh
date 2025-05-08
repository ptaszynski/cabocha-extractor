#!/bin/bash
set -e

INPUT_FILE="$1"
OUTPUT_DIR="output"
CABOCHA_OUTPUT_FILE="$OUTPUT_DIR/output.txt" # Define the path for cabocha's temporary output

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

perl mecab_extractor_better.pl "$INPUT_FILE"
wait
cabocha -f1 -n1 -d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd "$INPUT_FILE" > "$CABOCHA_OUTPUT_FILE" # hard-coded assumption of where neologd is
wait
#perl cabocha_extractor.pl output.txt
perl cabocha_extractor_upgraded.pl < "$CABOCHA_OUTPUT_FILE"
rm "$CABOCHA_OUTPUT_FILE"

# the following comments were added by gemini 2.5 flash but i thought they were hilarious
#perl cleaner.pl 10_tokenNER.txt # Processes these specific files
#perl cleaner.pl 10_tokenNER.txt # ...twice?
#perl cleaner.pl 11_lemmaNER.txt
#perl cleaner.pl 11_lemmaNER.txt

cat "$OUTPUT_DIR/10_tokenNER.txt" | perl cleaner.pl "$OUTPUT_DIR/10_tokenNER.txt"
cat "$OUTPUT_DIR/11_lemmaNER.txt" | perl cleaner.pl "$OUTPUT_DIR/11_lemmaNER.txt"


