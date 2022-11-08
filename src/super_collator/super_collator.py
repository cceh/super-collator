"""Main module."""

from typing import Sequence


def to_string(seq: Sequence, f=str):
    """Convert a sequence of tokens into a string.

    This function calls f(t) on each token t.
    """
    return " ".join([f(t) for t in seq])


def transpose(*sequences):
    """Transpose a matrix."""
    return list(zip(*sequences))


def to_table(*sequences: Sequence[str]):
    """Convert sequences of aligned strings into an ascii table."""
    strings_columnwise = transpose(*sequences)
    column_widths = [max(map(len, col)) for col in strings_columnwise]

    result = []
    for row in sequences:
        for s, length in zip(row, column_widths):
            result.append(f"{str(s):<{length + 1}}")
        result.append("\n")
    return "".join(result)
