#!/bin/bash
set -e

perl mecab_extractor_better.pl $1
wait
cabocha -f1 -n1 -d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd $1 > output.txt # hard-coded assumption of where neologd is
wait
#perl cabocha_extractor.pl output.txt
perl cabocha_extractor_upgraded.pl output.txt
rm output.txt

perl cleaner.pl 10_tokenNER.txt
perl cleaner.pl 10_tokenNER.txt
perl cleaner.pl 11_lemmaNER.txt
perl cleaner.pl 11_lemmaNER.txt


