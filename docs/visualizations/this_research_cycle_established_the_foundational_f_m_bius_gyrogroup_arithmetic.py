#!/usr/bin/env python3
"""
Algorithms for Hyperbolic Number Theory

Implements the core mathematical algorithms from the research paper:
1. Möbius gyrogroup arithmetic
2. Hyperbolic zeta function computation
3. Regular tree enumeration
4. Pythagorean-to-disk embedding

All algorithms include complexity analysis and type hints.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Iterator
import math


# ============================================================
# Algorithm 1: Möbius Gyrogroup Arithmetic
# ============================================================

class MoebiusGyrogroup:
    """
    Implements the Möbius gyrogroup on the open interval (-1, 1).
    
    The operation a ⊕ b = (a + b) / (1 + ab) forms a gyrogroup:
    - Commutative: a ⊕ b = b ⊕ a
    - Has identity: a ⊕ 0 = a
    - Has inverses: a ⊕ (-a) = 0
    - NOT associative (gyroassociative instead)
    
    Time complexity: O(1) per operation (using exact rational arithmetic)
    Space complexity: O(1) per element
    """
    
    def __init__(self, val: Fraction):
        """Initialize with a rational number in (-1, 1)."""
        if abs(val) >= 1:
            raise ValueError(f"Value {val} not in open unit interval (-1, 1)")
        self.val = val
    
    def __add__(self, other: 'MoebiusGyrogroup') -> 'MoebiusGyrogroup':
        """Möbius addition: (a + b) / (1 + ab)"""
        num = self.val + other.val
        den = 1 + self.val * other.val
        return MoebiusGyrogroup(num / den)
    
    def __neg__(self) -> 'MoebiusGyrogroup':
        """Möbius inverse: -a"""
        return MoebiusGyrogroup(-self.val)
    
    def __repr__(self) -> str:
        return f"M({self.val})"
    
    def __eq__(self, other: 'MoebiusGyrogroup') -> bool:
        return self.val == other.val
    
    @staticmethod
    def zero() -> 'MoebiusGyrogroup':
        """The identity element."""
        return MoebiusGyrogroup(Fraction(0))
    
    @staticmethod
    def gyration(a: 'MoebiusGyrogroup', b: 'MoebiusGyrogroup', 
                 x: 'MoebiusGyrogroup') -> 'MoebiusGyrogroup':
        """
        Gyration operator gyr[a,b](x).
        In the 1D case, gyr[a,b] = id, so the gyrogroup is actually
        a commutative group (gyrocommutative gyrogroup with trivial gyration).
        """
        return x  # Trivial in 1D
    
    def iterate(self, n: int) -> 'MoebiusGyrogroup':
        """
        Compute the n-fold Möbius sum: a ⊕ a ⊕ ... ⊕ a (n times).
        Uses the iterative formula x_{k+1} = a ⊕ x_k.
        
        Time: O(n) arithmetic operations
        Space: O(1)
        """
        result = self
        current = self
        for _ in range(n - 1):
            current = self + current
        return current


# ============================================================
# Algorithm 2: Hyperbolic Zeta Function
# ============================================================

def hyperbolic_zeta_summand(r: float, s: int) -> float:
    """
    Compute the hyperbolic zeta summand r^{-2s}.
    
    For 0 < r < 1 (a disk point), this gives values ≥ 1,
    reversing the classical bound.
    
    Time: O(log s) via fast exponentiation
    Space: O(1)
    """
    return (1.0 / r) ** (2 * s)


def hyperbolic_zeta_partial(r: float, s: float, N: int) -> float:
    """
    Compute partial sum of hyperbolic zeta function:
    Z_hyp(r, s) = sum_{n=1}^{N} r^{-2ns}
    
    WARNING: This diverges for 0 < r < 1, s > 0 (the reversal!).
    
    Time: O(N)
    Space: O(1)
    """
    return sum((1.0 / r) ** (2 * n * s) for n in range(1, N + 1))


def classical_zeta_partial(s: float, N: int) -> float:
    """
    Classical Riemann zeta partial sum for comparison:
    zeta(s) ≈ sum_{n=1}^{N} 1/n^s
    
    Time: O(N)
    Space: O(1)
    """
    return sum(1.0 / n**s for n in range(1, N + 1))


# ============================================================
# Algorithm 3: Regular Tree Enumeration
# ============================================================

def tree_sphere_size(q: int, k: int) -> int:
    """
    Number of vertices at distance exactly k from root
    in a (q+1)-regular tree.
    
    Formula: S(0) = 1, S(k) = (q+1) * q^{k-1} for k ≥ 1
    
    Time: O(log k) via fast exponentiation
    Space: O(1)
    """
    if k == 0:
        return 1
    return (q + 1) * q ** (k - 1)


def tree_ball_size(q: int, n: int) -> int:
    """
    Number of vertices within distance n of root
    in a (q+1)-regular tree.
    
    Formula: B(n) = 1 + (q+1) * (q^n - 1) / (q - 1) for q ≥ 2
    
    Time: O(n) or O(log n) with closed form
    Space: O(1)
    """
    return sum(tree_sphere_size(q, k) for k in range(n + 1))


def verify_exponential_growth(q: int, max_n: int = 20) -> List[Tuple[int, int, int, bool]]:
    """
    Verify the exponential growth theorem: q^n ≤ treeBall(q, n).
    
    Returns list of (n, q^n, ball_size, growth_holds).
    
    Time: O(max_n * n) total
    Space: O(max_n) for results
    """
    results = []
    for n in range(max_n + 1):
        qn = q ** n
        ball = tree_ball_size(q, n)
        results.append((n, qn, ball, ball >= qn))
    return results


# ============================================================
# Algorithm 4: Pythagorean-to-Disk Embedding
# ============================================================

def generate_pythagorean_triples(max_c: int) -> Iterator[Tuple[int, int, int]]:
    """
    Generate primitive Pythagorean triples (a, b, c) with c ≤ max_c.
    Uses the parametrization a = m²-n², b = 2mn, c = m²+n² 
    for m > n > 0, gcd(m,n) = 1, m-n odd.
    
    Time: O(max_c) triples generated
    Space: O(1) per triple (generator)
    """
    for m in range(2, int(max_c**0.5) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if math.gcd(m, n) != 1:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_c:
                break
            yield (min(a, b), max(a, b), c)


def embed_in_disk(triple: Tuple[int, int, int]) -> Tuple[float, float]:
    """
    Embed a Pythagorean triple (a, b, c) into the Poincaré disk
    as the point (a/c, b/c).
    
    Time: O(1)
    Space: O(1)
    """
    a, b, c = triple
    return (a / c, b / c)


def moebius_sum_of_embeddings(t1: Tuple[int, int, int], 
                               t2: Tuple[int, int, int]) -> float:
    """
    Compute the Möbius sum of the a/c embeddings of two Pythagorean triples.
    
    Time: O(1)
    Space: O(1)
    """
    r1 = t1[0] / t1[2]
    r2 = t2[0] / t2[2]
    return (r1 + r2) / (1 + r1 * r2)


# ============================================================
# Algorithm 5: Möbius Iteration Analysis
# ============================================================

def moebius_iterate_sequence(a: Fraction, n: int) -> List[Fraction]:
    """
    Compute the Möbius iteration sequence x_0 = a, x_{k+1} = a ⊕ x_k.
    
    Time: O(n) Möbius additions
    Space: O(n) for the full sequence
    """
    seq = [a]
    x = a
    for _ in range(n):
        x = (a + x) / (1 + a * x)
        seq.append(x)
    return seq


def check_monotonicity(seq: List[Fraction]) -> bool:
    """Check if a sequence is strictly increasing."""
    return all(seq[i] < seq[i+1] for i in range(len(seq) - 1))


def estimate_limit(seq: List[Fraction], tail: int = 5) -> float:
    """
    Estimate the limit of the sequence using Richardson extrapolation.
    
    Time: O(tail)
    Space: O(1)
    """
    # Use ratio of consecutive differences
    vals = [float(x) for x in seq[-tail:]]
    if len(vals) < 3:
        return vals[-1]
    
    diffs = [vals[i+1] - vals[i] for i in range(len(vals)-1)]
    if abs(diffs[-1]) < 1e-15:
        return vals[-1]
    
    ratios = [diffs[i+1] / diffs[i] for i in range(len(diffs)-1) if abs(diffs[i]) > 1e-15]
    if ratios:
        avg_ratio = sum(ratios) / len(ratios)
        if abs(avg_ratio) < 1:
            return vals[-1] + diffs[-1] / (1 - avg_ratio)
    
    return vals[-1]


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Hyperbolic Number Theory — Algorithm Demonstrations")
    print("=" * 55)
    
    # Gyrogroup
    a = MoebiusGyrogroup(Fraction(1, 3))
    b = MoebiusGyrogroup(Fraction(1, 4))
    print(f"\nGyrogroup: {a} + {b} = {a + b}")
    print(f"Identity: {a} + 0 = {a + MoebiusGyrogroup.zero()}")
    print(f"Inverse: {a} + (-{a}) = {a + (-a)}")
    
    # Zeta reversal
    print(f"\nZeta reversal (r=0.5):")
    for s in range(1, 6):
        print(f"  Hyperbolic summand (s={s}): {hyperbolic_zeta_summand(0.5, s):.1f}")
    
    # Tree growth
    print(f"\nTree growth verification (q=3):")
    for n, qn, ball, ok in verify_exponential_growth(3, 10):
        print(f"  n={n}: 3^n={qn:>8}, ball={ball:>8}, growth: {ok}")
    
    # Iteration
    print(f"\nMöbius iteration (a=1/2):")
    seq = moebius_iterate_sequence(Fraction(1, 2), 15)
    print(f"  Monotone: {check_monotonicity(seq)}")
    print(f"  Estimated limit: {estimate_limit(seq):.10f}")
    print(f"  tanh(artanh(0.5) * inf) → 1.0 (boundary)")
