#!/bin/bash
set -e

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_DIR="output"
CABOCHA_OUTPUT_FILE="$OUTPUT_DIR/output.txt" # Define the path for cabocha's temporary output

# Create the output directory if it doesn't exist
echo "--- Setting up output directory ---"
mkdir -p "$OUTPUT_DIR"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found :("
    exit 1
fi
echo "--- Setup complete ---"

echo "--- Running mecab_extractor_better.pl ---"
perl mecab_extractor_better.pl "$INPUT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: mecab_extractor_better.pl failed."
    exit 1
fi
echo "--- mecab_extractor_better.pl finished ---"
wait

echo "--- Running cabocha ---"
cabocha -f1 -n1 -d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd "$INPUT_FILE" > "$CABOCHA_OUTPUT_FILE" # hard-coded assumption of where neologd is
if [ $? -ne 0 ]; then
    echo "Error: cabocha failed."
    exit 1
fi
echo "--- cabocha finished ---"
wait

# Check if cabocha produced output
if [ ! -f "$CABOCHA_OUTPUT_FILE" ]; then
    echo "Error: Cabocha output file '$CABOCHA_OUTPUT_FILE' was not created."
    exit 1
fi


echo "--- Running cabocha_extractor_upgraded.pl ---"
perl cabocha_extractor_upgraded.pl < "$CABOCHA_OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: cabocha_extractor_upgraded.pl failed."
    exit 1
fi
echo "--- cabocha_extractor_upgraded.pl finished ---"

# Clean up the temporary cabocha output file
echo "--- Cleaning up temporary file ---"
rm "$CABOCHA_OUTPUT_FILE"
echo "--- Cleanup complete ---"

# the following comments were added by gemini 2.5 flash but i thought they were hilarious
#perl cleaner.pl 10_tokenNER.txt # Processes these specific files
#perl cleaner.pl 10_tokenNER.txt # ...twice?
#perl cleaner.pl 11_lemmaNER.txt
#perl cleaner.pl 11_lemmaNER.txt
echo "--- Running cleaner.pl ---"
cat "$OUTPUT_DIR/10_tokenNER.txt" | perl cleaner.pl "$OUTPUT_DIR/10_tokenNER.txt"
if [ $? -ne 0 ]; then
    echo "Error: cleaner.pl failed on 10_tokenNER.txt."
    exit 1
fi
cat "$OUTPUT_DIR/11_lemmaNER.txt" | perl cleaner.pl "$OUTPUT_DIR/11_lemmaNER.txt"
if [ $? -ne 0 ]; then
    echo "Error: cleaner.pl failed on 11_lemmaNER.txt."
    exit 1
fi
echo "--- cleaner.pl finished ---"

echo "Processing complete. Output files are in the '$OUTPUT_DIR' directory. Thank you for using this tool!!"

