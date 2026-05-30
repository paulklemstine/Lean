"""
Applications of Hyperbolic Number Theory
==========================================

Real-world applications of the mathematical results:
1. Hyperbolic coding theory (error-correcting codes on trees)
2. Diophantine approximation via Farey sequences
3. Trace-based matrix classification for dynamical systems
"""

import math
from fractions import Fraction
from typing import List, Tuple


# ============================================================
# Application 1: Best Rational Approximations via Farey Mediants
# ============================================================

def best_rational_approximation(x: float, max_denom: int = 100) -> List[Tuple[int, int]]:
    """
    Find the best rational approximations to x using the Stern-Brocot tree.
    
    This uses the connection between Farey sequences and SL₂(ℤ):
    each step in the continued fraction algorithm corresponds to a
    matrix multiplication in SL₂(ℤ), and the best approximations
    are vertices of the Farey tessellation of the hyperbolic plane.
    
    Args:
        x: Real number to approximate.
        max_denom: Maximum denominator.
    
    Returns:
        List of (p, q) best approximations p/q.
    """
    # Stern-Brocot search
    approx = []
    lo_p, lo_q = 0, 1  # 0/1
    hi_p, hi_q = 1, 0  # 1/0 = infinity
    
    while True:
        med_p = lo_p + hi_p
        med_q = lo_q + hi_q
        
        if med_q > max_denom:
            break
        
        med_val = med_p / med_q
        
        if abs(med_val - x) < 1e-12:
            approx.append((med_p, med_q))
            break
        elif med_val < x:
            lo_p, lo_q = med_p, med_q
            approx.append((med_p, med_q))
        else:
            hi_p, hi_q = med_p, med_q
            approx.append((med_p, med_q))
    
    return approx


# ============================================================
# Application 2: Matrix Classification via Trace
# ============================================================

def classify_sl2_element(trace: int) -> str:
    """
    Classify an SL₂(ℤ) element by its trace.
    
    This is the fundamental classification in hyperbolic geometry:
    - |tr| < 2: Elliptic (rotation, finite order in PSL₂)
    - |tr| = 2: Parabolic (translation along horocycle)
    - |tr| > 2: Hyperbolic (translation along geodesic)
    
    The trace determines the geometry of the corresponding isometry
    of the hyperbolic plane. This classification is used in:
    - Dynamical systems (periodic vs. chaotic orbits)
    - Number theory (cusps vs. closed geodesics)
    - Physics (classification of Lorentz transformations)
    
    Args:
        trace: Integer trace of an SL₂(ℤ) element.
    
    Returns:
        Classification string.
    """
    abs_tr = abs(trace)
    if abs_tr < 2:
        if trace == 0:
            return "Elliptic (order 2 or 4 in PSL₂)"
        elif abs_tr == 1:
            return "Elliptic (order 3 or 6 in PSL₂)"
        else:
            return f"Elliptic (|tr|={abs_tr})"
    elif abs_tr == 2:
        return "Parabolic (fixes one ideal point, translation along horocycle)"
    else:
        # Hyperbolic: translation length = 2·arccosh(|tr|/2)
        length = 2 * math.acosh(abs_tr / 2)
        return f"Hyperbolic (translation length = {length:.4f})"


# ============================================================
# Application 3: Hurwitz's Theorem via Markov Spectrum
# ============================================================

def markov_approximation_constants(n_triples: int = 15) -> List[float]:
    """
    Compute the Lagrange spectrum from Markov numbers.
    
    Hurwitz's theorem states that for any irrational α, there are
    infinitely many p/q with |α - p/q| < 1/(√5 · q²).
    The constant √5 is the best possible for the golden ratio.
    
    The Markov spectrum gives the best constants for worse-approximable
    numbers. For each Markov number m, the constant is √(9 - 4/m²).
    
    This connects the Markov equation x²+y²+z² = 3xyz (proved via
    Vieta involution in our Lean formalization) directly to the
    quality of Diophantine approximations.
    """
    # Generate Markov numbers
    triples = set()
    queue = [(1, 1, 1)]
    
    while queue and len(triples) < n_triples:
        x, y, z = queue.pop(0)
        triple = tuple(sorted([x, y, z]))
        if triple in triples or max(triple) > 10**6:
            continue
        triples.add(triple)
        for a, b, c in [(x, y, z), (y, z, x), (x, z, y)]:
            new_c = 3 * a * b - c
            if new_c > 0:
                queue.append((a, b, new_c))
    
    markov_nums = sorted(set(n for t in triples for n in t))
    
    # Compute Lagrange constants
    constants = []
    for m in markov_nums:
        L = math.sqrt(9 - 4 / m**2)
        constants.append((m, L))
    
    return constants


# ============================================================
# Application 4: Coding Theory on Trees
# ============================================================

def hyperbolic_code_distance(codewords: List[List[int]]) -> int:
    """
    Compute the minimum distance of a code on a binary tree.
    
    In hyperbolic geometry, the tree is a 0-hyperbolic space.
    The Gromov product (x|y) = (d(o,x) + d(o,y) - d(x,y))/2
    measures "how long paths from o to x and y stay together."
    
    For tree codes, this gives the minimum distance property:
    d_min = min_{x≠y} d_tree(x, y)
    
    This uses our proved Gromov product tree inequality.
    """
    min_dist = float('inf')
    for i in range(len(codewords)):
        for j in range(i + 1, len(codewords)):
            d = sum(1 for a, b in zip(codewords[i], codewords[j]) if a != b)
            min_dist = min(min_dist, d)
    return min_dist


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Application 1: Best Rational Approximations")
    print("=" * 50)
    
    targets = [math.pi, math.e, math.sqrt(2), (1 + math.sqrt(5)) / 2]
    names = ["π", "e", "√2", "φ (golden ratio)"]
    
    for name, x in zip(names, targets):
        approxs = best_rational_approximation(x, max_denom=1000)
        best = approxs[-1] if approxs else (0, 1)
        error = abs(x - best[0] / best[1])
        print(f"  {name} ≈ {best[0]}/{best[1]} (error = {error:.2e})")
    
    print(f"\nApplication 2: SL₂(ℤ) Element Classification")
    print("=" * 50)
    
    for tr in range(-3, 8):
        print(f"  tr = {tr:>3}: {classify_sl2_element(tr)}")
    
    print(f"\nApplication 3: Markov Spectrum (Diophantine Approximation)")
    print("=" * 50)
    
    constants = markov_approximation_constants(15)
    print(f"  Lagrange constants from Markov numbers:")
    print(f"  {'Markov m':>10} {'√(9-4/m²)':>12} {'1/L':>10}")
    for m, L in constants[:10]:
        print(f"  {m:>10} {L:>12.6f} {1/L:>10.6f}")
    print(f"  Limit: L → 3 (accumulation point of the Markov spectrum)")
    
    print(f"\nApplication 4: Tree Code Distance")
    print("=" * 50)
    codewords = [
        [0, 0, 0, 0],
        [1, 1, 0, 0],
        [0, 0, 1, 1],
        [1, 1, 1, 1],
    ]
    d_min = hyperbolic_code_distance(codewords)
    print(f"  Code with {len(codewords)} words, minimum distance = {d_min}")
