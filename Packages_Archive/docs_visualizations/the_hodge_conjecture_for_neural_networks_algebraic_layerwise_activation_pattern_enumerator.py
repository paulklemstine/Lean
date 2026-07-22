from itertools import product
from typing import Iterator, Sequence

def activation_pattern_count(widths: Sequence[int]) -> int:
    """Count all Boolean states of all hidden units."""
    if any(w < 0 for w in widths):
        raise ValueError("widths must be nonnegative")
    return 2 ** sum(widths)

def activation_patterns(widths: Sequence[int]) -> Iterator[tuple[int, ...]]:
    """Generate patterns lazily; output size is exponential."""
    if any(w < 0 for w in widths):
        raise ValueError("widths must be nonnegative")
    yield from product((0, 1), repeat=sum(widths))

widths = (2, 3, 1)
P = activation_pattern_count(widths)
print(P, 3 * P)
