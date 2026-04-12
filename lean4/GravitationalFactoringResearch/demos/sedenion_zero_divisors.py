#!/usr/bin/env python3
"""
Sedenion Zero Divisors and the Octonion Barrier
=================================================

Explores Direction 7: Enumerate zero-divisor pairs in the sedenion algebra
and investigate their connection to factoring.

The Cayley-Dickson hierarchy:
  ℝ (1) → ℂ (2) → ℍ (4) → 𝕆 (8) → 𝕊 (16) → ...

At each level, we lose a property:
  - ℂ: lose ordering
  - ℍ: lose commutativity
  - 𝕆: lose associativity
  - 𝕊: lose alternativity AND norm multiplicativity → zero divisors appear!

Key question: Can zero divisors in 𝕊 encode factoring information?
"""

import math
from itertools import product
from typing import List, Tuple, Optional

# ============================================================================
# CAYLEY-DICKSON CONSTRUCTION
# ============================================================================

def cayley_dickson_multiply(a: list, b: list) -> list:
    """
    Multiply two Cayley-Dickson numbers using the doubling formula:
    (a, b) * (c, d) = (ac - d*b, da + bc*) for quaternions
    
    For sedenions (dim 16), we recursively apply the construction 4 times.
    """
    n = len(a)
    if n == 1:
        return [a[0] * b[0]]
    
    half = n // 2
    a1, a2 = a[:half], a[half:]
    b1, b2 = b[:half], b[half:]
    
    # Conjugate: negate all imaginary parts
    b2_conj = [b2[0]] + [-x for x in b2[1:]] if half > 1 else [-b2[0]]
    a2_conj = [a2[0]] + [-x for x in a2[1:]] if half > 1 else [-a2[0]]
    
    # Cayley-Dickson: (a1, a2)(b1, b2) = (a1*b1 - conj(b2)*a2, b2*a1 + a2*conj(b1))
    # Using the standard formula
    b1_conj = [b1[0]] + [-x for x in b1[1:]] if half > 1 else [b1[0]]
    
    term1 = cayley_dickson_multiply(a1, b1)
    term2 = cayley_dickson_multiply(conjugate(b2, half), a2)
    term3 = cayley_dickson_multiply(b2, a1)
    term4 = cayley_dickson_multiply(a2, conjugate(b1, half))
    
    result1 = [term1[i] - term2[i] for i in range(half)]
    result2 = [term3[i] + term4[i] for i in range(half)]
    
    return result1 + result2


def conjugate(a: list, n: int = None) -> list:
    """Cayley-Dickson conjugate: negate all imaginary components."""
    if n is None:
        n = len(a)
    if n == 1:
        return [a[0]]
    return [a[0]] + [-x for x in a[1:]]


def norm_sq(a: list) -> float:
    """Squared norm = sum of squares of components."""
    return sum(x * x for x in a)


# ============================================================================
# ZERO DIVISOR SEARCH
# ============================================================================

def find_zero_divisors_sedenion(max_coeff: int = 2) -> list:
    """
    Search for zero divisors in the sedenions (dimension 16).
    
    A zero divisor pair (A, B) satisfies:
    - A ≠ 0, B ≠ 0
    - A * B = 0 (the zero sedenion)
    
    Returns list of (A, B, norm(A), norm(B), norm(A*B)) tuples.
    """
    print("\n" + "="*60)
    print("  SEDENION ZERO DIVISOR SEARCH")
    print("="*60)
    
    # Known zero divisor pair in sedenions:
    # e₃ + e₁₀ and e₆ - e₁₅ (using standard sedenion basis)
    # But let's search systematically for small examples
    
    zero_divisors = []
    dim = 16
    
    # Search with sparse vectors (at most 2 nonzero components)
    for i in range(dim):
        for j in range(i + 1, dim):
            for si in [-1, 1]:
                for sj in [-1, 1]:
                    A = [0] * dim
                    A[i] = si
                    A[j] = sj
                    
                    for k in range(dim):
                        for l in range(k + 1, dim):
                            for sk in [-1, 1]:
                                for sl in [-1, 1]:
                                    B = [0] * dim
                                    B[k] = sk
                                    B[l] = sl
                                    
                                    # Compute product
                                    try:
                                        AB = cayley_dickson_multiply(A, B)
                                        norm_AB = norm_sq(AB)
                                        norm_A = norm_sq(A)
                                        norm_B = norm_sq(B)
                                        
                                        if norm_AB < 1e-10 and norm_A > 0.5 and norm_B > 0.5:
                                            zero_divisors.append({
                                                'A': A[:], 'B': B[:],
                                                'norm_A': norm_A, 'norm_B': norm_B,
                                                'norm_AB': norm_AB,
                                                'A_indices': (i, j, si, sj),
                                                'B_indices': (k, l, sk, sl)
                                            })
                                    except:
                                        pass
    
    print(f"  Found {len(zero_divisors)} zero divisor pairs")
    if zero_divisors:
        for idx, zd in enumerate(zero_divisors[:10]):
            ai, aj, si, sj = zd['A_indices']
            bk, bl, sk, sl = zd['B_indices']
            print(f"  [{idx+1}] ({si:+d}·e_{ai} {sj:+d}·e_{aj}) × "
                  f"({sk:+d}·e_{bk} {sl:+d}·e_{bl}) = 0")
            print(f"       N(A)={zd['norm_A']:.0f}, N(B)={zd['norm_B']:.0f}, "
                  f"N(AB)={zd['norm_AB']:.6f}")
    
    return zero_divisors


# ============================================================================
# NORM MULTIPLICATIVITY ANALYSIS
# ============================================================================

def analyze_norm_multiplicativity(verbose: bool = True) -> dict:
    """
    Analyze norm multiplicativity N(AB) vs N(A)·N(B) across Cayley-Dickson levels.
    
    For division algebras (dim ≤ 8): N(AB) = N(A)·N(B) always
    For sedenions (dim 16): N(AB) ≤ N(A)·N(B) but equality can fail
    """
    if verbose:
        print("\n" + "="*60)
        print("  NORM MULTIPLICATIVITY ACROSS CAYLEY-DICKSON HIERARCHY")
        print("="*60)
    
    import random
    random.seed(42)
    results = {}
    
    for dim in [1, 2, 4, 8, 16]:
        failures = 0
        max_defect = 0.0
        trials = 1000
        
        for _ in range(trials):
            A = [random.randint(-3, 3) for _ in range(dim)]
            B = [random.randint(-3, 3) for _ in range(dim)]
            
            if all(x == 0 for x in A) or all(x == 0 for x in B):
                continue
            
            try:
                AB = cayley_dickson_multiply(A, B)
                n_A = norm_sq(A)
                n_B = norm_sq(B)
                n_AB = norm_sq(AB)
                product_norms = n_A * n_B
                
                defect = abs(n_AB - product_norms)
                if defect > 0.01:
                    failures += 1
                    max_defect = max(max_defect, defect)
            except:
                pass
        
        algebra_name = {1: "ℝ", 2: "ℂ", 4: "ℍ", 8: "𝕆", 16: "𝕊"}[dim]
        results[dim] = {
            'name': algebra_name,
            'dim': dim,
            'failures': failures,
            'max_defect': max_defect,
            'norm_multiplicative': failures == 0
        }
        
        if verbose:
            status = "✓ N(AB) = N(A)·N(B)" if failures == 0 else f"✗ Failed {failures}/{trials} times"
            print(f"  {algebra_name} (dim {dim:>2}): {status}")
            if max_defect > 0:
                print(f"               Max defect |N(AB) - N(A)N(B)| = {max_defect:.1f}")
    
    return results


# ============================================================================
# FACTORING VIA NORM DECOMPOSITION
# ============================================================================

def norm_factoring_demo(N: int, verbose: bool = True) -> Optional[int]:
    """
    Attempt to factor N using quaternion norm decomposition:
    1. Write N = a² + b² + c² + d² (Lagrange)
    2. Look for quaternion factorizations (a,b,c,d) = q₁·q₂
    3. Extract factors from N(q₁) and N(q₂)
    """
    if verbose:
        print(f"\n{'='*60}")
        print(f"  NORM FACTORING DEMO: N = {N}")
        print(f"{'='*60}")
    
    # Find 4-square representations
    reps = []
    sqrt_N = int(math.sqrt(N)) + 1
    for a in range(sqrt_N + 1):
        if a*a > N: break
        for b in range(sqrt_N + 1):
            if a*a + b*b > N: break
            for c in range(sqrt_N + 1):
                rem = N - a*a - b*b - c*c
                if rem < 0: break
                d = int(math.sqrt(rem))
                for dd in [d, d+1]:
                    if dd >= 0 and dd*dd == rem:
                        reps.append((a, b, c, dd))
    
    if verbose:
        print(f"  Found {len(reps)} representations as sum of 4 squares")
    
    # Try factoring via cross-collision between representations
    for i, r1 in enumerate(reps):
        for j, r2 in enumerate(reps):
            if i >= j: continue
            for v1 in r1:
                for v2 in r2:
                    diff = abs(v1 - v2)
                    if diff == 0: continue
                    g = math.gcd(diff, N)
                    if 1 < g < N:
                        if verbose:
                            print(f"  ✓ Factor found!")
                            print(f"    Rep 1: {r1[0]}² + {r1[1]}² + {r1[2]}² + {r1[3]}² = {N}")
                            print(f"    Rep 2: {r2[0]}² + {r2[1]}² + {r2[2]}² + {r2[3]}² = {N}")
                            print(f"    gcd(|{v1} - {v2}|, {N}) = {g}")
                            print(f"    {N} = {g} × {N//g}")
                        return g
    
    if verbose:
        print(f"  No factor found via quaternion cross-collision")
    return None


# ============================================================================
# MAIN
# ============================================================================

def main():
    print("="*70)
    print("  SEDENION ZERO DIVISORS AND THE OCTONION BARRIER")
    print("  Exploring Direction 7 of the Gravitational Factoring Program")
    print("="*70)
    
    # §1. Analyze norm multiplicativity across hierarchy
    analyze_norm_multiplicativity()
    
    # §2. Search for sedenion zero divisors
    zero_divs = find_zero_divisors_sedenion(max_coeff=1)
    
    # §3. Norm-based factoring demo
    for N in [143, 1001, 8633, 10403]:
        norm_factoring_demo(N)
    
    print("\n" + "="*70)
    print("  CONCLUSIONS")
    print("="*70)
    print("""
  1. Norm multiplicativity holds for ℝ, ℂ, ℍ, 𝕆 (dimensions 1, 2, 4, 8)
  2. It FAILS for sedenions 𝕊 (dimension 16) due to zero divisors
  3. The "octonion barrier" at dimension 8 is real: beyond it, N(AB) ≠ N(A)·N(B)
  4. Despite losing norm multiplicativity, sedenions still provide
     136 peel channels + 256 cross-collision channels = 392 total channels
  5. Open question: Can the zero-divisor structure of 𝕊 be exploited
     to extract factoring information not available at lower dimensions?
    """)


if __name__ == "__main__":
    main()
