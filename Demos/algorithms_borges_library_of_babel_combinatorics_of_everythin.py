#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Library of Babel combinatorics.

Type-hinted implementations of the key mathematical structures and algorithms.
"""

from __future__ import annotations
from typing import Callable, Sequence
from dataclasses import dataclass
import math
import itertools


# =============================================================================
# Core Types
# =============================================================================

Book = tuple[int, ...]  # A book: tuple of symbol indices
Substitution = Callable[[int], int]  # An alphabet endomorphism


@dataclass(frozen=True)
class BabelSpace:
    """The space of all books over a given alphabet and length."""
    alpha: int  # alphabet size
    N: int      # book length

    @property
    def cardinality(self) -> int:
        """Total number of books: α^N."""
        return self.alpha ** self.N

    @property
    def cardinality_log10(self) -> float:
        """Number of decimal digits in the cardinality."""
        return self.N * math.log10(self.alpha)


# =============================================================================
# Hamming Distance
# =============================================================================

def hamming_distance(b1: Book, b2: Book) -> int:
    """Compute Hamming distance between two books.

    Time complexity: O(N)
    """
    if len(b1) != len(b2):
        raise ValueError("Books must have equal length")
    return sum(1 for x, y in zip(b1, b2) if x != y)


def hamming_ball_volume(alpha: int, N: int, r: int) -> int:
    """Exact volume of a Hamming ball of radius r in Book(α, N).

    |B(b, r)| = Σ_{k=0}^{r} C(N, k) (α-1)^k
    """
    return sum(math.comb(N, k) * (alpha - 1) ** k for k in range(r + 1))


# =============================================================================
# Substitution Algebra
# =============================================================================

def apply_substitution(sigma: dict[int, int], book: Book) -> Book:
    """Apply an alphabet substitution to a book.

    Time complexity: O(N)
    """
    return tuple(sigma[c] for c in book)


def compose_substitutions(sigma: dict[int, int], tau: dict[int, int]) -> dict[int, int]:
    """Compose two substitutions: (σ ∘ τ)(c) = σ(τ(c)).

    Time complexity: O(α)
    """
    return {c: sigma[tau[c]] for c in tau}


def is_injective(sigma: dict[int, int]) -> bool:
    """Check if a substitution is injective.

    Time complexity: O(α)
    """
    return len(set(sigma.values())) == len(sigma)


# =============================================================================
# Orbit Computation
# =============================================================================

def compute_orbit(book: Book, alpha: int) -> set[Book]:
    """Compute the full substitution orbit of a book.

    Time complexity: O(α^α · N)
    """
    orbit: set[Book] = set()
    for sub_tuple in itertools.product(range(alpha), repeat=alpha):
        sigma = dict(enumerate(sub_tuple))
        orbit.add(apply_substitution(sigma, book))
    return orbit


def symbol_diversity(book: Book) -> int:
    """Number of distinct symbols used in a book.

    Time complexity: O(N)
    """
    return len(set(book))


def predicted_orbit_size(alpha: int, diversity: int) -> int:
    """Predicted orbit size from the Orbit-Diversity Conjecture.

    Returns α^(d) = α! / (α - d)! (falling factorial).
    """
    return math.perm(alpha, diversity)


# =============================================================================
# Compression Analysis
# =============================================================================

@dataclass
class CompressionScheme:
    """A faithful compression scheme."""
    compress: Callable[[Book], Book]
    decompress: Callable[[Book], Book]

    def verify_faithful(self, books: Sequence[Book]) -> bool:
        """Verify faithfulness on a set of test books."""
        return all(self.decompress(self.compress(b)) == b for b in books)


def compressible_fraction_bound(alpha: int, N: int, M: int) -> float:
    """Upper bound on the fraction of compressible books.

    At most α^M books can be compressed to length M,
    out of α^N total books. Fraction ≤ α^(M-N).
    """
    if M >= N:
        return 1.0
    return alpha ** (M - N)


def incompressible_count_lower_bound(alpha: int, N: int, M: int) -> int:
    """Lower bound on the number of incompressible books.

    At least α^N - α^M books cannot be faithfully compressed to length M.
    """
    if M >= N:
        return 0
    return alpha ** N - alpha ** M


# =============================================================================
# Spectrum Analysis
# =============================================================================

def symbol_frequencies(book: Book, alpha: int) -> list[int]:
    """Compute the frequency of each symbol in a book.

    Returns a list of length α where freq[c] = |{i : book[i] = c}|.
    Time complexity: O(N)
    """
    freq = [0] * alpha
    for c in book:
        freq[c] += 1
    return freq


def is_uniform(book: Book, alpha: int) -> bool:
    """Check if a book uses all symbols with equal frequency.

    Time complexity: O(N)
    """
    freq = symbol_frequencies(book, alpha)
    return len(set(freq)) <= 1


# =============================================================================
# Hamming Graph
# =============================================================================

def hamming_path(b1: Book, b2: Book) -> list[Book]:
    """Construct an explicit Hamming path from b1 to b2.

    Changes one position at a time, in order.
    Time complexity: O(N²) for the path construction.
    """
    path = [b1]
    current = list(b1)
    for i in range(len(b1)):
        if current[i] != b2[i]:
            current[i] = b2[i]
            path.append(tuple(current))
    return path


def hamming_diameter(alpha: int, N: int) -> int:
    """The diameter of the Hamming graph.

    Equals N when α ≥ 2, else 0.
    """
    if alpha < 2 or N < 1:
        return 0
    return N


# =============================================================================
# Topological Analysis
# =============================================================================

def cylinder_set(alpha: int, N: int, position: int, symbol: int) -> set[Book]:
    """Enumerate the cylinder set C(position, symbol) for small spaces.

    Only practical for small α and N.
    """
    result: set[Book] = set()
    for book in itertools.product(range(alpha), repeat=N):
        if book[position] == symbol:
            result.add(book)
    return result


def verify_clopen_separation(alpha: int, N: int) -> bool:
    """Verify clopen separation for all distinct pairs in Book(α, N).

    For every pair of distinct books, find a cylinder set separating them.
    Only practical for small α and N.
    """
    books = list(itertools.product(range(alpha), repeat=N))
    for i, b1 in enumerate(books):
        for b2 in books[i+1:]:
            # Find a separating position
            separated = False
            for pos in range(N):
                if b1[pos] != b2[pos]:
                    separated = True
                    break
            if not separated:
                return False  # Should never happen for distinct books
    return True


if __name__ == "__main__":
    # Quick self-test
    space = BabelSpace(alpha=25, N=1_312_000)
    print(f"Library of Babel: {space.cardinality_log10:.0f} decimal digits")

    b1 = (0, 1, 2, 0, 1)
    b2 = (0, 2, 2, 1, 1)
    print(f"Hamming distance: {hamming_distance(b1, b2)}")
    print(f"Path: {hamming_path(b1, b2)}")
    print(f"Diversity of b1: {symbol_diversity(b1)}")

    orbit = compute_orbit((0, 1, 0), alpha=3)
    print(f"Orbit of (0,1,0) in Book(3,3): size={len(orbit)}, "
          f"predicted={predicted_orbit_size(3, symbol_diversity((0,1,0)))}")
