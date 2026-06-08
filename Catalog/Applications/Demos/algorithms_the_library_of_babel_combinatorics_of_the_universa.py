#!/usr/bin/env python3
"""
Library of Babel: Algorithms

Type-hinted implementations of key algorithms from the BabelCode theory.
"""

from typing import List, Tuple, Set, Optional, Callable
from math import comb, log2
from itertools import product


# --- Type aliases ---
Volume = Tuple[int, ...]


def hamming_distance(v: Volume, w: Volume) -> int:
    """Compute Hamming distance between two volumes.
    
    Time complexity: O(L) where L = len(v)
    """
    assert len(v) == len(w), "Volumes must have same length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_ball(v: Volume, r: int, A: int) -> List[Volume]:
    """Enumerate all volumes within Hamming distance r of v.
    
    Time complexity: O(sum_{i=0}^{r} C(L,i) * (A-1)^i * L)
    """
    L = len(v)
    result: List[Volume] = []
    
    def _generate(pos: int, changes_left: int, current: list):
        if pos == L:
            result.append(tuple(current))
            return
        # Keep original symbol
        current.append(v[pos])
        _generate(pos + 1, changes_left, current)
        current.pop()
        # Change to each alternative symbol
        if changes_left > 0:
            for a in range(A):
                if a != v[pos]:
                    current.append(a)
                    _generate(pos + 1, changes_left - 1, current)
                    current.pop()
    
    _generate(0, r, [])
    return result


def hamming_ball_size(L: int, A: int, r: int) -> int:
    """Compute |B(v, r)| = sum_{i=0}^{r} C(L,i) * (A-1)^i.
    
    Time complexity: O(r)
    """
    return sum(comb(L, i) * (A - 1) ** i for i in range(min(r, L) + 1))


def singleton_bound(A: int, L: int, d: int) -> int:
    """Singleton upper bound on code size: A^(L-d+1).
    
    Time complexity: O(1) (modular exponentiation)
    """
    if d > L + 1:
        return 1
    return A ** (L - d + 1)


def hamming_bound_value(A: int, L: int, d: int) -> int:
    """Hamming (sphere-packing) upper bound: A^L / |B(v, t)| where t = floor((d-1)/2).
    
    Time complexity: O(d)
    """
    t = (d - 1) // 2
    ball = hamming_ball_size(L, A, t)
    return A ** L // ball


def plotkin_bound(A: int, L: int, d: int) -> Optional[int]:
    """Plotkin upper bound: d*A / (d*A - L*(A-1)) when d > L*(A-1)/A.
    
    Returns None if the bound doesn't apply (d too small).
    Time complexity: O(1)
    """
    threshold = L * (A - 1) / A
    if d <= threshold:
        return None
    return int(d * A / (d * A - L * (A - 1)))


def nearest_codeword(v: Volume, codewords: List[Volume]) -> Tuple[Volume, int]:
    """Find the nearest codeword to volume v.
    
    Returns (nearest_codeword, distance).
    Time complexity: O(|C| * L)
    """
    best_cw = codewords[0]
    best_dist = hamming_distance(v, best_cw)
    
    for cw in codewords[1:]:
        d = hamming_distance(v, cw)
        if d < best_dist:
            best_dist = d
            best_cw = cw
    
    return best_cw, best_dist


def greedy_code(A: int, L: int, d: int) -> List[Volume]:
    """Construct a code greedily by adding volumes that maintain min distance d.
    
    Not optimal in general, but provides a lower bound on maximum code size.
    Time complexity: O(A^L * |C| * L)
    """
    code: List[Volume] = []
    
    for v in product(range(A), repeat=L):
        vol = tuple(v)
        if all(hamming_distance(vol, cw) >= d for cw in code):
            code.append(vol)
    
    return code


def hamming_neighbors(v: Volume, A: int) -> List[Volume]:
    """Enumerate all Hamming neighbors (distance exactly 1) of volume v.
    
    Returns exactly L * (A-1) neighbors.
    Time complexity: O(L * A)
    """
    L = len(v)
    neighbors: List[Volume] = []
    
    for i in range(L):
        for a in range(A):
            if a != v[i]:
                w = list(v)
                w[i] = a
                neighbors.append(tuple(w))
    
    return neighbors


def babel_boundary(S: Set[Volume], A: int) -> Set[Volume]:
    """Compute the boundary of a set S: volumes not in S adjacent to some volume in S.
    
    Time complexity: O(|S| * L * A)
    """
    boundary: Set[Volume] = set()
    L = len(next(iter(S)))  # infer L from first element
    
    for v in S:
        for w in hamming_neighbors(v, A):
            if w not in S:
                boundary.add(w)
    
    return boundary


def pattern_positions(v: Volume, pattern: Volume) -> List[int]:
    """Find all positions where pattern appears as a substring of v.
    
    Time complexity: O(L * m) where m = len(pattern)
    """
    L = len(v)
    m = len(pattern)
    positions: List[int] = []
    
    for pos in range(L - m + 1):
        if all(v[pos + j] == pattern[j] for j in range(m)):
            positions.append(pos)
    
    return positions


def de_bruijn_sequence(A: int, n: int) -> List[int]:
    """Generate a de Bruijn sequence B(A, n): a cyclic sequence in which every
    possible n-length substring over alphabet {0,...,A-1} appears exactly once.
    
    Uses Martin's algorithm.
    Length of output: A^n + n - 1 (linear representation of the cycle).
    Time complexity: O(A^n)
    """
    sequence: List[int] = []
    a = [0] * (A * n)
    
    def _db(t: int, p: int):
        if t > n:
            if n % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            _db(t + 1, p)
            for j in range(a[t - p] + 1, A):
                a[t] = j
                _db(t + 1, t)
    
    _db(1, 1)
    # Make it linear by appending first n-1 elements
    sequence.extend(sequence[:n - 1])
    return sequence


def mini_library_catalog(A: int, L: int) -> dict:
    """Build a complete catalog of a mini-Library using de Bruijn sequences.
    
    Maps each volume to its position in the de Bruijn sequence.
    Time complexity: O(A^L * L)
    """
    seq = de_bruijn_sequence(A, L)
    catalog: dict = {}
    
    for pos in range(len(seq) - L + 1):
        vol = tuple(seq[pos:pos + L])
        if vol not in catalog:
            catalog[vol] = pos
    
    return catalog


def diagonal_counterexample(
    f: Callable[[Volume], Callable[[Volume], int]],
    volumes: List[Volume]
) -> Callable[[Volume], int]:
    """Construct the Lawvere diagonal function that cannot be in the range of f.
    
    Given f: Volume → (Volume → {0,1}), returns g: Volume → {0,1} such that
    g(v) = 1 - f(v)(v) for all v, ensuring g ≠ f(v) for all v.
    
    Time complexity: O(|volumes|)
    """
    diag_values = {v: 1 - f(v)(v) for v in volumes}
    return lambda v: diag_values.get(v, 0)


# --- Demo ---

if __name__ == "__main__":
    print("=== De Bruijn Sequence Demo ===")
    seq = de_bruijn_sequence(2, 3)
    print(f"B(2,3) = {''.join(map(str, seq))}")
    print(f"Length = {len(seq)} (expected {2**3 + 3 - 1} = {2**3 + 2})")
    
    # Verify all 3-length substrings appear
    substrings = set()
    for i in range(len(seq) - 2):
        substrings.add(tuple(seq[i:i+3]))
    print(f"Unique 3-substrings: {len(substrings)} (expected {2**3})")
    
    print("\n=== Greedy Code Construction ===")
    for d in [2, 3, 4]:
        code = greedy_code(2, 7, d)
        print(f"  Binary(7, d={d}): |C| = {len(code)}, "
              f"Singleton ≤ {singleton_bound(2, 7, d)}, "
              f"Hamming ≤ {hamming_bound_value(2, 7, d)}")
    
    print("\n=== Mini-Library Catalog ===")
    catalog = mini_library_catalog(2, 3)
    print(f"  Cataloged {len(catalog)} volumes of Library(2,3)")
    for vol, pos in sorted(catalog.items()):
        print(f"    {''.join(map(str, vol))} → position {pos}")
