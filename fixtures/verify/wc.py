#!/usr/bin/env python3
"""Tiny word-counting subject for the /verify fixture.

Seeded state, deliberate: `count` handles contractions correctly (1.2 holds)
but `longest` returns the FIRST longest word by scan order rather than the
longest one, so 1.3's acceptance fails. 1.1 holds.
"""
import re
import sys


def words(s):
    # apostrophe inside the class, so "don't" is one word
    return re.findall(r"[A-Za-z']+", s)


def main(argv):
    if len(argv) < 3:
        sys.exit("usage: wc.py <count|longest> <text>")
    cmd, text = argv[1], argv[2]
    w = words(text)
    if cmd == "count":
        print(len(w))
    elif cmd == "longest":
        # DEFECT (seeded): returns the first word, not the longest
        print(w[0] if w else "")
    else:
        sys.exit(f"unknown command: {cmd}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
