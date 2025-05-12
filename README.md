# cabocha-extractor

[DESCRIPTION]

A tool for preprocessing of text data in Japanese for further machine learning. It uses MeCab for tokenization and part-of-speech tagging and Cabocha for shallow and deep parsing.

usage:

bash main.sh input_file.txt

[DEPENDENCIES]

MeCab, MeCab Perl binding, Cabocha, mecab-ipadic-neologd
Assumes neologd is present at /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd
