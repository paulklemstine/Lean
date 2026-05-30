"""
Algorithms for Hyperbolic Number Theory
========================================

Core algorithms:
1. Markov tree generation via Vieta involution (BFS)
2. SL₂(ℤ) orbit computation on the Poincaré disk
3. Chebyshev polynomial evaluation for trace computation
4. Farey sequence generation and mediant construction

All algorithms have documented complexity.
"""

from typing import List, Tuple, Set, Optional
from collections import deque
import math


# ============================================================
# Algorithm 1: Markov Tree via Vieta Involution
# ============================================================

def generate_markov_tree(max_value: int = 10000) -> List[Tuple[int, int, int]]:
    """
    Generate all Markov triples (x,y,z) with max(x,y,z) ≤ max_value.
    
    Uses BFS on the Markov tree, applying Vieta involutions:
    Given (x,y,z) with x²+y²+z² = 3xyz, produce (x,y,3xy-z).
    
    Complexity:
        Time:  O(N log N) where N = number of Markov numbers ≤ max_value
        Space: O(N) for storing visited triples
    
    The number of Markov triples up to T grows as O(log²(T)),
    so this is very efficient.
    
    Args:
        max_value: Upper bound on the largest element in any triple.
    
    Returns:
        Sorted list of Markov triples (x, y, z) with x ≤ y ≤ z.
    
    Example:
        >>> triples = generate_markov_tree(100)
        >>> print(triples[:5])
        [(1, 1, 1), (1, 1, 2), (1, 2, 5), (1, 5, 13), (2, 5, 29)]
    """
    triples: Set[Tuple[int, int, int]] = set()
    queue: deque = deque([(1, 1, 1)])
    
    while queue:
        x, y, z = queue.popleft()
        triple = tuple(sorted([x, y, z]))
        if triple in triples or max(triple) > max_value:
            continue
        
        # Verify Markov equation
        assert x**2 + y**2 + z**2 == 3 * x * y * z, \
            f"Triple {triple} does not satisfy Markov equation"
        triples.add(triple)
        
        # Vieta jump on each coordinate
        for a, b, c in [(x, y, z), (y, z, x), (x, z, y)]:
            new_c = 3 * a * b - c
            if new_c > 0:
                queue.append((a, b, new_c))
    
    return sorted(triples)


# ============================================================
# Algorithm 2: SL₂(ℤ) Orbit on the Poincaré Disk
# ============================================================

def mobius_transform(a: complex, b: complex, c: complex, d: complex,
                     z: complex) -> complex:
    """
    Apply the Möbius transformation [[a,b],[c,d]] to z.
    
    φ(z) = (az + b) / (cz + d)
    
    Complexity: O(1)
    """
    denom = c * z + d
    if abs(denom) < 1e-15:
        return complex(float('inf'))
    return (a * z + b) / denom


def cayley_to_disk(z: complex) -> complex:
    """
    Cayley transform: upper half-plane → Poincaré disk.
    w = (z - i) / (z + i)
    
    Complexity: O(1)
    """
    i = complex(0, 1)
    if abs(z + i) < 1e-15:
        return complex(float('inf'))
    return (z - i) / (z + i)


def sl2z_orbit_disk(max_word_length: int = 5,
                    base_point: complex = complex(0, 2)
                    ) -> List[complex]:
    """
    Compute the orbit of base_point under SL₂(ℤ), mapped to the Poincaré disk.
    
    Uses BFS over words in the generators S and T of SL₂(ℤ).
    S: z → -1/z    T: z → z+1
    
    Complexity:
        Time:  O(4^L) where L = max_word_length (branching factor 4: S,S⁻¹,T,T⁻¹)
        Space: O(4^L) for storing orbit points
    
    Args:
        max_word_length: Maximum word length in generators S, T.
        base_point: Starting point in the upper half-plane.
    
    Returns:
        List of orbit points in the Poincaré disk (complex numbers with |z| < 1).
    """
    orbit_uhp: Set[Tuple[float, float]] = set()
    points: List[complex] = []
    
    # BFS over words
    queue: deque = deque([(base_point, 0)])
    
    while queue:
        z, depth = queue.popleft()
        
        # Discretize for deduplication
        key = (round(z.real, 8), round(z.imag, 8))
        if key in orbit_uhp or z.imag <= 0:
            continue
        orbit_uhp.add(key)
        
        # Map to disk
        w = cayley_to_disk(z)
        if abs(w) < 1:
            points.append(w)
        
        if depth < max_word_length:
            # Apply generators and inverses
            # S: z → -1/z
            if abs(z) > 1e-15:
                queue.append((-1/z, depth + 1))
            # T: z → z + 1
            queue.append((z + 1, depth + 1))
            # T⁻¹: z → z - 1
            queue.append((z - 1, depth + 1))
            # S⁻¹ = S (S is order 2 in PSL₂)
    
    return points


# ============================================================
# Algorithm 3: Chebyshev Polynomial (Trace Version)
# ============================================================

def chebyshev_trace(n: int, t: int) -> int:
    """
    Compute the trace Chebyshev polynomial T_n(t).
    
    Defined by: T_0(t) = 2, T_1(t) = t, T_{n+1}(t) = t·T_n(t) - T_{n-1}(t)
    
    This gives tr(g^n) = T_n(tr(g)) for g ∈ SL₂.
    
    Complexity:
        Time:  O(n) multiplications
        Space: O(1)
    
    Args:
        n: Non-negative integer exponent.
        t: The trace value (integer).
    
    Returns:
        T_n(t) = tr(g^n) where tr(g) = t.
    
    Example:
        >>> chebyshev_trace(0, 3)  # T_0 = 2
        2
        >>> chebyshev_trace(1, 3)  # T_1 = t
        3
        >>> chebyshev_trace(2, 3)  # T_2 = t² - 2
        7
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


# ============================================================
# Algorithm 4: Farey Sequence Generation
# ============================================================

def farey_sequence(n: int) -> List[Tuple[int, int]]:
    """
    Generate the Farey sequence F_n as a list of (numerator, denominator) pairs.
    
    Uses the mediant property: if a/b and c/d are consecutive in F_n,
    then c/d = mediant of a/b and next term, with |ad - bc| = 1.
    
    Complexity:
        Time:  O(n²) — |F_n| = 1 + Σ_{k=1}^n φ(k) ≈ 3n²/π²
        Space: O(n²)
    
    Args:
        n: Order of the Farey sequence.
    
    Returns:
        List of (numerator, denominator) pairs in increasing order.
    
    Example:
        >>> farey_sequence(3)
        [(0, 1), (1, 3), (1, 2), (2, 3), (1, 1)]
    """
    # Start with F_1 = [0/1, 1/1]
    a, b = 0, 1
    c, d = 1, n
    result = [(a, b)]
    
    while c <= n:
        result.append((c, d))
        # Compute next term using mediant
        k = (n + b) // d
        a, b, c, d = c, d, k * c - a, k * d - b
    
    return result


# ============================================================
# Algorithm 5: Hyperbolic Distance
# ============================================================

def hyperbolic_distance(z: complex, w: complex) -> float:
    """
    Compute the hyperbolic distance between z and w in the Poincaré disk.
    
    d(z, w) = 2 · arctanh(|z - w| / |1 - conj(z)·w|)
    
    Complexity: O(1)
    
    Args:
        z, w: Points in the Poincaré disk (|z| < 1, |w| < 1).
    
    Returns:
        Hyperbolic distance d(z, w).
    """
    num = abs(z - w)
    den = abs(1 - z.conjugate() * w)
    if den < 1e-15:
        return float('inf')
    ratio = num / den
    if ratio >= 1:
        return float('inf')
    return 2 * math.atanh(ratio)


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("Algorithm 1: Markov Tree Generation")
    print("-" * 40)
    triples = generate_markov_tree(1000)
    print(f"Found {len(triples)} Markov triples with max ≤ 1000")
    print(f"First 10: {triples[:10]}")
    markov_nums = sorted(set(n for t in triples for n in t))
    print(f"Markov numbers: {markov_nums[:20]}...")
    
    print(f"\nAlgorithm 2: SL₂(ℤ) Orbit on Disk")
    print("-" * 40)
    orbit = sl2z_orbit_disk(max_word_length=4)
    print(f"Found {len(orbit)} orbit points (word length ≤ 4)")
    
    dists = sorted(hyperbolic_distance(0, p) for p in orbit if abs(p) < 0.999)
    print(f"Hyperbolic distances from origin: {[f'{d:.3f}' for d in dists[:10]]}...")
    
    print(f"\nAlgorithm 3: Chebyshev Traces")
    print("-" * 40)
    for t in [2, 3, 4]:
        traces = [chebyshev_trace(n, t) for n in range(8)]
        print(f"  tr(g)={t}: T_n = {traces}")
    
    print(f"\nAlgorithm 4: Farey Sequences")
    print("-" * 40)
    for n in [3, 5, 7]:
        F = farey_sequence(n)
        print(f"  F_{n} has {len(F)} terms: {F[:8]}...")
    
    print(f"\nAlgorithm 5: Hyperbolic Distance")
    print("-" * 40)
    z1, z2 = complex(0.3, 0.2), complex(-0.1, 0.4)
    print(f"  d({z1}, {z2}) = {hyperbolic_distance(z1, z2):.6f}")
    print(f"  d(0, 0.5) = {hyperbolic_distance(0, 0.5):.6f}")
    print(f"  d(0, 0.9) = {hyperbolic_distance(0, 0.9):.6f}")
    print(f"  d(0, 0.99) = {hyperbolic_distance(0, 0.99):.6f}")
