#!/usr/bin/python3
"""CLI script"""

import argparse
import sys

from super_collator.aligner import Aligner
from super_collator.ngrams import NGrams
from super_collator.token import SingleToken
from super_collator.super_collator import to_table


def build_parser(description: str) -> argparse.ArgumentParser:
    """Build the commandline parser."""
    parser = argparse.ArgumentParser(
        description=description,
        # don't wrap my description
        formatter_class=argparse.RawDescriptionHelpFormatter,
        fromfile_prefix_chars="@",
    )

    parser.add_argument(
        "-v",
        "--verbose",
        dest="verbose",
        action="count",
        help="increase output verbosity",
        default=0,
    )
    parser.add_argument(
        "inputs",
        metavar="TOKENS",
        type=str,
        nargs="+",
        help="the input strings to process",
    )

    return parser


def main():
    parser = build_parser(__doc__)
    args = parser.parse_args()
    aligner = Aligner()

    aa = [NGrams([s]).load(s, 2) for s in args.inputs[0].split()]
    for n, inp in enumerate(args.inputs[1:]):
        bb = [NGrams([s]).load(s, 2) for s in inp.split()]
        aa, bb, score = aligner.align(
            aa, bb, NGrams.similarity, lambda: NGrams(["-"] * n), lambda: NGrams(["-"])
        )
        aa = [NGrams.merge(a, b, list.__add__) for a, b in zip(aa, bb)]

    print(to_table(*zip(*[a.user_data for a in aa])).strip())
    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
