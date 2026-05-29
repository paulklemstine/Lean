#!/usr/bin/env python3
"""
Algorithms for Certified Expander Synthesis over GL₂(𝔽_q)

This module implements the core algorithms for:
1. Algebraic certificate verification (Singer-like, primitive det)
2. Group generation testing via closure computation
3. Cayley graph construction and spectral analysis
4. Certified expander witness production

All algorithms operate over finite fields F_q for prime q.
"""

import numpy as np
from typing import Optional, Tuple, List, Set
from itertools import product


# ============================================================
# Finite Field Arithmetic
# ============================================================

def gcd(a: int, b: int) -> int:
    """Extended GCD."""
    while b:
        a, b = b, a % b
    return a


def mod_inverse(a: int, q: int) -> Optional[int]:
    """Multiplicative inverse of a mod q, or None if not invertible."""
    if a % q == 0:
        return None
    return pow(a, q - 2, q)  # Fermat's little theorem


def multiplicative_order(a: int, q: int) -> int:
    """
    Compute the multiplicative order of a in (Z/qZ)×.

    Time complexity: O(q) in worst case, O(sqrt(q)) with factoring.
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
    """Check if a is a primitive root modulo q."""
    return multiplicative_order(a, q) == q - 1


def is_quadratic_residue(a: int, q: int) -> bool:
    """Check if a is a quadratic residue mod q using Euler's criterion."""
    if a % q == 0:
        return True
    return pow(a, (q - 1) // 2, q) == 1


# ============================================================
# Matrix Operations over F_q
# ============================================================

class Mat2Fq:
    """2x2 matrix over F_q with arithmetic operations.

    Attributes:
        entries: 2x2 numpy array of integers in [0, q)
        q: prime modulus
    """

    def __init__(self, entries: np.ndarray, q: int):
        self.entries = entries % q
        self.q = q

    @staticmethod
    def identity(q: int) -> 'Mat2Fq':
        return Mat2Fq(np.eye(2, dtype=int), q)

    @staticmethod
    def from_entries(a: int, b: int, c: int, d: int, q: int) -> 'Mat2Fq':
        return Mat2Fq(np.array([[a, b], [c, d]], dtype=int), q)

    def det(self) -> int:
        """Determinant mod q."""
        return int((self.entries[0, 0] * self.entries[1, 1] -
                     self.entries[0, 1] * self.entries[1, 0]) % self.q)

    def trace(self) -> int:
        """Trace mod q."""
        return int((self.entries[0, 0] + self.entries[1, 1]) % self.q)

    def charpoly_coeffs(self) -> Tuple[int, int]:
        """Returns (trace, det) for charpoly X² - tr·X + det."""
        return self.trace(), self.det()

    def __mul__(self, other: 'Mat2Fq') -> 'Mat2Fq':
        return Mat2Fq((self.entries @ other.entries) % self.q, self.q)

    def inverse(self) -> Optional['Mat2Fq']:
        """Matrix inverse, or None if singular."""
        d = self.det()
        if d == 0:
            return None
        d_inv = mod_inverse(d, self.q)
        adj = np.array([
            [self.entries[1, 1], -self.entries[0, 1]],
            [-self.entries[1, 0], self.entries[0, 0]]
        ], dtype=int)
        return Mat2Fq((d_inv * adj) % self.q, self.q)

    def __eq__(self, other) -> bool:
        return np.array_equal(self.entries, other.entries)

    def __hash__(self) -> int:
        return hash(tuple(self.entries.flatten()))

    def __repr__(self) -> str:
        return f"[{self.entries[0,0]} {self.entries[0,1]}; {self.entries[1,0]} {self.entries[1,1]}] (mod {self.q})"


# ============================================================
# Certificate Verification
# ============================================================

def is_charpoly_irreducible(M: Mat2Fq) -> bool:
    """
    Check if the characteristic polynomial of M is irreducible over F_q.

    The charpoly is X² - tr(M)·X + det(M). A quadratic over F_q is
    irreducible iff its discriminant tr² - 4·det is a non-square in F_q.

    Time complexity: O(log q) for the Euler criterion.
    """
    tr, det = M.charpoly_coeffs()
    q = M.q
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    return not is_quadratic_residue(disc, q)


def verify_singer_like(M: Mat2Fq) -> bool:
    """
    Verify the Singer-like certificate: M is invertible with irreducible charpoly.

    A Singer-like element acts as a "field extension in disguise" — its
    eigenvalues lie in F_{q²} \\ F_q, and it fixes no line in P¹(F_q).

    Time complexity: O(log q).
    """
    return M.det() != 0 and is_charpoly_irreducible(M)


def verify_primitive_det(M: Mat2Fq) -> bool:
    """
    Verify the primitive determinant certificate: det(M) generates F_q×.

    Time complexity: O(q) worst case.
    """
    d = M.det()
    return d != 0 and is_primitive_root(d, M.q)


def verify_generation(g: Mat2Fq, h: Mat2Fq) -> bool:
    """
    Verify that g, h generate GL₂(F_q) via closure computation.

    Time complexity: O(|GL₂(F_q)|²) = O(q⁸) worst case.
    Space complexity: O(|GL₂(F_q)|) = O(q⁴).
    """
    q = g.q
    gl2_size = (q**2 - 1) * (q**2 - q)
    identity = Mat2Fq.identity(q)
    g_inv, h_inv = g.inverse(), h.inverse()
    if g_inv is None or h_inv is None:
        return False

    generated: Set[Mat2Fq] = {identity}
    frontier = [identity]
    generators = [g, g_inv, h, h_inv]

    while frontier:
        new_frontier = []
        for m in frontier:
            for gen in generators:
                prod = m * gen
                if prod not in generated:
                    generated.add(prod)
                    new_frontier.append(prod)
                    if len(generated) >= gl2_size:
                        return True
        frontier = new_frontier
    return len(generated) >= gl2_size


def find_certified_pair(q: int, max_search: int = 200) -> Optional[Tuple[Mat2Fq, Mat2Fq]]:
    """
    Algorithm: Certified Expander Pair Search

    Input: prime q ≥ 5
    Output: certified pair (g, h) with proof data, or None

    Strategy:
    1. Enumerate Singer-like elements (matrices with irreducible charpoly)
    2. Enumerate primitive-determinant elements
    3. Test generation by closure computation
    4. Return first successful pair

    Time complexity: O(q⁴ · q⁸) worst case (dominated by generation test)
    In practice, certified pairs are dense and found quickly.
    """
    identity = Mat2Fq.identity(q)

    # Phase 1: Collect Singer-like candidates
    singers = []
    for a, b, c, d in product(range(q), repeat=4):
        M = Mat2Fq.from_entries(a, b, c, d, q)
        if verify_singer_like(M) and M != identity:
            singers.append(M)
            if len(singers) >= max_search:
                break

    # Phase 2: Collect primitive-det candidates
    primitives = []
    for a, b, c, d in product(range(q), repeat=4):
        M = Mat2Fq.from_entries(a, b, c, d, q)
        if verify_primitive_det(M) and M != identity:
            primitives.append(M)
            if len(primitives) >= max_search:
                break

    # Phase 3: Test pairs
    for g in singers:
        for h in primitives:
            if verify_generation(g, h):
                return (g, h)

    return None


# ============================================================
# Spectral Analysis
# ============================================================

def build_cayley_adjacency(g: Mat2Fq, h: Mat2Fq) -> Tuple[np.ndarray, List[Mat2Fq]]:
    """
    Build the normalized adjacency matrix of Cay(GL₂(F_q), {g, g⁻¹, h, h⁻¹}).

    Returns the (|G| × |G|) matrix A and the list of group elements.
    """
    q = g.q
    gl2 = []
    for a, b, c, d in product(range(q), repeat=4):
        M = Mat2Fq.from_entries(a, b, c, d, q)
        if M.det() != 0:
            gl2.append(M)

    n = len(gl2)
    index_map = {m: i for i, m in enumerate(gl2)}
    g_inv, h_inv = g.inverse(), h.inverse()
    gens = [g, g_inv, h, h_inv]

    A = np.zeros((n, n))
    for i, m in enumerate(gl2):
        for gen in gens:
            j = index_map[m * gen]
            A[i, j] = 1.0
    return A / 4.0, gl2


def spectral_gap(A: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap γ = 1 - max|λ_nontrivial| of normalized adjacency matrix.

    Returns (gap, all_eigenvalues_sorted).
    """
    eigs = np.linalg.eigvalsh(A)
    eigs_sorted = np.sort(eigs)[::-1]
    lambda1 = eigs_sorted[0]
    lambda2 = max(abs(eigs_sorted[1]), abs(eigs_sorted[-1]))
    return float(lambda1 - lambda2), eigs_sorted


# ============================================================
# Projective Line Analysis
# ============================================================

def projective_line_points(q: int) -> List[Tuple[int, int]]:
    """
    Points of P¹(F_q) represented as (a : b) with normalization.
    Returns q + 1 points.
    """
    points = []
    # Points (1 : b) for b in F_q
    for b in range(q):
        points.append((1, b))
    # Point (0 : 1) = infinity
    points.append((0, 1))
    return points


def projective_action(M: Mat2Fq, point: Tuple[int, int]) -> Tuple[int, int]:
    """Action of M on P¹(F_q)."""
    q = M.q
    a, b = point
    # M · (a, b)^T = (M[0,0]*a + M[0,1]*b, M[1,0]*a + M[1,1]*b)
    new_a = (int(M.entries[0, 0]) * a + int(M.entries[0, 1]) * b) % q
    new_b = (int(M.entries[1, 0]) * a + int(M.entries[1, 1]) * b) % q
    # Normalize
    if new_a != 0:
        inv_a = mod_inverse(new_a, q)
        return (1, (inv_a * new_b) % q)
    elif new_b != 0:
        return (0, 1)
    else:
        raise ValueError("Singular matrix cannot act on projective line")


def singer_like_fixed_points(M: Mat2Fq) -> List[Tuple[int, int]]:
    """Find fixed points of M on P¹(F_q). Should be empty for Singer-like M."""
    q = M.q
    points = projective_line_points(q)
    return [p for p in points if projective_action(M, p) == p]


# ============================================================
# Main Demonstration
# ============================================================

if __name__ == "__main__":
    import sys
    q = int(sys.argv[1]) if len(sys.argv) > 1 else 5

    print(f"Certified Expander Synthesis for GL₂(𝔽_{q})")
    print("=" * 50)

    pair = find_certified_pair(q)
    if pair is None:
        print("No certified pair found.")
        sys.exit(1)

    g, h = pair
    print(f"\nCertified pair found:")
    print(f"  g = {g}")
    print(f"  h = {h}")
    print(f"  Singer-like(g): {verify_singer_like(g)}")
    print(f"  PrimitiveDet(h): {verify_primitive_det(h)}")

    # Verify Singer-like has no projective fixed points
    fixed = singer_like_fixed_points(g)
    print(f"\n  Fixed points of g on P¹(𝔽_{q}): {fixed}")
    assert len(fixed) == 0, "Singer-like element should have no fixed points!"
    print("  ✓ Confirmed: g has no fixed points on P¹")

    # Compute spectrum
    print(f"\nBuilding Cayley graph ({(q**2-1)*(q**2-q)} vertices)...")
    A, _ = build_cayley_adjacency(g, h)
    gap, eigs = spectral_gap(A)
    print(f"  Spectral gap γ = {gap:.6f}")
    print(f"  q · γ = {q * gap:.6f}")
    print(f"  Top eigenvalues: {eigs[:5].round(6)}")
