#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Prime Gap Crossword framework.

Implements the modular sieve admissibility and forcing pattern detection
algorithms described in the research paper. These algorithms treat prime gap
patterns as constraint satisfaction problems over finite modular arithmetic.

Usage:
    from algorithms import SieveCrossword
    cw = SieveCrossword(primes={2, 3, 5})
    print(cw.next_gaps([2, 6]))  # -> {4}  (forced!)
"""

from math import prod, gcd
from itertools import product as cartesian_product
from typing import List, Set, Dict, Tuple, Optional
from functools import lru_cache
import time


class SieveCrossword:
    """
    A prime-gap crossword board defined by a finite sieve set S of primes.

    The modulus M = ∏S defines a finite state space: residues mod M.
    A gap word is S-admissible if there exists a starting residue a (mod M)
    such that:
      - All cumulative "prime positions" a+t are coprime to every q in S.
      - All intermediate positions are divisible by at least one q in S.

    Attributes:
        primes: The sieve set S (set of primes).
        modulus: M = product of all primes in S.
        coprime_residues: Set of residues mod M coprime to all primes in S.
    """

    def __init__(self, primes: Set[int]):
        """Initialize with a set of prime numbers."""
        self.primes: Set[int] = primes
        self.modulus: int = prod(primes) if primes else 1
        self.coprime_residues: Set[int] = {
            r for r in range(self.modulus)
            if all(r % q != 0 for q in primes)
        }

    def gap_word_positions(self, gaps: List[int]) -> List[int]:
        """
        Compute cumulative sums of a gap word, starting from 0.

        Args:
            gaps: List of gap sizes [g1, g2, ..., gk].

        Returns:
            [0, g1, g1+g2, ..., g1+...+gk]

        Example:
            >>> SieveCrossword({2,3}).gap_word_positions([2, 4, 6])
            [0, 2, 6, 12]
        """
        positions = [0]
        s = 0
        for g in gaps:
            s += g
            positions.append(s)
        return positions

    def interior_positions(self, gaps: List[int]) -> Set[int]:
        """
        Compute positions strictly between consecutive cumulative sums.

        These are the positions that must be "sieved out" (divisible by
        at least one prime in S) for a valid gap pattern.

        Args:
            gaps: List of gap sizes.

        Returns:
            Set of interior positions.

        Example:
            >>> SieveCrossword({2,3}).interior_positions([4, 2])
            {1, 2, 3, 5}
        """
        positions = self.gap_word_positions(gaps)
        interior: Set[int] = set()
        for i in range(len(positions) - 1):
            for x in range(positions[i] + 1, positions[i + 1]):
                interior.add(x)
        return interior

    def avoids_all(self, n: int) -> bool:
        """Check that n is coprime to all primes in S (mod self.modulus)."""
        return all(n % q != 0 for q in self.primes)

    def hit_by_some(self, n: int) -> bool:
        """Check that n is divisible by at least one prime in S."""
        return any(n % q == 0 for q in self.primes)

    def is_admissible_at(self, gaps: List[int], a: int) -> bool:
        """
        Check if gap word is admissible at starting residue a.

        Args:
            gaps: Gap word.
            a: Starting residue.

        Returns:
            True if all positions avoid S and all interior points are hit.
        """
        positions = self.gap_word_positions(gaps)
        interior = self.interior_positions(gaps)

        # All cumulative positions must avoid S
        for t in positions:
            if not self.avoids_all(a + t):
                return False

        # All interior positions must be hit by S
        for u in interior:
            if not self.hit_by_some(a + u):
                return False

        return True

    def admissible_residues(self, gaps: List[int]) -> List[int]:
        """
        Find all residues mod M that make gaps admissible.

        Args:
            gaps: Gap word.

        Returns:
            List of valid starting residues mod M.

        Complexity: O(M * |gaps| * max(gaps))
        """
        return [a for a in range(self.modulus)
                if self.is_admissible_at(gaps, a)]

    def is_admissible(self, gaps: List[int]) -> bool:
        """Check if gap word has any admissible starting residue."""
        return any(self.is_admissible_at(gaps, a)
                   for a in range(self.modulus))

    def next_gaps(self, word: List[int], max_gap: int = 30) -> Set[int]:
        """
        Find all admissible positive next gaps for a word.

        Args:
            word: Current gap word prefix.
            max_gap: Maximum gap size to consider.

        Returns:
            Set of admissible next gaps.

        Complexity: O(max_gap * M * |word| * max(word))
        """
        return {g for g in range(1, max_gap + 1)
                if self.is_admissible(word + [g])}

    def is_forcing(self, word: List[int], max_gap: int = 30) -> Optional[int]:
        """
        Check if word is forcing: has exactly one admissible positive next gap.

        Args:
            word: Gap word to check.
            max_gap: Bound on next gap search.

        Returns:
            The forced gap if word is forcing, None otherwise.
        """
        gaps = self.next_gaps(word, max_gap)
        if len(gaps) == 1:
            return gaps.pop()
        return None

    def find_forcing_patterns(self, max_word_len: int = 4,
                              max_gap: int = 30) -> List[Tuple[List[int], int]]:
        """
        Enumerate all forcing patterns up to given word length.

        Args:
            max_word_len: Maximum word length to search.
            max_gap: Maximum gap value in words and extensions.

        Returns:
            List of (word, forced_gap) pairs.

        Complexity: O(max_gap^max_word_len * max_gap * M)
        """
        even_gaps = list(range(2, max_gap + 1, 2))
        forcing_patterns: List[Tuple[List[int], int]] = []

        for length in range(1, max_word_len + 1):
            for word_tuple in cartesian_product(even_gaps, repeat=length):
                word = list(word_tuple)
                if not self.is_admissible(word):
                    continue
                forced = self.is_forcing(word, max_gap)
                if forced is not None:
                    forcing_patterns.append((word, forced))

        return forcing_patterns

    def ambiguity_ratio(self, length: int, max_gap: int = 20) -> float:
        """
        Compute the fraction of admissible words of given length
        that have more than one admissible next gap.

        Args:
            length: Word length to analyze.
            max_gap: Maximum gap value.

        Returns:
            Ratio of ambiguous words to total admissible words.
        """
        even_gaps = list(range(2, max_gap + 1, 2))
        total_admissible = 0
        ambiguous = 0

        for word_tuple in cartesian_product(even_gaps, repeat=length):
            word = list(word_tuple)
            if not self.is_admissible(word):
                continue
            total_admissible += 1
            nexts = self.next_gaps(word, max_gap)
            if len(nexts) > 1:
                ambiguous += 1

        if total_admissible == 0:
            return 0.0
        return ambiguous / total_admissible

    def state_transition_graph(self, max_gap: int = 20) -> Dict[int, Dict[int, int]]:
        """
        Build the state transition graph for single-gap words.

        Vertices are admissible residues mod M.
        Edge (a, b) labeled g means: starting at residue a, gap g leads to
        residue (a + g) mod M = b, and the extension is admissible.

        Returns:
            Dict mapping residue -> {next_residue: gap_label}
        """
        graph: Dict[int, Dict[int, int]] = {}
        for a in range(self.modulus):
            if not self.avoids_all(a):
                continue
            edges: Dict[int, int] = {}
            for g in range(2, max_gap + 1, 2):
                b = (a + g) % self.modulus
                if self.is_admissible_at([g], a):
                    edges[b] = g
            if edges:
                graph[a] = edges
        return graph


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """
    Generate all primes up to limit using Sieve of Eratosthenes.

    Args:
        limit: Upper bound for prime search.

    Returns:
        Sorted list of primes ≤ limit.

    Complexity: O(n log log n)
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def prime_gaps(limit: int) -> List[int]:
    """
    Compute consecutive prime gaps up to limit.

    Args:
        limit: Generate primes up to this bound.

    Returns:
        List of gaps between consecutive primes.
    """
    primes = sieve_of_eratosthenes(limit)
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def empirical_next_gap_distribution(gaps_data: List[int],
                                     word: List[int]) -> Dict[int, int]:
    """
    Compute empirical distribution of next gaps after a given word
    appears in actual prime gap data.

    Args:
        gaps_data: List of consecutive prime gaps.
        word: Pattern to search for.

    Returns:
        Dictionary mapping next_gap -> count.
    """
    distribution: Dict[int, int] = {}
    wlen = len(word)

    for i in range(len(gaps_data) - wlen):
        if gaps_data[i:i + wlen] == word:
            next_g = gaps_data[i + wlen]
            distribution[next_g] = distribution.get(next_g, 0) + 1

    return distribution


if __name__ == "__main__":
    # Quick demo
    print("=== Prime Gap Crossword Algorithms ===\n")

    for S_set in [{2, 3}, {2, 3, 5}, {2, 3, 5, 7}]:
        cw = SieveCrossword(S_set)
        print(f"Sieve S = {sorted(S_set)}, M = {cw.modulus}")
        print(f"  Coprime residues: {len(cw.coprime_residues)} out of {cw.modulus}")

        patterns = cw.find_forcing_patterns(max_word_len=2, max_gap=20)
        print(f"  Forcing patterns (len ≤ 2):")
        for w, g in patterns[:10]:
            print(f"    {w} -> {g}")
        print()
