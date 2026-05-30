"""
Hyperbolic Number Theory: Core Algorithms
==========================================
Implements the mathematical machinery for hyperbolic arithmetic
on the Poincaré disk, including SL₂(ℝ) group operations,
orbit generation, and counting functions.
"""

import math
from typing import Tuple, List, Dict, Optional, Set

# ============================================================
# Algorithm 1: SL₂(ℝ) Arithmetic
# ============================================================

class SL2RMatrix:
    """
    Element of SL₂(ℝ): 2×2 real matrix with determinant 1.
    
    Supports multiplication, inversion, power, and trace computation.
    Time complexity: O(1) for all operations except power (O(n)).
    Space complexity: O(1).
    """
    
    __slots__ = ('a', 'b', 'c', 'd')
    
    def __init__(self, a: float, b: float, c: float, d: float):
        self.a, self.b, self.c, self.d = a, b, c, d
    
    @property
    def det(self) -> float:
        """Determinant. Should always be ≈ 1."""
        return self.a * self.d - self.b * self.c
    
    @property
    def trace(self) -> float:
        """Trace: classifies as elliptic (|tr|<2), parabolic (|tr|=2), hyperbolic (|tr|>2)."""
        return self.a + self.d
    
    @property
    def discriminant(self) -> float:
        """tr² - 4: positive for hyperbolic, zero for parabolic, negative for elliptic."""
        return self.trace ** 2 - 4
    
    def classify(self) -> str:
        """Classify the transformation type."""
        d = self.discriminant
        if abs(d) < 1e-10:
            return "parabolic"
        return "hyperbolic" if d > 0 else "elliptic"
    
    def __matmul__(self, other: 'SL2RMatrix') -> 'SL2RMatrix':
        """Matrix multiplication. O(1)."""
        return SL2RMatrix(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d
        )
    
    def inv(self) -> 'SL2RMatrix':
        """Matrix inverse: [[d,-b],[-c,a]] for det=1. O(1)."""
        return SL2RMatrix(self.d, -self.b, -self.c, self.a)
    
    def power(self, n: int) -> 'SL2RMatrix':
        """
        Matrix power by repeated squaring. O(log n).
        
        Uses the identity g^(m+n) = g^m · g^n proved in Lean.
        """
        if n == 0:
            return SL2RMatrix(1, 0, 0, 1)
        if n < 0:
            return self.inv().power(-n)
        if n == 1:
            return SL2RMatrix(self.a, self.b, self.c, self.d)
        if n % 2 == 0:
            half = self.power(n // 2)
            return half @ half
        else:
            return self @ self.power(n - 1)
    
    def key(self, precision: int = 8) -> Tuple[float, ...]:
        """Hashable key for deduplication."""
        return (round(self.a, precision), round(self.b, precision),
                round(self.c, precision), round(self.d, precision))
    
    def __repr__(self):
        return f"[[{self.a:.4f}, {self.b:.4f}], [{self.c:.4f}, {self.d:.4f}]]"


# ============================================================
# Algorithm 2: Trace Chebyshev Recurrence
# ============================================================

def trace_sequence(g: SL2RMatrix, n_terms: int) -> List[float]:
    """
    Compute trace sequence tr(g^k) for k = 0, 1, ..., n_terms-1
    using the Chebyshev recurrence: tr(g^{k+2}) = tr(g)·tr(g^{k+1}) - tr(g^k).
    
    This is proved in Lean as `hypsl2_trace_sq` (base case)
    and conjectured as `sl2r_trace_recurrence` (general).
    
    Time: O(n_terms)
    Space: O(n_terms) for output, O(1) working space
    """
    if n_terms <= 0:
        return []
    
    t = g.trace
    traces = [2.0]  # tr(g^0) = tr(I) = 2
    
    if n_terms >= 2:
        traces.append(t)  # tr(g^1) = tr(g)
    
    for k in range(2, n_terms):
        # Chebyshev recurrence: T_{k} = t · T_{k-1} - T_{k-2}
        next_trace = t * traces[-1] - traces[-2]
        traces.append(next_trace)
    
    return traces


# ============================================================
# Algorithm 3: PSL(2,ℤ) Orbit Generation
# ============================================================

def generate_psl2z_orbit(max_depth: int = 6) -> Dict[Tuple, SL2RMatrix]:
    """
    Generate orbit of the identity under PSL(2,ℤ) = ⟨S, T⟩ where
    S = [[0,-1],[1,0]] and T = [[1,1],[0,1]].
    
    Uses BFS to enumerate all words of length ≤ max_depth.
    
    Time: O(3^max_depth) worst case
    Space: O(|orbit|)
    
    Returns: dict mapping matrix keys to SL2RMatrix objects
    """
    S = SL2RMatrix(0, -1, 1, 0)
    T = SL2RMatrix(1, 1, 0, 1)
    generators = [S, T, T.inv()]
    
    orbit: Dict[Tuple, SL2RMatrix] = {}
    identity = SL2RMatrix(1, 0, 0, 1)
    orbit[identity.key()] = identity
    
    frontier = [identity]
    
    for depth in range(max_depth):
        next_frontier = []
        for g in frontier:
            for gen in generators:
                h = g @ gen
                k = h.key()
                if k not in orbit:
                    orbit[k] = h
                    next_frontier.append(h)
        frontier = next_frontier
    
    return orbit


# ============================================================
# Algorithm 4: Upper Half-Plane to Disk Mapping
# ============================================================

def mobius_action_on_i(g: SL2RMatrix) -> Tuple[float, float]:
    """
    Compute g(i) where g acts on the upper half-plane.
    g(z) = (az + b)/(cz + d), evaluated at z = i.
    
    Returns (Re(g(i)), Im(g(i))).
    """
    # g(i) = (ai + b)/(ci + d) = (b + ai)(d - ci) / (c² + d²)
    denom = g.c**2 + g.d**2
    if denom < 1e-15:
        return (float('inf'), float('inf'))
    re = (g.a * g.c + g.b * g.d) / denom
    im = (g.a * g.d - g.b * g.c) / denom  # = 1/denom since det=1
    return (re, im)


def cayley_transform(z_re: float, z_im: float) -> Tuple[float, float]:
    """
    Cayley transform: maps upper half-plane to Poincaré disk.
    w = (z - i)/(z + i)
    
    Returns (Re(w), Im(w)).
    """
    num_re = z_re
    num_im = z_im - 1
    den_re = z_re
    den_im = z_im + 1
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-15:
        return (0.0, 0.0)
    w_re = (num_re * den_re + num_im * den_im) / den_sq
    w_im = (num_im * den_re - num_re * den_im) / den_sq
    return (w_re, w_im)


def orbit_to_disk_points(orbit: Dict[Tuple, SL2RMatrix]) -> List[Tuple[float, float, float]]:
    """
    Map orbit matrices to points in the Poincaré disk.
    
    Returns list of (x, y, |z|²) tuples.
    """
    points = []
    for g in orbit.values():
        z_re, z_im = mobius_action_on_i(g)
        if z_im <= 0 or z_re == float('inf'):
            continue
        w_re, w_im = cayley_transform(z_re, z_im)
        r_sq = w_re**2 + w_im**2
        if r_sq < 1 - 1e-10:
            points.append((w_re, w_im, r_sq))
    return points


# ============================================================
# Algorithm 5: Hyperbolic Counting Function
# ============================================================

def count_in_radius(points: List[Tuple[float, float, float]], r: float) -> int:
    """
    Count points with |z|² ≤ r².
    
    Proved monotone in Lean: countInRadius_mono.
    Time: O(|points|)
    """
    r_sq = r ** 2
    return sum(1 for _, _, rsq in points if rsq <= r_sq)


# ============================================================
# Algorithm 6: Euler Totient and Farey Count
# ============================================================

def euler_totient(n: int) -> int:
    """
    Euler's totient function φ(n).
    
    Properties proved in Lean:
    - totient_prime_eq: φ(p) = p-1 for prime p
    - totient_mul_coprime: φ(mn) = φ(m)φ(n) for gcd(m,n)=1
    
    Time: O(√n)
    """
    if n <= 1:
        return n
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def totient_sum(n: int) -> int:
    """
    Cumulative sum Σ_{k=1}^n φ(k).
    
    Proved in Lean: totientSumH_ge shows this ≥ n.
    This equals |F_n| - 1 where F_n is the Farey sequence of order n.
    
    Time: O(n√n)
    """
    return sum(euler_totient(k) for k in range(1, n + 1))


# ============================================================
# Algorithm 7: Hyperbolic Distance
# ============================================================

def poincare_distance(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """
    Hyperbolic distance in the Poincaré disk model.
    d(p,q) = 2·arctanh(|p-q| / √((1-|p|²)(1-|q|²) + |p-q|²))
    
    We use the log form proved in Lean:
    d(p,q) = log(1 + 2|p-q|²/((1-|p|²)(1-|q|²)))
    
    Properties proved:
    - hypDist_nonneg: d(p,q) ≥ 0
    - hypDist_self: d(p,p) = 0
    - mhypDist_comm: d(p,q) = d(q,p)
    - mhypDist_pos_of_ne: p ≠ q → d(p,q) > 0
    
    Time: O(1)
    """
    dx = p[0] - q[0]
    dy = p[1] - q[1]
    delta_sq = dx**2 + dy**2
    p_sq = p[0]**2 + p[1]**2
    q_sq = q[0]**2 + q[1]**2
    denom = (1 - p_sq) * (1 - q_sq)
    if denom <= 0:
        return float('inf')
    return math.log(1 + 2 * delta_sq / denom)


if __name__ == "__main__":
    # Quick self-test
    g = SL2RMatrix(2, 1, 1, 1)
    traces = trace_sequence(g, 10)
    print("Trace sequence:", [f"{t:.0f}" for t in traces])
    
    orbit = generate_psl2z_orbit(5)
    print(f"Orbit size at depth 5: {len(orbit)}")
    
    pts = orbit_to_disk_points(orbit)
    print(f"Disk points: {len(pts)}")
    
    print(f"φ(12) = {euler_totient(12)}")
    print(f"Σφ(k) for k=1..10 = {totient_sum(10)}")
