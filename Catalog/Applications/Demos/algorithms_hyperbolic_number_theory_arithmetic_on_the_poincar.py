#!/usr/bin/env python3
"""
Algorithms for Hyperbolic Number Theory

Implements key algorithms from the research paper with full documentation,
type hints, and complexity analysis.
"""

from typing import List, Tuple, Optional, Set
import math


# ============================================================================
# Algorithm 1: Trace Sequence Computation (Chebyshev Recurrence)
# ============================================================================

def trace_seq(t: int, n: int) -> int:
    """
    Compute the trace sequence traceSeq(t, n) via the Chebyshev recurrence.

    This gives tr(g^n) where g ∈ SL₂(ℤ) has trace t.
    Satisfies: traceSeq(t, 0) = 2, traceSeq(t, 1) = t,
               traceSeq(t, n+2) = t * traceSeq(t, n+1) - traceSeq(t, n)

    Time: O(n), Space: O(1)

    Args:
        t: The base trace value (integer ≥ 2 for hyperbolic elements)
        n: The power index (non-negative integer)

    Returns:
        The n-th term of the trace sequence with base t.

    Examples:
        >>> trace_seq(3, 0)
        2
        >>> trace_seq(3, 3)
        18
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    prev2, prev1 = 2, t
    for _ in range(n - 1):
        prev2, prev1 = prev1, t * prev1 - prev2
    return prev1


def trace_seq_matrix(t: int, n: int) -> int:
    """
    Compute traceSeq(t, n) via matrix exponentiation.

    Uses the recurrence matrix [[t, -1], [1, 0]] raised to power n.

    Time: O(log n), Space: O(1)

    Args:
        t: The base trace value
        n: The power index

    Returns:
        The n-th term of the trace sequence.
    """
    if n == 0:
        return 2
    if n == 1:
        return t

    def mat_mul(A: Tuple, B: Tuple) -> Tuple:
        return (
            A[0] * B[0] + A[1] * B[2],
            A[0] * B[1] + A[1] * B[3],
            A[2] * B[0] + A[3] * B[2],
            A[2] * B[1] + A[3] * B[3],
        )

    # Matrix [[t, -1], [1, 0]]
    base = (t, -1, 1, 0)
    result = (1, 0, 0, 1)  # Identity

    power = n - 1
    while power > 0:
        if power & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        power >>= 1

    # result * [t, 2]^T gives [traceSeq(t, n), traceSeq(t, n-1)]
    return result[0] * t + result[1] * 2


# ============================================================================
# Algorithm 2: Markov Tree Generation via Vieta Involutions
# ============================================================================

def generate_markov_triples(max_value: int = 1000) -> List[Tuple[int, int, int]]:
    """
    Generate all Markov triples (x, y, z) with max(x,y,z) ≤ max_value.

    Uses BFS on the Markov tree, applying Vieta involutions:
    (x, y, z) → (x, y, 3xy - z) and permutations.

    The Markov equation is x² + y² + z² = 3xyz.

    Time: O(N log N) where N is the number of triples found
    Space: O(N)

    Args:
        max_value: Upper bound on the largest element.

    Returns:
        Sorted list of Markov triples.
    """
    seen: Set[Tuple[int, int, int]] = set()
    queue = [(1, 1, 1)]
    seen.add((1, 1, 1))

    while queue:
        x, y, z = queue.pop(0)
        # Apply Vieta involution to each coordinate
        for a, b, c in [(x, y, z), (x, z, y), (y, z, x)]:
            new_c = 3 * a * b - c
            if new_c > 0:
                triple = tuple(sorted((a, b, new_c)))
                if triple not in seen and max(triple) <= max_value:
                    seen.add(triple)
                    queue.append(triple)

    return sorted(seen)


# ============================================================================
# Algorithm 3: Primitive Trace Classification
# ============================================================================

def classify_traces(N: int) -> Tuple[List[int], List[int]]:
    """
    Classify traces in [3, N] as primitive or imprimitive.

    A trace t is imprimitive if t + 2 = s² for some integer s ≥ 2
    (equivalently, t is the trace of a square of some element).

    Time: O(N), Space: O(N)

    Args:
        N: Upper bound for trace values.

    Returns:
        (primitives, imprimitives): Lists of primitive and imprimitive traces.
    """
    primitives = []
    imprimitives = []

    for t in range(3, N + 1):
        s = int(math.isqrt(t + 2))
        if s >= 2 and s * s == t + 2:
            imprimitives.append(t)
        else:
            primitives.append(t)

    return primitives, imprimitives


# ============================================================================
# Algorithm 4: Pseudo-Hyperbolic Distance
# ============================================================================

def pseudo_hyp_dist(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """
    Compute the pseudo-hyperbolic distance between two points in the Poincaré disk.

    δ(z,w) = |z-w| / |1-z̄w|

    The actual hyperbolic distance is d = 2·arctanh(δ).

    Time: O(1), Space: O(1)

    Args:
        p: Point (x₁, y₁) with x₁²+y₁² < 1
        q: Point (x₂, y₂) with x₂²+y₂² < 1

    Returns:
        The pseudo-hyperbolic distance δ(p, q) ∈ [0, 1).
    """
    px, py = p
    qx, qy = q

    num_sq = (px - qx) ** 2 + (py - qy) ** 2
    den_sq = (1 - px * qx - py * qy) ** 2 + (px * qy - py * qx) ** 2

    return math.sqrt(num_sq / den_sq)


def hyperbolic_distance(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """
    Compute the actual hyperbolic distance in the Poincaré disk model.

    d(z,w) = 2·arctanh(δ(z,w))

    Time: O(1), Space: O(1)
    """
    delta = pseudo_hyp_dist(p, q)
    if delta >= 1:
        return float('inf')
    return 2 * math.atanh(delta)


# ============================================================================
# Algorithm 5: SL₂(ℤ) Element from Trace (Constructive Witness)
# ============================================================================

def sl2z_from_trace(n: int) -> Tuple[int, int, int, int]:
    """
    Construct an explicit SL₂(ℤ) element with given trace n (for n ≥ 2).

    Returns [[n-1, 1], [n-2, 1]] which has determinant 1 and trace n.

    Time: O(1), Space: O(1)

    Args:
        n: Desired trace value (integer ≥ 2)

    Returns:
        (a, b, c, d) with ad - bc = 1 and a + d = n
    """
    assert n >= 2, f"Trace must be ≥ 2, got {n}"
    a, b, c, d = n - 1, 1, n - 2, 1
    assert a * d - b * c == 1
    assert a + d == n
    return (a, b, c, d)


# ============================================================================
# Algorithm 6: Fundamental Discriminant Computation
# ============================================================================

def fundamental_disc(t: int) -> int:
    """
    Compute the fundamental discriminant D = t² - 4 associated to trace t.

    This determines the quadratic field ℚ(√D) associated to a hyperbolic
    element with trace t.

    Time: O(1), Space: O(1)
    """
    return t * t - 4


def discriminant_class_table(max_t: int) -> dict:
    """
    Build a table mapping discriminants to trace values.

    Time: O(max_t), Space: O(max_t)

    Returns:
        Dict mapping D → list of trace values t with t² - 4 ≡ D (mod squares)
    """
    table = {}
    for t in range(3, max_t + 1):
        D = fundamental_disc(t)
        # Find the square-free part
        d = D
        for p in range(2, int(math.isqrt(D)) + 1):
            while d % (p * p) == 0:
                d //= (p * p)
        if d not in table:
            table[d] = []
        table[d].append(t)
    return table


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Trace sequence
    print("Trace sequence for t=3:")
    for n in range(10):
        v1 = trace_seq(3, n)
        v2 = trace_seq_matrix(3, n)
        assert v1 == v2, f"Mismatch at n={n}"
        print(f"  traceSeq(3, {n}) = {v1}")

    # Markov triples
    print("\nMarkov triples with max ≤ 100:")
    triples = generate_markov_triples(100)
    for t in triples:
        print(f"  {t}")

    # Primitive trace density
    print("\nPrimitive trace density for N=1000:")
    prims, imprims = classify_traces(1000)
    print(f"  Primitives: {len(prims)}, Imprimitives: {len(imprims)}")
    print(f"  Density: {len(prims)/998:.4f}")

    # Hyperbolic distance
    print("\nHyperbolic distances:")
    points = [(0, 0), (0.5, 0), (0.3, 0.4), (-0.2, 0.1)]
    for i, p in enumerate(points):
        for j, q in enumerate(points):
            if i < j:
                d = hyperbolic_distance(p, q)
                print(f"  d({p}, {q}) = {d:.4f}")

    # Discriminant table
    print("\nDiscriminant class table (square-free parts):")
    table = discriminant_class_table(20)
    for d in sorted(table.keys()):
        print(f"  D_sf={d}: traces {table[d]}")
