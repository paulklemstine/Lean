"""
Algorithms for Interval Preconnectedness and Pythagorean Sine Approximation

Implements:
1. Berggren tree traversal for primitive Pythagorean triple enumeration
2. Best rational approximation of reals by Pythagorean sines
3. Gap analysis for density testing
"""

import math
from typing import List, Tuple, Optional
from collections import deque


def berggren_matrices() -> List:
    """
    Return the three Berggren transformation matrices.
    
    Each matrix M satisfies: if (a,b,c) is a primitive Pythagorean triple,
    then M·(a,b,c)ᵀ is also a primitive Pythagorean triple.
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    # Matrix A
    A = lambda a, b, c: (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    # Matrix B
    B = lambda a, b, c: (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    # Matrix C
    C = lambda a, b, c: (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    return [A, B, C]


def enumerate_primitive_triples_bfs(max_hypotenuse: int = 1000) -> List[Tuple[int, int, int]]:
    """
    Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hypotenuse
    using BFS on the Berggren tree.
    
    Algorithm:
        1. Start with root triple (3, 4, 5)
        2. Apply three Berggren matrices to generate children
        3. Prune branches where hypotenuse exceeds bound
        4. Normalize so that a ≤ b
    
    Time complexity: O(N) where N is the number of triples with c ≤ max_hypotenuse
    Space complexity: O(N) for storing results
    
    Returns:
        Sorted list of (a, b, c) with a ≤ b, a² + b² = c², gcd(a,c) = 1
    """
    transforms = berggren_matrices()
    triples = []
    queue = deque([(3, 4, 5)])
    
    while queue:
        a, b, c = queue.popleft()
        # Normalize
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        if c <= max_hypotenuse and a > 0 and b > 0:
            triples.append((a, b, c))
            for T in transforms:
                na, nb, nc = T(a, b, c)
                if nc <= max_hypotenuse:
                    queue.append((abs(na), abs(nb), nc))
    
    return sorted(set(triples), key=lambda t: (t[2], t[0]))


def pythagorean_sine_approximation(
    target: float, 
    max_hypotenuse: int = 10000,
    tolerance: float = 1e-6
) -> Optional[Tuple[int, int, int, float]]:
    """
    Find the primitive Pythagorean triple whose sine a/c best approximates target.
    
    Algorithm:
        1. Generate all primitive triples up to max_hypotenuse via Berggren BFS
        2. Compute sine = min(a,b)/c for each triple
        3. Return triple minimizing |sine - target|
    
    Args:
        target: Value in (0, 1) to approximate
        max_hypotenuse: Upper bound on hypotenuse search
        tolerance: Stop early if approximation within tolerance
    
    Time complexity: O(N log N) where N = number of triples
    Space complexity: O(N)
    
    Returns:
        (a, b, c, sine) or None if no triple found
    """
    triples = enumerate_primitive_triples_bfs(max_hypotenuse)
    
    best = None
    best_error = float('inf')
    
    for a, b, c in triples:
        sine = a / c  # a ≤ b, so a/c is the smaller ratio
        error = abs(sine - target)
        if error < best_error:
            best_error = error
            best = (a, b, c, sine)
            if error < tolerance:
                break
    
    return best


def gap_analysis(max_hypotenuse: int = 5000) -> dict:
    """
    Analyze gaps in the Pythagorean sine distribution.
    
    Tests the density conjecture by computing:
    - Maximum gap between consecutive sine values
    - Distribution of gap sizes
    - Whether max gap decreases as hypotenuse bound increases
    
    Algorithm:
        1. Generate all primitive triples up to bound
        2. Extract and sort sine values
        3. Compute gaps between consecutive values
        4. Return statistical summary
    
    Time complexity: O(N log N) where N = number of triples
    Space complexity: O(N)
    """
    triples = enumerate_primitive_triples_bfs(max_hypotenuse)
    sines = sorted(set(a / c for a, b, c in triples))
    
    if len(sines) < 2:
        return {"error": "Too few triples"}
    
    gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
    
    return {
        "num_triples": len(triples),
        "num_distinct_sines": len(sines),
        "max_gap": max(gaps),
        "min_gap": min(gaps),
        "mean_gap": sum(gaps) / len(gaps),
        "median_gap": sorted(gaps)[len(gaps) // 2],
        "min_sine": sines[0],
        "max_sine": sines[-1],
        "gaps_above_01": sum(1 for g in gaps if g > 0.1),
        "gaps_above_001": sum(1 for g in gaps if g > 0.01),
    }


def convergence_test(bounds: List[int] = None) -> List[dict]:
    """
    Test whether the maximum gap decreases as we include more triples.
    
    If the density conjecture is true, max_gap → 0 as bound → ∞.
    
    Time complexity: O(Σ N_i log N_i) for each bound
    """
    if bounds is None:
        bounds = [100, 500, 1000, 2000, 5000, 10000]
    
    results = []
    for bound in bounds:
        analysis = gap_analysis(bound)
        results.append({
            "max_hypotenuse": bound,
            "num_triples": analysis["num_triples"],
            "max_gap": analysis["max_gap"],
            "mean_gap": analysis["mean_gap"],
        })
    
    return results


if __name__ == "__main__":
    print("Berggren Tree Enumeration")
    print("=" * 50)
    triples = enumerate_primitive_triples_bfs(100)
    print(f"Primitive triples with c ≤ 100: {len(triples)}")
    for t in triples[:10]:
        print(f"  {t}  →  sin = {t[0]/t[2]:.6f}")
    
    print("\nPythagorean Sine Approximation")
    print("=" * 50)
    for target in [0.1, 1/math.sqrt(2), 0.9, math.pi/4 - 0.5]:
        result = pythagorean_sine_approximation(target, max_hypotenuse=10000)
        if result:
            a, b, c, sine = result
            print(f"  Target {target:.6f}: ({a}, {b}, {c}), sine = {sine:.6f}, "
                  f"error = {abs(sine - target):.8f}")
    
    print("\nConvergence Test (Density Conjecture)")
    print("=" * 50)
    results = convergence_test()
    for r in results:
        print(f"  c ≤ {r['max_hypotenuse']:6d}: "
              f"{r['num_triples']:5d} triples, "
              f"max_gap = {r['max_gap']:.6f}, "
              f"mean_gap = {r['mean_gap']:.8f}")
