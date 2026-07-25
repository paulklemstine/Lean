#!/usr/bin/env python3
"""Numerical demonstrations for commensurability counting and Coxeter data.

The program uses only the Python standard library.  It demonstrates:
1. the range of Coxeter Gram entries -cos(pi/m);
2. the decorated binary model with 2^n classes and two objects per class;
3. conversion of a linear volume bound A*n+B into an exponential class bound.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from math import cos, exp, log, pi
from typing import Dict, Iterable, List, Sequence, Tuple

Word = Tuple[int, ...]


@dataclass(frozen=True)
class DecoratedWord:
    """A binary structural word with an equivalence-invisible decoration."""

    word: Word
    decoration: int


def binary_words(n: int) -> Iterable[Word]:
    """Generate all binary words of length n in lexicographic integer order."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    for value in range(1 << n):
        yield tuple((value >> shift) & 1 for shift in reversed(range(n)))


def decorated_family(n: int) -> List[DecoratedWord]:
    """Return both decorations of every binary word of length n."""
    return [DecoratedWord(word, decoration) for word in binary_words(n)
            for decoration in (0, 1)]


def invariant(obj: DecoratedWord) -> Word:
    """Return the structural word, which is constant on model classes."""
    return obj.word


def model_volume(obj: DecoratedWord) -> int:
    """Return Hamming weight, the model's linearly bounded volume."""
    return sum(obj.word)


def class_histogram(n: int) -> Dict[Word, int]:
    """Count objects in each class, keyed by the invariant word."""
    return dict(Counter(invariant(obj) for obj in decorated_family(n)))


def gram_entry(m: int) -> float:
    """Compute the intersecting-facet Gram entry -cos(pi/m), m >= 2."""
    if m < 2:
        raise ValueError("a Coxeter order must satisfy m >= 2")
    return -cos(pi / m)


def gram_table(orders: Sequence[int]) -> List[Tuple[int, float, bool]]:
    """Compute entries and numerically test membership in (-1, 0]."""
    return [(m, gram_entry(m), -1.0 < gram_entry(m) <= 0.0) for m in orders]


def volume_class_bound(n: int, a: float = 1.0, b: float = 0.0) -> Tuple[float, int, float]:
    """Return V=A*n+B, 2^n, and exp((log 2/A)(V-B))."""
    if n < 0 or a <= 0 or b < 0:
        raise ValueError("require n >= 0, A > 0, and B >= 0")
    volume = a * n + b
    classes = 1 << n
    analytic = exp((log(2.0) / a) * (volume - b))
    return volume, classes, analytic


def run_demo(max_n: int = 10) -> None:
    """Print three reproducible numerical demonstrations."""
    print("COXETER GRAM ENTRIES")
    print("m   -cos(pi/m)       in (-1, 0]")
    for m, entry, valid in gram_table([2, 3, 4, 5, 6, 8, 12, 50]):
        print(f"{m:2d}  {entry: .10f}    {valid}")

    print("\nDECORATED BINARY MODEL")
    print("n  objects  classes  class size  max volume  1+n log(2) <= 2^n")
    for n in range(max_n + 1):
        family = decorated_family(n)
        histogram = class_histogram(n)
        sizes = set(histogram.values())
        max_volume = max((model_volume(x) for x in family), default=0)
        inequality = 1.0 + n * log(2.0) <= float(1 << n) + 1e-12
        class_size = sizes.pop() if len(sizes) == 1 else -1
        print(f"{n:2d} {len(family):8d} {len(histogram):8d} {class_size:11d} "
              f"{max_volume:11d} {str(inequality):>10}")
        assert len(family) == 2 ** (n + 1)
        assert len(histogram) == 2 ** n
        assert class_size == 2
        assert max_volume <= n
        assert inequality

    print("\nLINEAR VOLUME TO EXPONENTIAL CLASSES (A=2.5, B=3)")
    print("n   volume   classes   exponential expression")
    for n in range(max_n + 1):
        volume, classes, analytic = volume_class_bound(n, 2.5, 3.0)
        print(f"{n:2d} {volume:8.2f} {classes:9d} {analytic:24.6f}")
        assert abs(classes - analytic) < 1e-8 * max(1, classes)


if __name__ == "__main__":
    run_demo()
