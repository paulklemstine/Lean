#!/usr/bin/env python3
"""
Algorithms for the Library of Babel: Combinatorial Topology

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import List, Dict, Tuple, Optional, Callable
import math


# --- Core Types ---

Symbol = int  # Elements of Fin(α), represented as 0..α-1
Book = List[Symbol]  # A book is a list of symbols


def make_book(symbols: List[int], alpha: int) -> Book:
    """Create a valid book, checking all symbols are in range."""
    assert all(0 <= s < alpha for s in symbols), f"All symbols must be in [0, {alpha})"
    return list(symbols)


# --- Hamming Distance ---

def hamming_distance(b1: Book, b2: Book) -> int:
    """
    Compute the Hamming distance between two books.
    
    Time complexity: O(N) where N = len(b1) = len(b2)
    Space complexity: O(1)
    
    Satisfies:
    - Symmetry: hamming_distance(b1, b2) == hamming_distance(b2, b1)
    - Identity: hamming_distance(b1, b2) == 0 iff b1 == b2
    - Triangle: hamming_distance(b1, b3) <= hamming_distance(b1, b2) + hamming_distance(b2, b3)
    - Bound: hamming_distance(b1, b2) <= len(b1)
    """
    assert len(b1) == len(b2), "Books must have equal length"
    return sum(1 for a, c in zip(b1, b2) if a != c)


def hamming_ball(center: Book, radius: int, alpha: int) -> int:
    """
    Count the number of books within Hamming distance r of center.
    
    |B(b, r)| = Σ_{k=0}^{r} C(N, k) · (α-1)^k
    
    This is the volume of a Hamming ball, used in sphere-packing bounds.
    """
    n = len(center)
    total = 0
    for k in range(min(radius, n) + 1):
        total += math.comb(n, k) * (alpha - 1) ** k
    return total


# --- Symbol Spectrum ---

def symbol_spectrum(book: Book, alpha: int) -> List[int]:
    """
    Compute the symbol frequency spectrum.
    
    Returns a list of length α where spectrum[c] = count of symbol c in book.
    Invariant: sum(spectrum) == len(book)
    
    Time: O(N), Space: O(α)
    """
    spectrum = [0] * alpha
    for s in book:
        spectrum[s] += 1
    return spectrum


def is_uniform(book: Book, alpha: int) -> bool:
    """Check if a book has uniform symbol distribution."""
    spec = symbol_spectrum(book, alpha)
    return len(set(spec)) <= 1


def spectrum_entropy(book: Book, alpha: int) -> float:
    """
    Compute the Shannon entropy of the book's symbol distribution.
    H = -Σ p_c log₂(p_c)
    
    Maximum entropy (log₂ α) indicates uniform distribution.
    """
    n = len(book)
    if n == 0:
        return 0.0
    spec = symbol_spectrum(book, alpha)
    entropy = 0.0
    for count in spec:
        if count > 0:
            p = count / n
            entropy -= p * math.log2(p)
    return entropy


# --- Incompressibility Analysis ---

def compressible_fraction(alpha: int, n: int, m: int) -> float:
    """
    Upper bound on the fraction of books compressible from length N to length M.
    
    fraction ≤ α^M / α^N = α^(M-N) = α^(-k) where k = N - M
    
    For α = 25, k = 1: fraction ≤ 0.04 (4%)
    For α = 25, k = 100: fraction ≤ 10^(-140)
    """
    if m >= n:
        return 1.0
    return alpha ** (m - n)


def incompressible_count_bound(alpha: int, n: int, m: int) -> Tuple[int, int]:
    """
    Return (min_incompressible, total) where min_incompressible is the minimum
    number of books that cannot be compressed from length N to length M.
    
    min_incompressible = α^N - α^M
    """
    total = alpha ** n
    compressible = alpha ** m
    return (total - compressible, total)


# --- Edit Operations ---

def single_edit(book: Book, position: int, new_symbol: Symbol) -> Book:
    """
    Create a new book by changing one character.
    The result has Hamming distance exactly 1 from the original
    (if new_symbol ≠ book[position]).
    """
    result = list(book)
    result[position] = new_symbol
    return result


def edit_path(b1: Book, b2: Book) -> List[Book]:
    """
    Construct a minimum-length edit path from b1 to b2.
    Each step changes exactly one character.
    Path length = hamming_distance(b1, b2) + 1.
    
    This witnesses the combinatorial connectivity of the Babel space.
    """
    assert len(b1) == len(b2)
    path = [list(b1)]
    current = list(b1)
    for i in range(len(b1)):
        if current[i] != b2[i]:
            current = list(current)
            current[i] = b2[i]
            path.append(current)
    return path


def count_neighbors(n: int, alpha: int) -> int:
    """
    Number of books at Hamming distance exactly 1 from any given book.
    Each of N positions can be changed to any of (α-1) alternative symbols.
    """
    return (alpha - 1) * n


# --- Topological Analysis ---

def clopen_set_membership(book: Book, position: int, symbol: Symbol) -> bool:
    """
    Check if a book belongs to the clopen basis set C(i, c) = {b : b[i] = c}.
    These sets form a clopen basis for the product topology,
    witnessing covering dimension 0.
    """
    return book[position] == symbol


def separate_books(b1: Book, b2: Book) -> Optional[Tuple[int, int, int]]:
    """
    Find a separating clopen set for two distinct books.
    Returns (position, b1[position], b2[position]) or None if books are equal.
    
    This witnesses total disconnectedness: any two distinct points
    are separated by a clopen set.
    """
    for i in range(len(b1)):
        if b1[i] != b2[i]:
            return (i, b1[i], b2[i])
    return None


# --- Babel Library Parameters ---

class BabelLibrary:
    """The Library of Babel with specific parameters."""
    
    def __init__(self, alpha: int = 25, pages: int = 410,
                 lines_per_page: int = 40, chars_per_line: int = 80):
        self.alpha = alpha
        self.pages = pages
        self.lines_per_page = lines_per_page
        self.chars_per_line = chars_per_line
        self.book_length = pages * lines_per_page * chars_per_line
    
    @property
    def total_books_log10(self) -> float:
        """Log base 10 of total number of books."""
        return self.book_length * math.log10(self.alpha)
    
    @property
    def neighbors_per_book(self) -> int:
        """Number of books at Hamming distance 1 from any given book."""
        return (self.alpha - 1) * self.book_length
    
    @property
    def diameter(self) -> int:
        """Maximum Hamming distance (= book length)."""
        return self.book_length
    
    @property
    def clopen_basis_size(self) -> int:
        """Number of basic clopen sets in the product topology."""
        return self.alpha * self.book_length
    
    def compressible_fraction(self, savings: int) -> float:
        """Fraction of books compressible by `savings` characters."""
        return self.alpha ** (-savings)
    
    def summary(self) -> str:
        """Print summary of library parameters and theorems."""
        lines = [
            f"Library of Babel Parameters:",
            f"  Alphabet size: {self.alpha}",
            f"  Book length: {self.book_length:,}",
            f"  Total books: ≈ 10^{self.total_books_log10:,.0f}",
            f"  Neighbors per book: {self.neighbors_per_book:,}",
            f"  Hamming diameter: {self.diameter:,}",
            f"  Clopen basis size: {self.clopen_basis_size:,}",
            f"  Covering dimension: 0",
            f"  Compressible by 1 char: ≤ {self.compressible_fraction(1):.2%}",
            f"  Compressible by 100 chars: ≤ 10^{-100*math.log10(self.alpha):.0f}",
        ]
        return "\n".join(lines)


if __name__ == "__main__":
    lib = BabelLibrary()
    print(lib.summary())
