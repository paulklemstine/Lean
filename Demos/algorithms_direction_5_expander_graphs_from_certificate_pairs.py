#!/usr/bin/env python3
"""
Algorithms for Certificate-Based Expander Graph Construction

Implements the core algorithms described in the research paper:
1. Certificate verification for matrix pairs
2. Cayley graph construction from generator sets
3. Spectral gap computation via eigenvalue analysis
4. Mixing time estimation from spectral data

Keywords: explicit expanders, Cayley graphs, spectral gap, finite linear groups
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set
from itertools import product


# ============================================================================
# Algorithm 1: Finite Field Arithmetic
# ============================================================================

class GF:
    """Arithmetic in GF(q) for prime q.

    Time complexity: O(log q) for inversion via Fermat's little theorem.
    Space complexity: O(1).
    """

    def __init__(self, q: int):
        """Initialize GF(q).

        Args:
            q: A prime number.
        """
        self.q = q

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.q

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.q

    def neg(self, a: int) -> int:
        return (-a) % self.q

    def inv(self, a: int) -> int:
        """Multiplicative inverse using Fermat's little theorem."""
        if a % self.q == 0:
            raise ValueError("Zero is not invertible")
        return pow(int(a), self.q - 2, self.q)

    def order(self, a: int) -> int:
        """Multiplicative order of a in GF(q)×."""
        if a % self.q == 0:
            return 0
        val = a % self.q
        o = 1
        current = val
        while current != 1:
            current = self.mul(current, val)
            o += 1
        return o

    def is_primitive(self, a: int) -> bool:
        """Check if a generates GF(q)×."""
        return a % self.q != 0 and self.order(a) == self.q - 1


# ============================================================================
# Algorithm 2: Matrix Group Operations over GF(q)
# ============================================================================

class MatrixGroup:
    """Operations on 2×2 matrices over GF(q).

    Time complexity: O(1) per operation (fixed matrix size).
    Space complexity: O(1) per matrix.
    """

    def __init__(self, q: int):
        self.gf = GF(q)
        self.q = q

    def mul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Matrix multiplication over GF(q)."""
        q = self.q
        return np.array([
            [(A[0, 0] * B[0, 0] + A[0, 1] * B[1, 0]) % q,
             (A[0, 0] * B[0, 1] + A[0, 1] * B[1, 1]) % q],
            [(A[1, 0] * B[0, 0] + A[1, 1] * B[1, 0]) % q,
             (A[1, 0] * B[0, 1] + A[1, 1] * B[1, 1]) % q]
        ], dtype=int)

    def det(self, A: np.ndarray) -> int:
        """Determinant over GF(q)."""
        return (A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % self.q

    def inv(self, A: np.ndarray) -> Optional[np.ndarray]:
        """Matrix inverse over GF(q). Returns None if singular."""
        d = self.det(A)
        if d == 0:
            return None
        di = self.gf.inv(d)
        q = self.q
        return np.array([
            [(A[1, 1] * di) % q, ((-A[0, 1]) * di) % q],
            [((-A[1, 0]) * di) % q, (A[0, 0] * di) % q]
        ], dtype=int)

    def identity(self) -> np.ndarray:
        return np.eye(2, dtype=int)

    def enumerate_gl2(self) -> List[np.ndarray]:
        """Enumerate all elements of GL₂(GF(q)).

        Time: O(q⁴). Space: O(q⁴ - q³ + q² - q) = O(|GL₂|).
        """
        elements = []
        for a, b, c, d in product(range(self.q), repeat=4):
            A = np.array([[a, b], [c, d]], dtype=int)
            if self.det(A) != 0:
                elements.append(A)
        return elements

    def to_tuple(self, A: np.ndarray) -> tuple:
        return tuple(A.flatten().tolist())

    def from_tuple(self, t: tuple) -> np.ndarray:
        return np.array(t, dtype=int).reshape(2, 2)


# ============================================================================
# Algorithm 3: Certificate Verification
# ============================================================================

class CertificateVerifier:
    """Verify algebraic certificates for matrix pairs.

    A certified pair (g, h) in GL₂(GF(q)) must satisfy:
    1. Singer-like: g has irreducible characteristic polynomial
    2. Primitive determinant: det(h) generates GF(q)×
    3. Generation: ⟨g, h⟩ = GL₂(GF(q))

    Time: O(q) for certificate checks, O(|GL₂|²) for generation test.
    """

    def __init__(self, q: int):
        self.mg = MatrixGroup(q)
        self.q = q

    def charpoly_coeffs(self, A: np.ndarray) -> Tuple[int, int]:
        """Return (trace, det) of characteristic polynomial x² - tr·x + det."""
        tr = (A[0, 0] + A[1, 1]) % self.q
        det = self.mg.det(A)
        return (tr, det)

    def is_singer_like(self, A: np.ndarray) -> bool:
        """Check Singer-like property: irreducible charpoly over GF(q).

        For degree 2 polynomials over GF(q): irreducible iff no root in GF(q).
        Time: O(q).
        """
        tr, det = self.charpoly_coeffs(A)
        for x in range(self.q):
            if (x * x - tr * x + det) % self.q == 0:
                return False
        return True

    def is_primitive_det(self, A: np.ndarray) -> bool:
        """Check if det(A) generates GF(q)×. Time: O(q)."""
        return self.mg.gf.is_primitive(self.mg.det(A))

    def generates_group(self, g: np.ndarray, h: np.ndarray,
                        gl2: List[np.ndarray]) -> bool:
        """Check if {g, h} generates GL₂(GF(q)) by BFS closure.

        Time: O(|GL₂| · 4) = O(|GL₂|).
        Space: O(|GL₂|).
        """
        gi, hi = self.mg.inv(g), self.mg.inv(h)
        if gi is None or hi is None:
            return False

        generators = [g, gi, h, hi]
        gl2_set = set(self.mg.to_tuple(A) for A in gl2)
        generated: Set[tuple] = set()
        frontier = {self.mg.to_tuple(self.mg.identity())}

        while frontier:
            new_frontier: Set[tuple] = set()
            for t in frontier:
                if t in generated:
                    continue
                generated.add(t)
                A = self.mg.from_tuple(t)
                for gen in generators:
                    prod = self.mg.mul(A, gen, )
                    pt = self.mg.to_tuple(prod)
                    if pt not in generated and pt in gl2_set:
                        new_frontier.add(pt)
            frontier = new_frontier

        return len(generated) == len(gl2)

    def verify_certificate(self, g: np.ndarray, h: np.ndarray,
                           gl2: List[np.ndarray]) -> Dict[str, bool]:
        """Full certificate verification. Returns dict of test results."""
        return {
            'singer_like': self.is_singer_like(g),
            'primitive_det': self.is_primitive_det(h),
            'generates': self.generates_group(g, h, gl2),
            'g_invertible': self.mg.det(g) != 0,
            'h_invertible': self.mg.det(h) != 0,
        }


# ============================================================================
# Algorithm 4: Cayley Graph Construction
# ============================================================================

class CayleyGraph:
    """Construct and analyze Cayley graphs from generator sets.

    Time: O(|G| · |S|) for construction.
    Space: O(|G|²) for adjacency matrix.
    """

    def __init__(self, group_elements: List[np.ndarray],
                 generators: List[np.ndarray], mg: MatrixGroup):
        self.mg = mg
        self.elements = group_elements
        self.n = len(group_elements)
        self.idx = {mg.to_tuple(A): i for i, A in enumerate(group_elements)}
        self.generators = generators
        self._adj = None

    @property
    def adjacency_matrix(self) -> np.ndarray:
        """Build adjacency matrix. Lazy evaluation."""
        if self._adj is None:
            self._adj = np.zeros((self.n, self.n), dtype=float)
            for i, A in enumerate(self.elements):
                for gen in self.generators:
                    prod = self.mg.mul(A, gen)
                    j = self.idx.get(self.mg.to_tuple(prod))
                    if j is not None:
                        self._adj[i, j] = 1.0
        return self._adj

    @property
    def normalized_adjacency(self) -> np.ndarray:
        """Normalized adjacency (Markov operator). Time: O(|G|²)."""
        d = len(self.generators)
        return self.adjacency_matrix / d

    def degree(self) -> int:
        """Regularity degree."""
        return len(self.generators)

    def is_regular(self) -> bool:
        """Check regularity. Time: O(|G|)."""
        row_sums = self.adjacency_matrix.sum(axis=1)
        return np.allclose(row_sums, self.degree())


# ============================================================================
# Algorithm 5: Spectral Analysis
# ============================================================================

class SpectralAnalyzer:
    """Spectral analysis of Cayley graphs.

    Computes eigenvalues, spectral gap, and mixing time estimates.
    Time: O(|G|³) for eigenvalue computation (via numpy).
    """

    def __init__(self, cayley: CayleyGraph):
        self.cayley = cayley
        self._eigenvalues = None

    @property
    def eigenvalues(self) -> np.ndarray:
        """Compute eigenvalues of normalized adjacency matrix."""
        if self._eigenvalues is None:
            M = self.cayley.normalized_adjacency
            self._eigenvalues = np.sort(np.linalg.eigvalsh(M))[::-1]
        return self._eigenvalues

    def spectral_gap(self) -> float:
        """Spectral gap: 1 - max(|λ₂|, |λ_min|).

        Returns:
            The spectral gap, a value in [0, 1].
        """
        ev = self.eigenvalues
        if len(ev) < 2:
            return 1.0
        second = max(abs(ev[1]), abs(ev[-1]))
        return 1.0 - second

    def second_eigenvalue(self) -> float:
        """Second-largest eigenvalue."""
        ev = self.eigenvalues
        return ev[1] if len(ev) >= 2 else 0.0

    def mixing_time(self, delta: float = 0.01) -> int:
        """Estimate mixing time to total variation distance ≤ δ.

        Uses the bound: t_mix ≤ (log|G| + log(1/δ)) / gap.

        Args:
            delta: Target total variation distance.

        Returns:
            Upper bound on mixing time.
        """
        gap = self.spectral_gap()
        if gap <= 0:
            return float('inf')
        n = len(self.cayley.elements)
        return int(np.ceil((np.log(n) + np.log(1.0 / delta)) / gap))

    def eigenvalue_histogram(self) -> Dict[str, list]:
        """Return eigenvalue data for visualization."""
        return {
            'eigenvalues': self.eigenvalues.tolist(),
            'gap': self.spectral_gap(),
            'second_ev': self.second_eigenvalue(),
        }


# ============================================================================
# Algorithm 6: Full Certificate-to-Expansion Pipeline
# ============================================================================

def certificate_expansion_pipeline(q: int, max_pairs: int = 3) -> List[dict]:
    """Complete pipeline: certificates → generation → Cayley graph → spectral gap.

    This implements the full algebraic-to-spectral bridge:
    1. Enumerate GL₂(GF(q))
    2. Find elements with Singer-like and primitive-determinant properties
    3. Verify generation
    4. Construct Cayley graphs
    5. Compute spectral gaps

    Args:
        q: Prime field size.
        max_pairs: Maximum number of certified pairs to find.

    Returns:
        List of result dicts with certificate data and spectral analysis.

    Time: O(|GL₂|³) dominated by eigenvalue computation.
    """
    mg = MatrixGroup(q)
    cv = CertificateVerifier(q)
    gl2 = mg.enumerate_gl2()

    results = []
    singers = [A for A in gl2 if cv.is_singer_like(A)]
    prim_dets = [A for A in gl2 if cv.is_primitive_det(A)]

    for g in singers:
        if len(results) >= max_pairs:
            break
        for h in prim_dets:
            if len(results) >= max_pairs:
                break
            if not cv.generates_group(g, h, gl2):
                continue

            gi, hi = mg.inv(g), mg.inv(h)
            generators = [g, gi, h, hi]
            cayley = CayleyGraph(gl2, generators, mg)
            spectral = SpectralAnalyzer(cayley)

            results.append({
                'g': g.tolist(),
                'h': h.tolist(),
                'q': q,
                'gl2_order': len(gl2),
                'degree': cayley.degree(),
                'is_regular': cayley.is_regular(),
                'spectral_gap': spectral.spectral_gap(),
                'second_eigenvalue': spectral.second_eigenvalue(),
                'mixing_time': spectral.mixing_time(),
                'eigenvalues': spectral.eigenvalues.tolist(),
            })

    return results


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Certificate-to-Expansion Pipeline")
    print("=" * 50)

    for q in [3, 5]:
        results = certificate_expansion_pipeline(q, max_pairs=2)
        print(f"\nGL₂(𝔽_{q}): found {len(results)} certified pairs")
        for i, r in enumerate(results):
            print(f"  Pair {i+1}: gap = {r['spectral_gap']:.6f}, "
                  f"t_mix ≤ {r['mixing_time']}, "
                  f"regular = {r['is_regular']}")
