#!/usr/bin/env python3
"""
algorithms.py — Certified Expander Synthesis for GL₂(𝔽_q)

Implements the verified algorithm pipeline:
  1. Enumerate GL₂(𝔽_q) elements
  2. Filter for Singer-like elements (irreducible charpoly)
  3. Filter for primitive determinant elements
  4. Check generation via BFS closure
  5. Compute spectral gap of resulting Cayley graph
  6. Return proof-carrying witness data

All algorithms have explicit complexity analysis.
"""

import numpy as np
from itertools import product as cartesian_product
from typing import List, Tuple, Optional, Dict, Any

# ──────────────────────────────────────────────────────────
# Core finite field arithmetic
# ──────────────────────────────────────────────────────────

def mod(x: int, q: int) -> int:
    """Reduce x modulo q."""
    return x % q

def power_mod(base: int, exp: int, q: int) -> int:
    """Fast modular exponentiation."""
    return pow(base, exp, q)

def inverse_mod(a: int, q: int) -> int:
    """Multiplicative inverse of a mod q (q prime)."""
    return power_mod(a, q - 2, q)

def multiplicative_order(a: int, q: int) -> int:
    """
    Compute the multiplicative order of a in (ℤ/qℤ)×.

    Time complexity: O(q)
    Space complexity: O(1)
    """
    if a % q == 0:
        return 0
    x = 1
    for k in range(1, q):
        x = (x * a) % q
        if x == 1:
            return k
    return q - 1

def is_primitive_root(a: int, q: int) -> bool:
    """Check if a is a primitive root mod q (generator of 𝔽_q×)."""
    return multiplicative_order(a, q) == q - 1

# ──────────────────────────────────────────────────────────
# Matrix operations over 𝔽_q
# ──────────────────────────────────────────────────────────

class Mat2:
    """2×2 matrix over 𝔽_q with efficient arithmetic.

    Time complexity per operation:
      - __init__: O(1)
      - det: O(1)
      - __mul__: O(1)
      - inv: O(1)
      - trace: O(1)
      - charpoly_coeffs: O(1)
      - is_charpoly_irreducible: O(q)
    """

    __slots__ = ['a', 'b', 'c', 'd', 'q']

    def __init__(self, a: int, b: int, c: int, d: int, q: int):
        self.a = a % q
        self.b = b % q
        self.c = c % q
        self.d = d % q
        self.q = q

    def det(self) -> int:
        return (self.a * self.d - self.b * self.c) % self.q

    def trace(self) -> int:
        return (self.a + self.d) % self.q

    def __mul__(self, other: 'Mat2') -> 'Mat2':
        q = self.q
        return Mat2(
            (self.a * other.a + self.b * other.c) % q,
            (self.a * other.b + self.b * other.d) % q,
            (self.c * other.a + self.d * other.c) % q,
            (self.c * other.b + self.d * other.d) % q,
            q
        )

    def inv(self) -> Optional['Mat2']:
        """Return inverse or None if singular."""
        det = self.det()
        if det == 0:
            return None
        q = self.q
        di = inverse_mod(det, q)
        return Mat2(
            (self.d * di) % q,
            ((-self.b) * di) % q,
            ((-self.c) * di) % q,
            (self.a * di) % q,
            q
        )

    def charpoly_coeffs(self) -> Tuple[int, int]:
        """Return (tr, det) where charpoly = X² - tr·X + det."""
        return self.trace(), self.det()

    def is_charpoly_irreducible(self) -> bool:
        """Check if charpoly X² - tr·X + det has no roots in 𝔽_q.

        Time complexity: O(q)
        """
        tr, det = self.charpoly_coeffs()
        q = self.q
        for a in range(q):
            if (a * a - tr * a + det) % q == 0:
                return False
        return True

    def is_singer_like(self) -> bool:
        """Singer-like: invertible with irreducible charpoly."""
        return self.det() != 0 and self.is_charpoly_irreducible()

    def is_primitive_det(self) -> bool:
        """Primitive determinant: det generates 𝔽_q×."""
        return is_primitive_root(self.det(), self.q)

    def to_tuple(self) -> Tuple[int, int, int, int]:
        return (self.a, self.b, self.c, self.d)

    def to_numpy(self) -> np.ndarray:
        return np.array([[self.a, self.b], [self.c, self.d]])

    @staticmethod
    def identity(q: int) -> 'Mat2':
        return Mat2(1, 0, 0, 1, q)

    def __eq__(self, other):
        return self.to_tuple() == other.to_tuple() and self.q == other.q

    def __hash__(self):
        return hash((self.to_tuple(), self.q))

    def __repr__(self):
        return f"Mat2([{self.a},{self.b};{self.c},{self.d}] mod {self.q})"

# ──────────────────────────────────────────────────────────
# Enumeration algorithms
# ──────────────────────────────────────────────────────────

def enumerate_gl2(q: int) -> List[Mat2]:
    """
    Enumerate all elements of GL₂(𝔽_q).

    |GL₂(𝔽_q)| = (q²-1)(q²-q) = q(q-1)²(q+1)

    Time complexity: O(q⁴)
    Space complexity: O(q⁴)
    """
    elements = []
    for a, b, c, d in cartesian_product(range(q), repeat=4):
        m = Mat2(a, b, c, d, q)
        if m.det() != 0:
            elements.append(m)
    return elements

def find_singer_elements(q: int) -> List[Mat2]:
    """
    Find all Singer-like elements in GL₂(𝔽_q).

    Expected count: q(q-1)(q²-q)/2 ≈ q⁴/2 (roughly half of GL₂).

    Time complexity: O(q⁵) — enumerate O(q⁴) elements, each check O(q).
    """
    singers = []
    for a, b, c, d in cartesian_product(range(q), repeat=4):
        m = Mat2(a, b, c, d, q)
        if m.is_singer_like():
            singers.append(m)
    return singers

def find_primitive_det_elements(q: int) -> List[Mat2]:
    """
    Find all elements with primitive determinant.

    Time complexity: O(q⁵) worst case.
    """
    result = []
    for a, b, c, d in cartesian_product(range(q), repeat=4):
        m = Mat2(a, b, c, d, q)
        if m.is_primitive_det():
            result.append(m)
    return result

# ──────────────────────────────────────────────────────────
# Generation check via BFS
# ──────────────────────────────────────────────────────────

def check_generation(g: Mat2, h: Mat2, target_size: int) -> bool:
    """
    Check if {g, g⁻¹, h, h⁻¹} generates GL₂(𝔽_q) via BFS.

    Time complexity: O(|GL₂| · 4) = O(q⁴)
    Space complexity: O(|GL₂|) = O(q⁴)
    """
    q = g.q
    g_inv = g.inv()
    h_inv = h.inv()
    if g_inv is None or h_inv is None:
        return False

    seen = {Mat2.identity(q).to_tuple()}
    queue = [Mat2.identity(q)]
    gens = [g, g_inv, h, h_inv]

    while queue:
        current = queue.pop(0)
        for s in gens:
            prod = current * s
            t = prod.to_tuple()
            if t not in seen:
                seen.add(t)
                queue.append(prod)
                if len(seen) == target_size:
                    return True
    return len(seen) == target_size

# ──────────────────────────────────────────────────────────
# Certified pair synthesis algorithm
# ──────────────────────────────────────────────────────────

def synthesize_certified_pairs(
    q: int,
    max_pairs: int = 10,
    max_singer_candidates: int = 100,
    max_prim_candidates: int = 100
) -> List[Dict[str, Any]]:
    """
    Algorithm: Certified Expander Synthesis for GL₂(𝔽_q)

    Input:  prime q ≥ 5
    Output: list of certified pairs with spectral data

    Pseudocode:
      1. Compute |GL₂(𝔽_q)| = q(q-1)²(q+1)
      2. For each (a,b,c,d) ∈ 𝔽_q⁴ with ad-bc ≠ 0:
         a. Check if charpoly is irreducible → Singer candidate
         b. Check if det is primitive → primitive-det candidate
      3. For each Singer g and primitive-det h:
         a. BFS from identity using {g, g⁻¹, h, h⁻¹}
         b. If closure = GL₂(𝔽_q): certified pair found
      4. For certified pairs, compute Cayley adjacency spectrum
      5. Return spectral gap data

    Time complexity: O(q⁸) worst case (q⁴ pairs × q⁴ BFS)
    Space complexity: O(q⁴) for group element storage
    """
    target_size = q * (q - 1) * (q - 1) * (q + 1)

    # Phase 1: Find candidates
    singers = []
    prim_dets = []
    for a, b, c, d in cartesian_product(range(q), repeat=4):
        m = Mat2(a, b, c, d, q)
        det = m.det()
        if det == 0:
            continue
        if m.is_charpoly_irreducible():
            singers.append(m)
        if is_primitive_root(det, q):
            prim_dets.append(m)

    # Phase 2: Check generation
    results = []
    for g in singers[:max_singer_candidates]:
        for h in prim_dets[:max_prim_candidates]:
            if check_generation(g, h, target_size):
                result = {
                    'g': g,
                    'h': h,
                    'g_matrix': g.to_numpy(),
                    'h_matrix': h.to_numpy(),
                    'g_det': g.det(),
                    'h_det': h.det(),
                    'g_trace': g.trace(),
                    'h_trace': h.trace(),
                    'singer_like': True,
                    'primitive_det': True,
                    'generates': True,
                }
                results.append(result)
                if len(results) >= max_pairs:
                    return results
        if len(results) >= max_pairs:
            break

    return results

def compute_spectral_data(
    g: Mat2, h: Mat2, elements: Optional[List[Mat2]] = None
) -> Dict[str, Any]:
    """
    Compute full spectral data for a certified pair.

    Returns dict with eigenvalues, spectral gap, q*gap, etc.

    Time complexity: O(|GL₂|² · 4) for adjacency + O(|GL₂|³) for eigendecomposition
    """
    q = g.q
    if elements is None:
        elements = enumerate_gl2(q)
    n = len(elements)
    idx = {e.to_tuple(): i for i, e in enumerate(elements)}

    g_inv, h_inv = g.inv(), h.inv()
    gens = [g, g_inv, h, h_inv]

    # Build normalized adjacency matrix
    A = np.zeros((n, n))
    for i, e in enumerate(elements):
        for s in gens:
            prod = e * s
            j = idx[prod.to_tuple()]
            A[i, j] += 1
    A /= 4.0

    # Eigenvalue computation
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]

    # Spectral gap (excluding both +1 and -1 for bipartite handling)
    nontrivial = [ev for ev in eigenvalues[1:] if abs(abs(ev) - 1.0) > 1e-10]
    if nontrivial:
        second_largest = max(abs(ev) for ev in nontrivial)
        gap = 1.0 - second_largest
    else:
        gap = 1.0  # Only trivial eigenvalues

    # Standard gap (may be 0 if bipartite)
    standard_second = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    standard_gap = 1.0 - standard_second

    return {
        'eigenvalues': eigenvalues,
        'spectral_gap': gap,
        'standard_gap': standard_gap,
        'q_times_gap': q * gap,
        'q_times_standard_gap': q * standard_gap,
        'has_minus_one': abs(eigenvalues[-1] + 1.0) < 1e-10,
        'is_bipartite': abs(eigenvalues[-1] + 1.0) < 1e-10,
        'n_vertices': n,
    }

# ──────────────────────────────────────────────────────────
# Projective line analysis
# ──────────────────────────────────────────────────────────

def projective_action(m: Mat2, point: Tuple[int, int]) -> Tuple[int, int]:
    """Act on ℙ¹(𝔽_q) by Möbius transformation."""
    q = m.q
    a, b = point
    na = (m.a * a + m.b * b) % q
    nb = (m.c * a + m.d * b) % q
    if nb != 0:
        inv_b = inverse_mod(nb, q)
        return ((na * inv_b) % q, 1)
    elif na != 0:
        return (1, 0)
    else:
        raise ValueError("Zero image in projective action")

def count_fixed_points(m: Mat2) -> int:
    """Count fixed points of m on ℙ¹(𝔽_q)."""
    q = m.q
    points = [(a, 1) for a in range(q)] + [(1, 0)]
    return sum(1 for p in points if projective_action(m, p) == p)

# ──────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────

if __name__ == '__main__':
    for q in [5, 7, 11]:
        print(f"\n{'='*50}")
        print(f"  GL₂(𝔽_{q}) Certified Expander Synthesis")
        print(f"{'='*50}")

        pairs = synthesize_certified_pairs(q, max_pairs=2)
        elements = enumerate_gl2(q)

        for i, pair in enumerate(pairs):
            data = compute_spectral_data(pair['g'], pair['h'], elements)
            fp = count_fixed_points(pair['g'])
            print(f"\n  Pair {i+1}: g={pair['g']}, h={pair['h']}")
            print(f"    Spectral gap (non-bipartite): {data['spectral_gap']:.6f}")
            print(f"    q × gap: {data['q_times_gap']:.6f}")
            print(f"    Bipartite: {data['is_bipartite']}")
            print(f"    Singer fixed points on ℙ¹: {fp}")
