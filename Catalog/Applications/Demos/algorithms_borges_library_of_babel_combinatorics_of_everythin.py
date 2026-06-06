#!/usr/bin/env python3
"""
Algorithms for the Library of Babel.

Type-hinted implementations of key algorithms from the research.
"""

import math
from typing import List, Dict, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class BabelBook:
    """A book in the Library of Babel."""
    symbols: List[int]
    alphabet_size: int

    def __post_init__(self):
        assert all(0 <= s < self.alphabet_size for s in self.symbols)

    @property
    def length(self) -> int:
        return len(self.symbols)


def hamming_distance(b1: BabelBook, b2: BabelBook) -> int:
    """Compute the Hamming distance between two books.

    Time complexity: O(N)
    Space complexity: O(1)
    """
    assert b1.length == b2.length
    assert b1.alphabet_size == b2.alphabet_size
    return sum(1 for s1, s2 in zip(b1.symbols, b2.symbols) if s1 != s2)


def hamming_ball_volume(alpha: int, n: int, t: int) -> int:
    """Compute the volume of a Hamming ball of radius t.

    V(n, t) = Σ_{k=0}^{t} C(n, k) * (α-1)^k

    Time complexity: O(t)
    """
    return sum(math.comb(n, k) * (alpha - 1) ** k for k in range(t + 1))


def singleton_bound(alpha: int, n: int, d: int) -> int:
    """Compute the Singleton bound on code size.

    A code with minimum distance d has at most α^(N-d+1) codewords.
    Achieved by MDS codes (e.g., Reed-Solomon).

    Time complexity: O(1)
    """
    return alpha ** (n - d + 1)


def sphere_packing_bound(alpha: int, n: int, d: int) -> float:
    """Compute the sphere-packing (Hamming) bound on code size.

    |C| ≤ α^N / V(N, ⌊(d-1)/2⌋)

    Time complexity: O(d)
    """
    t = (d - 1) // 2
    vol = hamming_ball_volume(alpha, n, t)
    return alpha ** n / vol


def compressible_fraction(alpha: int, n: int, m: int) -> float:
    """Compute the maximum fraction of books compressible to length M.

    At most α^M / α^N = α^{-(N-M)} books are compressible.

    Time complexity: O(1)
    """
    return alpha ** (m - n)


def symbol_spectrum(book: BabelBook) -> Dict[int, int]:
    """Compute the symbol frequency spectrum of a book.

    Time complexity: O(N)
    """
    spectrum: Dict[int, int] = {}
    for s in book.symbols:
        spectrum[s] = spectrum.get(s, 0) + 1
    return spectrum


def is_uniform(book: BabelBook) -> bool:
    """Check if a book has uniform symbol distribution.

    Time complexity: O(N)
    """
    spec = symbol_spectrum(book)
    if not spec:
        return True
    values = list(spec.values())
    return all(v == values[0] for v in values)


@dataclass
class CompressionScheme:
    """A faithful compression scheme."""
    compress: Callable[[BabelBook], BabelBook]
    decompress: Callable[[BabelBook], BabelBook]

    def verify_faithful(self, book: BabelBook) -> bool:
        """Verify compress(decompress(b)) == b for a specific book."""
        compressed = self.compress(book)
        decompressed = self.decompress(compressed)
        return decompressed.symbols == book.symbols


def apply_coord_permutation(book: BabelBook, perm: List[int]) -> BabelBook:
    """Apply a coordinate permutation to a book.

    Theorem: This is a Hamming isometry (coord_perm_isometry).

    Time complexity: O(N)
    """
    return BabelBook(
        symbols=[book.symbols[perm[i]] for i in range(book.length)],
        alphabet_size=book.alphabet_size
    )


def apply_symbol_permutation(
    book: BabelBook, perm: List[int]
) -> BabelBook:
    """Apply a symbol permutation to all positions of a book.

    Theorem: This is a Hamming isometry (symbol_perm_isometry).

    Time complexity: O(N)
    """
    return BabelBook(
        symbols=[perm[s] for s in book.symbols],
        alphabet_size=book.alphabet_size
    )


def apply_pointwise_permutation(
    book: BabelBook, perms: List[List[int]]
) -> BabelBook:
    """Apply position-dependent symbol permutations.

    Theorem: This is a Hamming isometry (pointwise_perm_isometry).

    Time complexity: O(N)
    """
    return BabelBook(
        symbols=[perms[i][book.symbols[i]] for i in range(book.length)],
        alphabet_size=book.alphabet_size
    )


def log_library_size(alpha: int, n: int) -> float:
    """Compute log₁₀ of library size = N · log₁₀(α)."""
    return n * math.log10(alpha)


if __name__ == "__main__":
    # Quick self-test
    b1 = BabelBook([0, 1, 2, 0, 1], 3)
    b2 = BabelBook([0, 1, 0, 0, 2], 3)
    print(f"Hamming distance: {hamming_distance(b1, b2)}")
    print(f"Spectrum b1: {symbol_spectrum(b1)}")
    print(f"Is uniform b1: {is_uniform(b1)}")
    print(f"Singleton bound (3,5,3): {singleton_bound(3, 5, 3)}")
    print(f"Sphere-packing bound (2,7,3): {sphere_packing_bound(2, 7, 3)}")
    print(f"Hamming ball V(7,1): {hamming_ball_volume(2, 7, 1)}")
