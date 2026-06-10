#!/usr/bin/env python3
"""
Algorithms for Tropical Pythagorean M-Convexity

Implements core algorithms for computing and analyzing the p-adic valuation
images of Pythagorean triples.

Algorithms:
1. Euclid parametrization enumeration — O(B) time for bound B
2. p-adic valuation computation — O(log n) per number
3. Tropical image construction — O(T · log B) for T triples
4. Weak exchange verification — O(|S|² · dim) for set S ⊂ ℕ³
5. Semilinear decomposition — heuristic structural analysis
"""

from math import gcd, isqrt, log
from collections import defaultdict
from typing import Optional
from itertools import combinations


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n).
    
    The p-adic valuation is the exponent of the largest power of p dividing n.
    
    Time complexity: O(log_p(n))
    Space complexity: O(1)
    
    Args:
        p: Prime number (must be ≥ 2)
        n: Non-negative integer
        
    Returns:
        The largest k ≥ 0 such that p^k divides n, or infinity (as -1) if n=0.
        
    Examples:
        >>> padic_val(3, 54)  # 54 = 2 · 3³
        3
        >>> padic_val(5, 100)  # 100 = 4 · 5²
        2
        >>> padic_val(7, 11)  # 7 does not divide 11
        0
    """
    if n == 0:
        return -1  # Represents infinity
    if p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def enumerate_primitive_triples(bound: int) -> list[tuple[int, int, int]]:
    """Enumerate all primitive Pythagorean triples (a, b, c) with c ≤ bound.
    
    Uses Euclid's parametrization: for coprime m > n > 0 with m ≢ n (mod 2),
    the triple (m²-n², 2mn, m²+n²) is primitive Pythagorean, and all primitive
    triples arise this way (up to swapping a, b).
    
    Time complexity: O(B) where B = bound (number of (m,n) pairs is O(B))
    Space complexity: O(T) where T is the number of triples found
    
    Args:
        bound: Upper bound on the hypotenuse c
        
    Returns:
        Sorted list of primitive triples (a, b, c) with a < b.
        
    Examples:
        >>> enumerate_primitive_triples(15)
        [(3, 4, 5), (5, 12, 13)]
    """
    triples = set()
    m = 2
    while m * m + 1 <= bound:
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if gcd(m, n) != 1:
                continue
            a = m * m - n * n
            b = 2 * m * n
            c = m * m + n * n
            if c > bound:
                break
            triples.add((min(a, b), max(a, b), c))
        m += 1
    return sorted(triples)


def compute_valuation_image(
    p: int, 
    triples: list[tuple[int, int, int]]
) -> dict[tuple[int, int, int], list[tuple[int, int, int]]]:
    """Compute the tropical Pythagorean image Trop_p(P).
    
    Maps each primitive triple to its p-adic valuation vector and groups
    triples by their valuation vector.
    
    Time complexity: O(T · log B) where T = |triples|, B = max hypotenuse
    Space complexity: O(T)
    
    Args:
        p: Prime number
        triples: List of primitive Pythagorean triples
        
    Returns:
        Dictionary mapping valuation vectors to their witness triples.
    """
    image = defaultdict(list)
    for a, b, c in triples:
        v = (padic_val(p, a), padic_val(p, b), padic_val(p, c))
        image[v].append((a, b, c))
    return dict(image)


def verify_tropical_min_law(
    p: int, 
    triples: list[tuple[int, int, int]]
) -> dict:
    """Verify the tropical min-plus law for a set of Pythagorean triples.
    
    Checks both:
    1. Inequality: min(2·v_p(a), 2·v_p(b)) ≤ 2·v_p(c) (always)
    2. Equality: min(2·v_p(a), 2·v_p(b)) = 2·v_p(c) (when v_p(a) ≠ v_p(b))
    
    Time complexity: O(T · log B)
    
    Returns:
        Dictionary with verification results and statistics.
    """
    results = {
        'inequality_holds': True,
        'equality_holds': True,
        'total_triples': len(triples),
        'unequal_valuation_cases': 0,
        'equality_failures': [],
        'inequality_failures': [],
    }
    
    for a, b, c in triples:
        va, vb, vc = padic_val(p, a), padic_val(p, b), padic_val(p, c)
        lhs = min(2 * va, 2 * vb)
        rhs = 2 * vc
        
        if lhs > rhs:
            results['inequality_holds'] = False
            results['inequality_failures'].append((a, b, c, va, vb, vc))
        
        if va != vb:
            results['unequal_valuation_cases'] += 1
            if lhs != rhs:
                results['equality_holds'] = False
                results['equality_failures'].append((a, b, c, va, vb, vc))
    
    return results


def verify_weak_exchange(
    valuation_set: set[tuple[int, int, int]],
    dim: int = 3
) -> dict:
    """Verify the weak tropical exchange property for a valuation image.
    
    For each pair (v, w) ∈ S × S and coordinate i with v_i > w_i,
    checks whether there exists j with v_j < w_j and u ∈ S with
    u_i < v_i and u_j ≥ v_j.
    
    Time complexity: O(|S|³ · dim)
    Space complexity: O(|S|)
    
    Args:
        valuation_set: Set of valuation vectors
        dim: Dimension of vectors (default 3)
        
    Returns:
        Dictionary with verification results and any violations.
    """
    vals = list(valuation_set)
    violations = []
    checks = 0
    
    for v in vals:
        for w in vals:
            for i in range(dim):
                if v[i] > w[i]:
                    candidates_j = [j for j in range(dim) if v[j] < w[j]]
                    if not candidates_j:
                        continue
                    checks += 1
                    found = False
                    for j in candidates_j:
                        for u in vals:
                            if u[i] < v[i] and u[j] >= v[j]:
                                found = True
                                break
                        if found:
                            break
                    if not found:
                        violations.append({
                            'v': v, 'w': w, 'i': i,
                            'candidate_j': candidates_j
                        })
    
    return {
        'satisfies_exchange': len(violations) == 0,
        'total_checks': checks,
        'violations': violations,
        'set_size': len(vals),
    }


def analyze_semilinear_structure(
    image: dict[tuple, list]
) -> dict:
    """Heuristic analysis of semilinear structure in the valuation image.
    
    Attempts to identify whether the valuation image can be described as
    a union of translated cones in ℕ³. This is a computational test for
    Conjecture B (exact semilinear description).
    
    Args:
        image: Valuation image dictionary (from compute_valuation_image)
        
    Returns:
        Analysis results including detected patterns and cone candidates.
    """
    vectors = sorted(image.keys())
    
    # Check which coordinates are always zero
    always_zero = [True, True, True]
    for v in vectors:
        for i in range(3):
            if v[i] != 0:
                always_zero[i] = False
    
    # Detect ray structure: check if image lies on coordinate rays
    on_axis = defaultdict(list)
    for v in vectors:
        nonzero_coords = [i for i in range(3) if v[i] > 0]
        if len(nonzero_coords) <= 1:
            key = nonzero_coords[0] if nonzero_coords else -1
            on_axis[key].append(v)
    
    # Check for contiguity along rays
    ray_analysis = {}
    for axis, pts in on_axis.items():
        if axis == -1:
            continue
        values = sorted(p[axis] for p in pts)
        is_contiguous = all(values[i+1] - values[i] == 1 for i in range(len(values)-1))
        ray_analysis[axis] = {
            'values': values,
            'contiguous': is_contiguous,
            'min': min(values) if values else None,
            'max': max(values) if values else None,
        }
    
    return {
        'total_vectors': len(vectors),
        'always_zero_coords': [i for i, z in enumerate(always_zero) if z],
        'on_axis_count': sum(len(v) for v in on_axis.values()),
        'ray_analysis': ray_analysis,
        'fraction_on_axis': sum(len(v) for v in on_axis.values()) / max(len(vectors), 1),
    }


def euclid_parameter_valuations(
    p: int, 
    bound: int
) -> list[dict]:
    """Compute valuations through Euclid's parametrization.
    
    For each coprime pair (m, n) with m > n, m ≢ n (mod 2),
    computes the triple (m²-n², 2mn, m²+n²) and its valuation
    in terms of the parameter valuations.
    
    This implements the parametric valuation formula:
    - v_p(b) = v_p(2) + v_p(m) + v_p(n) for b = 2mn
    - v_p(a) relates to v_p(m-n) + v_p(m+n) for a = m²-n² = (m-n)(m+n)
    
    Args:
        p: Odd prime
        bound: Upper bound on hypotenuse
        
    Returns:
        List of dictionaries with parameter and valuation data.
    """
    results = []
    m = 2
    while m * m + 1 <= bound:
        for n in range(1, m):
            if (m - n) % 2 == 0 or gcd(m, n) != 1:
                continue
            a = m * m - n * n
            b = 2 * m * n
            c = m * m + n * n
            if c > bound:
                break
            
            vm, vn = padic_val(p, m), padic_val(p, n)
            v_mn = padic_val(p, m - n)
            v_mp = padic_val(p, m + n)
            
            results.append({
                'm': m, 'n': n,
                'a': min(a, b), 'b': max(a, b), 'c': c,
                'v_m': vm, 'v_n': vn,
                'v_m_minus_n': v_mn, 'v_m_plus_n': v_mp,
                'v_a': padic_val(p, a), 'v_b': padic_val(p, b), 'v_c': padic_val(p, c),
                'formula_b': vm + vn,  # v_p(b/2) = v_p(m) + v_p(n) for odd p
                'formula_a': v_mn + v_mp,  # v_p(a) = v_p(m-n) + v_p(m+n)
            })
        m += 1
    return results


if __name__ == "__main__":
    # Example usage
    print("=== Algorithm Demonstrations ===\n")
    
    bound = 200
    triples = enumerate_primitive_triples(bound)
    print(f"Found {len(triples)} primitive triples with c ≤ {bound}\n")
    
    for p in [3, 5, 7]:
        print(f"--- Prime p = {p} ---")
        
        # Valuation image
        image = compute_valuation_image(p, triples)
        print(f"  |Trop_{p}(P)| = {len(image)}")
        
        # Tropical min-law
        results = verify_tropical_min_law(p, triples)
        print(f"  Inequality: {'✓' if results['inequality_holds'] else '✗'}")
        print(f"  Equality (unequal vals): {'✓' if results['equality_holds'] else '✗'} "
              f"({results['unequal_valuation_cases']} cases)")
        
        # Weak exchange
        val_set = set(image.keys())
        exchange = verify_weak_exchange(val_set)
        print(f"  Weak exchange: {'✓' if exchange['satisfies_exchange'] else '✗'} "
              f"({exchange['total_checks']} checks)")
        
        # Semilinear structure
        structure = analyze_semilinear_structure(image)
        print(f"  On-axis fraction: {structure['fraction_on_axis']:.1%}")
        print()
    
    # Parametric analysis
    print("--- Euclid Parameter Valuations (p=3, c≤100) ---")
    params = euclid_parameter_valuations(3, 100)
    for r in params[:5]:
        print(f"  (m,n)=({r['m']},{r['n']}): triple=({r['a']},{r['b']},{r['c']}), "
              f"v₃(a)={r['v_a']}, v₃(b)={r['v_b']}, v₃(c)={r['v_c']}, "
              f"formula_a={r['formula_a']}, formula_b={r['formula_b']}")
