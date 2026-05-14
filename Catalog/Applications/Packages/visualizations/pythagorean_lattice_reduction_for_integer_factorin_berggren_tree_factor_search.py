#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Algorithms

Implements the core algorithms for:
1. Square-root collision factoring
2. Berggren tree traversal and factor witness search
3. Euclid-parameter lattice construction
4. LLL-based short vector search for factoring
"""

import math
import random
from typing import Optional
import numpy as np


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Square-Root Collision Factor Extraction
# ─────────────────────────────────────────────────────────────────────

def gcd_factor_extract(n: int, x: int, y: int) -> Optional[int]:
    """
    Extract a nontrivial factor of n from x² ≡ y² (mod n).

    Complexity: O(log n) via Euclidean algorithm for gcd.

    Args:
        n: Integer to factor (n > 1)
        x, y: Integers with x² ≡ y² (mod n)

    Returns:
        A nontrivial factor d with 1 < d < n, or None if collision is trivial.
    """
    if (x * x - y * y) % n != 0:
        return None

    d = math.gcd(abs(x - y) % n, n)
    if 1 < d < n:
        return d

    d = math.gcd(abs(x + y) % n, n)
    if 1 < d < n:
        return d

    return None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Berggren Tree Traversal
# ─────────────────────────────────────────────────────────────────────

BERGGREN_MATRICES = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),  # U
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),      # A
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),   # D
]


def berggren_apply(word: list[int], root: np.ndarray = None) -> np.ndarray:
    """
    Apply a Berggren word to the root triple.

    Args:
        word: List of generator indices (0=U, 1=A, 2=D)
        root: Starting triple, default [3, 4, 5]

    Returns:
        Resulting Pythagorean triple as numpy array.

    Complexity: O(|word|) matrix-vector multiplications.
    """
    if root is None:
        root = np.array([3, 4, 5])
    v = root.copy()
    for g in reversed(word):
        v = BERGGREN_MATRICES[g] @ v
    return v


def berggren_bfs_factor_search(n: int, max_depth: int = 10) -> Optional[dict]:
    """
    Breadth-first search of the Berggren tree for factor witnesses.

    For each Berggren triple (a, b, c), checks:
    1. Hypotenuse-gcd: if n | c² and n ∤ c, then gcd(c, n) factors n
    2. Square collision: if n | a²-b² and n ∤ (a±b), then gcd(a-b, n) factors n

    Args:
        n: Integer to factor
        max_depth: Maximum word length to search

    Returns:
        Dict with factor, method, word, and triple; or None.

    Complexity: O(3^max_depth) in worst case.
    """
    from collections import deque

    queue = deque()
    queue.append([])

    while queue:
        word = queue.popleft()
        if len(word) > max_depth:
            break

        triple = berggren_apply(word)
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

        # Method 1: Hypotenuse-gcd
        if c * c % n == 0 and c % n != 0:
            d = math.gcd(abs(c), n)
            if 1 < d < n:
                return {"factor": d, "method": "hyp_gcd", "word": word, "triple": (a, b, c)}

        # Method 2: Square collision on (a, b)
        if (a * a - b * b) % n == 0:
            d = gcd_factor_extract(n, a, b)
            if d is not None:
                return {"factor": d, "method": "sq_collision", "word": word, "triple": (a, b, c)}

        # Method 3: Square collision on (a, c) and (b, c)
        for x, y in [(a, c), (b, c)]:
            if (x * x - y * y) % n == 0:
                d = gcd_factor_extract(n, x, y)
                if d is not None:
                    return {"factor": d, "method": "sq_collision", "word": word, "triple": (a, b, c)}

        # Expand children
        if len(word) < max_depth:
            for g in range(3):
                queue.append(word + [g])

    return None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Euclid-Parameter Lattice Construction
# ─────────────────────────────────────────────────────────────────────

def euclid_congruence_lattice(n: int) -> np.ndarray:
    """
    Construct a lattice basis encoding congruence conditions for Euclid parameters.

    The lattice L_n consists of vectors (m, k) such that m² + k² ≡ 0 (mod n).
    We augment with a third coordinate for the congruence constraint.

    Returns a 3×3 integer matrix whose rows form a basis for the lattice.

    Complexity: O(n) for finding a square root of -1 mod n (if it exists).
    """
    # Try to find r such that r² ≡ -1 (mod n)
    r = None
    for x in range(1, n):
        if (x * x + 1) % n == 0:
            r = x
            break

    if r is not None:
        # Lattice basis: vectors (m, k) with m ≡ r*k (mod n)
        basis = np.array([
            [1, r, 0],
            [0, n, 0],
            [0, 0, n],
        ])
    else:
        # -1 is not a QR mod n; use a different encoding
        basis = np.array([
            [n, 0, 0],
            [0, n, 0],
            [0, 0, 1],
        ])

    return basis


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: LLL-Based Short Vector Factor Search
# ─────────────────────────────────────────────────────────────────────

def lll_reduce(basis: np.ndarray, delta: float = 0.75) -> np.ndarray:
    """
    Lenstra-Lenstra-Lovász lattice basis reduction.

    Args:
        basis: Integer matrix whose rows form a lattice basis
        delta: Lovász condition parameter (0.25 < delta < 1)

    Returns:
        LLL-reduced basis.

    Complexity: O(d^5 * log(B)^3) where d is dimension, B is max entry.
    """
    n = basis.shape[0]
    B = basis.astype(float).copy()
    mu = np.zeros((n, n))
    B_star = np.zeros_like(B)
    B_star_norms = np.zeros(n)

    def gram_schmidt():
        for i in range(n):
            B_star[i] = B[i].copy()
            for j in range(i):
                if B_star_norms[j] > 1e-10:
                    mu[i][j] = np.dot(B[i], B_star[j]) / B_star_norms[j]
                    B_star[i] -= mu[i][j] * B_star[j]
            B_star_norms[i] = np.dot(B_star[i], B_star[i])

    gram_schmidt()

    k = 1
    while k < n:
        # Size reduction
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] -= r * B[j]
                gram_schmidt()

        # Lovász condition
        if B_star_norms[k] >= (delta - mu[k][k-1]**2) * B_star_norms[k-1]:
            k += 1
        else:
            B[[k, k-1]] = B[[k-1, k]]
            gram_schmidt()
            k = max(k - 1, 1)

    return np.round(B).astype(int)


def lll_factor_search(n: int) -> Optional[dict]:
    """
    Attempt to factor n using LLL reduction on a Pythagorean congruence lattice.

    Constructs a lattice encoding m² + k² ≡ 0 (mod n) and searches for
    short vectors that yield Pythagorean factor witnesses.

    Args:
        n: Integer to factor (n > 1)

    Returns:
        Dict with factor information, or None.

    Complexity: Polynomial in log(n) for the LLL step; factor extraction is O(log n).
    """
    basis = euclid_congruence_lattice(n)
    reduced = lll_reduce(basis)

    for row in reduced:
        m, k = int(row[0]), int(row[1])
        if m == 0 and k == 0:
            continue

        # Construct Euclid triple
        a = m * m - k * k
        b = 2 * m * k
        c = m * m + k * k

        if a == 0 or b == 0:
            continue

        # Check various gcd conditions
        for val in [c, a - b, a + b, a, b]:
            d = math.gcd(abs(val), n)
            if 1 < d < n:
                return {
                    "factor": d,
                    "euclid_params": (m, k),
                    "triple": (a, b, c),
                    "method": "lll_euclid",
                }

    return None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Combined Factoring Strategy
# ─────────────────────────────────────────────────────────────────────

def pythagorean_factor(n: int, max_berggren_depth: int = 8) -> Optional[dict]:
    """
    Combined Pythagorean factoring algorithm.

    Tries multiple strategies:
    1. LLL-based Euclid parameter search
    2. Berggren tree traversal
    3. Random Euclid parameter search

    Args:
        n: Integer to factor (n > 1)
        max_berggren_depth: Max Berggren tree depth

    Returns:
        Dict with factor and method information, or None.
    """
    # Strategy 1: LLL
    result = lll_factor_search(n)
    if result:
        return result

    # Strategy 2: Berggren tree
    result = berggren_bfs_factor_search(n, max_depth=max_berggren_depth)
    if result:
        return result

    # Strategy 3: Random Euclid parameters
    for _ in range(1000):
        m = random.randint(1, int(n**0.5) + 1)
        k = random.randint(1, int(n**0.5) + 1)
        if m <= k:
            continue
        c = m * m + k * k
        d = math.gcd(c, n)
        if 1 < d < n:
            a = m * m - k * k
            b = 2 * m * k
            return {
                "factor": d,
                "euclid_params": (m, k),
                "triple": (a, b, c),
                "method": "random_euclid",
            }

    return None


if __name__ == "__main__":
    print("Pythagorean Lattice Reduction — Algorithm Tests")
    print("=" * 60)

    test_composites = [15, 21, 35, 77, 91, 119, 143, 221, 323, 667,
                       1001, 2021, 3599, 10403, 25519]

    for n in test_composites:
        result = pythagorean_factor(n)
        if result:
            d = result["factor"]
            print(f"  {n:>6} = {d:>4} × {n//d:<5}  method={result['method']}")
        else:
            print(f"  {n:>6}: not factored")
