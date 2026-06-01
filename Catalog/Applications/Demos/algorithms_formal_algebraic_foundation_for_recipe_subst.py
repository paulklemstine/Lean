#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Hamming Substitution Algebras.

Implements the key algorithms from the formal theory with full type hints
and documentation.
"""

from typing import List, Tuple, Optional, Set, FrozenSet
from dataclasses import dataclass
import itertools


# ============================================================
# Data Structures
# ============================================================

Word = Tuple[int, ...]


@dataclass
class AdditiveFlavorMap:
    """An additive flavor map: total value = sum of per-slot contributions."""
    slot_flavors: List[List[int]]

    @property
    def n_slots(self) -> int:
        return len(self.slot_flavors)

    @property
    def n_options(self) -> int:
        return len(self.slot_flavors[0]) if self.slot_flavors else 0

    def evaluate(self, word: Word) -> int:
        """Evaluate the flavor map on a word. O(n)."""
        return sum(self.slot_flavors[i][word[i]] for i in range(self.n_slots))

    def optimize(self) -> Tuple[Word, int]:
        """
        Find the word maximizing the flavor map. O(n·m).
        Returns (optimal_word, optimal_value).

        This implements the Slot Independence Theorem: since the total
        value decomposes as a sum of independent per-slot contributions,
        we can optimize each slot independently.
        """
        optimal = tuple(
            max(range(len(sf)), key=lambda j: sf[j])
            for sf in self.slot_flavors
        )
        value = self.evaluate(optimal)
        return optimal, value

    def fiber(self, target: int) -> List[Word]:
        """Find all words with a given flavor value. O(m^n)."""
        result = []
        for word in itertools.product(
            *[range(len(sf)) for sf in self.slot_flavors]
        ):
            if self.evaluate(word) == target:
                result.append(word)
        return result


@dataclass
class HammingCode:
    """A code in the Hamming space with minimum distance guarantee."""
    codewords: List[Word]
    n_slots: int
    n_options: int

    @property
    def size(self) -> int:
        return len(self.codewords)

    def min_distance(self) -> int:
        """Compute the minimum distance of the code. O(|C|²·n)."""
        if len(self.codewords) <= 1:
            return self.n_slots
        min_d = self.n_slots
        for i, u in enumerate(self.codewords):
            for j, v in enumerate(self.codewords):
                if j <= i:
                    continue
                d = hamming_distance(u, v)
                min_d = min(min_d, d)
        return min_d

    def satisfies_singleton_bound(self) -> bool:
        """Check whether the code satisfies the Singleton bound."""
        d = self.min_distance()
        bound = self.n_options ** max(self.n_slots - d + 1, 0)
        return self.size <= bound


# ============================================================
# Core Algorithms
# ============================================================

def hamming_distance(u: Word, v: Word) -> int:
    """
    Compute the Hamming distance between two words.

    The Hamming distance is the number of positions where the words differ.
    This is a metric: d(u,v) ≥ 0, d(u,v) = 0 iff u = v, d(u,v) = d(v,u),
    and d(u,w) ≤ d(u,v) + d(v,w) (triangle inequality).

    Time: O(n) where n = len(u).
    """
    return sum(1 for a, b in zip(u, v) if a != b)


def singleton_bound(n: int, m: int, d: int) -> int:
    """
    Compute the Singleton bound on code size.

    For a code C ⊆ H(n,m) with minimum distance d:
        |C| ≤ m^(n - d + 1)

    This bound is tight: codes achieving equality are MDS (Maximum Distance
    Separable) codes.

    Args:
        n: word length (number of slots)
        m: alphabet size (options per slot)
        d: minimum distance

    Returns:
        Upper bound on code size.
    """
    return m ** max(n - d + 1, 0)


def find_triangles(n: int, m: int) -> List[Tuple[Word, Word, Word]]:
    """
    Find all distance-1 triangles in H(n,m).

    By the Triangle Dichotomy Theorem:
    - H(n,2) has no distance-1 triangles (binary_hamming_triangle_free)
    - H(n,m) with m ≥ 3, n ≥ 1 always has triangles (nonbinary_triangle_exists)

    Time: O(m^(3n)) — enumerates all triples.
    """
    words = list(itertools.product(range(m), repeat=n))
    triangles = []
    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            if hamming_distance(words[i], words[j]) != 1:
                continue
            for k in range(j + 1, len(words)):
                if (hamming_distance(words[i], words[k]) == 1 and
                        hamming_distance(words[j], words[k]) == 1):
                    triangles.append((words[i], words[j], words[k]))
    return triangles


def shortest_path_count(u: Word, v: Word) -> int:
    """
    Count the number of shortest substitution paths (geodesics) from u to v.

    The number of geodesics equals d!, where d = hamming_distance(u, v).
    This is because a geodesic must change each differing position exactly once,
    and the order of changes is the only degree of freedom.

    Time: O(n + d!) where d = hamming_distance(u, v).
    """
    d = hamming_distance(u, v)
    result = 1
    for i in range(1, d + 1):
        result *= i
    return result


def enumerate_geodesics(u: Word, v: Word) -> List[List[Word]]:
    """
    Enumerate all shortest substitution paths from u to v.

    Each geodesic is a sequence of words [u = w₀, w₁, ..., w_d = v]
    where consecutive words differ in exactly one position.

    Time: O(d! · d · n).
    """
    differing = [i for i in range(len(u)) if u[i] != v[i]]
    geodesics = []
    for perm in itertools.permutations(differing):
        path = [list(u)]
        current = list(u)
        for pos in perm:
            current = current[:]
            current[pos] = v[pos]
            path.append(current)
        geodesics.append([tuple(w) for w in path])
    return geodesics


def translate(word: Word, offset: Word, m: int) -> Word:
    """
    Translate a word by a fixed offset (coordinate-wise addition mod m).

    By translation_preserves_hamming:
        hamming_distance(translate(u, t, m), translate(v, t, m))
        == hamming_distance(u, v)

    Time: O(n).
    """
    return tuple((a + b) % m for a, b in zip(word, offset))


def is_fiber_connected(words: List[Word]) -> bool:
    """
    Check if a set of words is connected in the Hamming graph.

    Uses BFS with distance-1 edges.

    Time: O(|words|² · n).
    """
    if len(words) <= 1:
        return True
    word_set: Set[Word] = set(words)
    visited: Set[Word] = {words[0]}
    queue = [words[0]]
    while queue:
        current = queue.pop(0)
        for w in words:
            if w not in visited and hamming_distance(current, w) == 1:
                visited.add(w)
                queue.append(w)
    return len(visited) == len(words)


def coord_project(word: Word, k: int) -> Word:
    """
    Project a word onto its first k coordinates.

    This is the projection used in the Singleton bound proof:
    it is injective on any code with minimum distance d when k = n - d + 1.

    Time: O(k).
    """
    return word[:k]


# ============================================================
# Main: demonstrate all algorithms
# ============================================================

if __name__ == "__main__":
    # Additive optimization demo
    flavor = AdditiveFlavorMap(
        slot_flavors=[[3, 7, 2, 5], [1, 4, 8, 6], [9, 1, 3, 2], [2, 5, 4, 7], [6, 3, 1, 8]]
    )
    opt_word, opt_val = flavor.optimize()
    print(f"Additive optimization: word={opt_word}, value={opt_val}")

    # Singleton bound demo
    for n, m, d in [(7, 2, 3), (4, 3, 2), (10, 5, 4)]:
        print(f"Singleton bound H({n},{m}), d={d}: |C| ≤ {singleton_bound(n, m, d)}")

    # Triangle dichotomy
    for m in [2, 3]:
        tris = find_triangles(3, m)
        print(f"H(3,{m}): {len(tris)} triangles")

    # Geodesic counting
    u, v = (0, 1, 2, 0), (2, 1, 0, 1)
    print(f"Geodesics from {u} to {v}: {shortest_path_count(u, v)}")
