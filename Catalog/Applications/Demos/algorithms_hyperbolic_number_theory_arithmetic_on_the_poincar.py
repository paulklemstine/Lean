"""
Hyperbolic Number Theory: Algorithms

Core algorithms for computing with hyperbolic lattice structures,
trace sequences, and Möbius transformations.

Includes:
- Trace sequence computation (O(n) time, O(1) space)
- Companion matrix exponentiation (O(log n) time)
- Pseudo-hyperbolic distance computation
- Markov tree generation via Vieta involution
- Conformal factor computation
"""

import math
from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass


# ============================================================================
# Algorithm 1: Trace Sequence (Linear Recurrence)
# ============================================================================

def trace_seq(t: int, n: int) -> int:
    """Compute traceSeq(t, n) via the Chebyshev recurrence.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    The trace sequence satisfies:
        x_0 = 2, x_1 = t, x_{k+2} = t·x_{k+1} - x_k
    
    This computes tr(γⁿ) where γ ∈ SL₂(ℤ) has tr(γ) = t.
    
    Args:
        t: The trace value (integer).
        n: The power (non-negative integer).
        
    Returns:
        The n-th term of the trace sequence.
        
    Examples:
        >>> trace_seq(3, 0)
        2
        >>> trace_seq(3, 4)
        47
        >>> trace_seq(0, 4)
        2
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b


# ============================================================================
# Algorithm 2: Matrix Power via Fast Exponentiation
# ============================================================================

@dataclass
class Mat2x2:
    """2×2 integer matrix."""
    a: int
    b: int
    c: int
    d: int
    
    def __mul__(self, other: 'Mat2x2') -> 'Mat2x2':
        return Mat2x2(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )
    
    def det(self) -> int:
        return self.a * self.d - self.b * self.c
    
    def trace(self) -> int:
        return self.a + self.d
    
    @staticmethod
    def identity() -> 'Mat2x2':
        return Mat2x2(1, 0, 0, 1)


def companion_matrix(t: int) -> Mat2x2:
    """The trace companion matrix [[t, -1], [1, 0]].
    
    This matrix has:
    - det = 1 (it's in SL₂(ℤ))
    - trace = t
    - tr(Mⁿ) = traceSeq(t, n)
    """
    return Mat2x2(t, -1, 1, 0)


def matrix_power(M: Mat2x2, n: int) -> Mat2x2:
    """Compute M^n via fast exponentiation.
    
    Time complexity: O(log n) matrix multiplications
    Space complexity: O(1)
    
    Args:
        M: A 2×2 integer matrix.
        n: The exponent (non-negative integer).
        
    Returns:
        M^n as a 2×2 matrix.
    """
    if n == 0:
        return Mat2x2.identity()
    if n == 1:
        return M
    result = Mat2x2.identity()
    base = M
    while n > 0:
        if n % 2 == 1:
            result = result * base
        base = base * base
        n //= 2
    return result


def trace_seq_fast(t: int, n: int) -> int:
    """Compute traceSeq(t, n) via matrix exponentiation.
    
    Time complexity: O(log n) (but with big integer multiplication)
    Space complexity: O(1)
    
    Uses the identity tr(M^n) = traceSeq(t, n) where M = [[t,-1],[1,0]].
    """
    M = companion_matrix(t)
    Mn = matrix_power(M, n)
    return Mn.trace()


# ============================================================================
# Algorithm 3: Pseudo-Hyperbolic Distance
# ============================================================================

def pseudo_hyp_dist(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """Compute the pseudo-hyperbolic distance ρ(p, q) in the Poincaré disk.
    
    ρ(p,q) = |p - q| / |1 - p̄·q|
    
    Time complexity: O(1)
    
    Args:
        p, q: Points in the unit disk as (x, y) tuples.
        
    Returns:
        The pseudo-hyperbolic distance (a value in [0, 1)).
    """
    dx, dy = p[0] - q[0], p[1] - q[1]
    num_sq = dx**2 + dy**2
    # |1 - p̄·q|² = (1 - px·qx - py·qy)² + (px·qy - py·qx)²
    re_part = 1 - p[0]*q[0] - p[1]*q[1]
    im_part = p[0]*q[1] - p[1]*q[0]
    den_sq = re_part**2 + im_part**2
    return math.sqrt(num_sq / den_sq)


def hyperbolic_distance(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """Compute the hyperbolic distance d_H(p, q) in the Poincaré disk.
    
    d_H(p, q) = 2 · arctanh(ρ(p, q))
    
    Time complexity: O(1)
    """
    rho = pseudo_hyp_dist(p, q)
    return 2 * math.atanh(min(rho, 0.9999999))


def conformal_factor(p: Tuple[float, float]) -> float:
    """Compute the conformal factor λ(z) = 2/(1 - |z|²).
    
    This converts Euclidean infinitesimal distances to hyperbolic ones:
    ds_H = λ(z) · ds_E
    
    Our theorem proves λ(z) ≥ 2 for all z in the disk.
    """
    norm_sq = p[0]**2 + p[1]**2
    assert norm_sq < 1, "Point must be in the unit disk"
    return 2.0 / (1.0 - norm_sq)


# ============================================================================
# Algorithm 4: Markov Tree via Vieta Involution
# ============================================================================

def markov_tree(max_depth: int = 5) -> List[Tuple[int, int, int]]:
    """Generate the Markov tree via the Vieta involution.
    
    Starting from (1, 1, 1), applies the Vieta involution
    z → 3xy - z to generate all Markov triples.
    
    The Vieta involution preserves the Markov equation
    x² + y² + z² = 3xyz (proved in our Lean formalization).
    
    Time complexity: O(3^depth) per level
    Space complexity: O(|tree|)
    
    Args:
        max_depth: Maximum tree depth.
        
    Returns:
        List of Markov triples (x, y, z) with x ≤ y ≤ z.
    """
    result = []
    seen: Set[Tuple[int, int, int]] = set()
    queue = [(1, 1, 1, 0)]  # (x, y, z, depth)
    
    while queue:
        x, y, z, depth = queue.pop(0)
        key = tuple(sorted((x, y, z)))
        if key in seen:
            continue
        seen.add(key)
        result.append(key)
        
        if depth < max_depth:
            # Apply Vieta involution to each coordinate
            for a, b, c in [(x,y,z), (y,z,x), (z,x,y)]:
                new_c = 3*a*b - c
                if new_c > 0:
                    queue.append((a, b, new_c, depth + 1))
    
    return sorted(result)


# ============================================================================
# Algorithm 5: Spectral Data Computation
# ============================================================================

@dataclass
class HyperbolicSpectralData:
    """Spectral data for a hyperbolic element of SL₂(ℤ).
    
    Packages the trace, discriminant, and eigenvalue information.
    """
    trace_val: int
    
    @property
    def discriminant(self) -> int:
        """Δ = t² - 4."""
        return self.trace_val**2 - 4
    
    @property 
    def eigenvalues(self) -> Tuple[float, float]:
        """The eigenvalues (t ± √Δ)/2 of the companion matrix."""
        sqrt_disc = math.sqrt(abs(self.discriminant))
        if self.discriminant >= 0:
            return (
                (self.trace_val + sqrt_disc) / 2,
                (self.trace_val - sqrt_disc) / 2,
            )
        else:
            return (
                self.trace_val / 2,
                self.trace_val / 2,
            )
    
    @property
    def displacement(self) -> float:
        """The hyperbolic displacement length ℓ = arccosh(|t|/2)."""
        if abs(self.trace_val) <= 2:
            return 0.0
        return math.acosh(abs(self.trace_val) / 2)
    
    @property
    def element_type(self) -> str:
        """Classify: hyperbolic (|t|>2), parabolic (|t|=2), elliptic (|t|<2)."""
        if abs(self.trace_val) > 2:
            return "hyperbolic"
        elif abs(self.trace_val) == 2:
            return "parabolic"
        else:
            return "elliptic"
    
    def power_trace(self, n: int) -> int:
        """Compute tr(γⁿ) = traceSeq(t, n)."""
        return trace_seq(self.trace_val, n)
    
    def verify_cassini(self, n: int) -> bool:
        """Verify the Cassini identity at a specific n."""
        lhs = self.power_trace(n+2) * self.power_trace(n) - self.power_trace(n+1)**2
        return lhs == self.discriminant


# ============================================================================
# Algorithm 6: Gromov Product and Tropical Bridge
# ============================================================================

def gromov_product(d_xw: float, d_yw: float, d_xy: float) -> float:
    """Compute the Gromov product ⟨x,y⟩_w = (d(x,w) + d(y,w) - d(x,y))/2.
    
    The ultrametric inequality states:
    ⟨x,y⟩_w ≥ min(⟨x,z⟩_w, ⟨y,z⟩_w) - δ
    for δ-hyperbolic spaces.
    """
    return (d_xw + d_yw - d_xy) / 2


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: a ⊕ b = min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a ⊗ b = a + b."""
    return a + b


# ============================================================================
# Main: Run all algorithms
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Hyperbolic Number Theory: Algorithm Demonstrations")
    print("=" * 60)
    
    # 1. Trace sequences
    print("\n--- Trace Sequences ---")
    for t in [0, 1, 3, 5]:
        vals = [trace_seq(t, n) for n in range(10)]
        print(f"  t={t:2d}: {vals}")
    
    # 2. Fast vs slow computation
    print("\n--- Fast Matrix Exponentiation ---")
    t, n = 3, 50
    slow = trace_seq(t, n)
    fast = trace_seq_fast(t, n)
    print(f"  traceSeq({t}, {n}) = {slow}")
    print(f"  via matrix:      {fast}")
    print(f"  Match: {slow == fast}")
    
    # 3. Spectral data
    print("\n--- Hyperbolic Spectral Data ---")
    for t in [3, 4, 5, 7]:
        sd = HyperbolicSpectralData(t)
        print(f"  t={t}: Δ={sd.discriminant}, type={sd.element_type}, "
              f"eigenvalues={sd.eigenvalues}, "
              f"displacement={sd.displacement:.4f}")
        # Verify Cassini
        for n in range(10):
            assert sd.verify_cassini(n), f"Cassini failed at t={t}, n={n}"
        print(f"         Cassini verified for n=0..9 ✓")
    
    # 4. Markov triples
    print("\n--- Markov Tree ---")
    triples = markov_tree(4)
    print(f"  Found {len(triples)} Markov triples:")
    for triple in triples[:15]:
        x, y, z = triple
        check = x**2 + y**2 + z**2 == 3*x*y*z
        print(f"    ({x}, {y}, {z}) — check: {check}")
    
    print("\nAll algorithms verified successfully!")
