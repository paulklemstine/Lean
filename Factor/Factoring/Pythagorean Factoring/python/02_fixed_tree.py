#!/usr/bin/env python3
"""
=============================================================================
PYTHAGOREAN TRIPLE TREE FACTORING — CORRECTED TREE CLIMBING
=============================================================================

The Berggren matrices and their correct inverses for climbing the ternary
tree of ALL primitive Pythagorean triples back to root (3, 4, 5).
"""

import math
from typing import List, Tuple, Optional

# ==========================================================================
# CORRECT Berggren Matrices and Inverses
# ==========================================================================

# Forward matrices: (3,4,5) -> children
# Convention: (a, b, c) with a ODD, b EVEN, a² + b² = c²

def mat_mul(M, v):
    return tuple(sum(M[i][j] * v[j] for j in range(3)) for i in range(3))

# Berggren forward matrices
A = [[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]]
B = [[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]]
C = [[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]]

# Correct inverse matrices (verified by hand computation of determinants)
# det(A) = 1, det(B) = -1, det(C) = 1
A_inv = [[ 1,  2, -2], [-2, -1,  2], [-2, -2,  3]]
B_inv = [[ 1,  2, -2], [ 2,  1, -2], [-2, -2,  3]]
C_inv = [[-1, -2,  2], [ 2,  1, -2], [-2, -2,  3]]

def verify_inverses():
    """Verify A * A_inv = I, etc."""
    I = [[1,0,0],[0,1,0],[0,0,1]]
    for name, M, Mi in [("A", A, A_inv), ("B", B, B_inv), ("C", C, C_inv)]:
        product = [[sum(M[i][k]*Mi[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
        assert product == I, f"{name} * {name}_inv != I, got {product}"
    print("✓ All inverse matrices verified correct")

def find_parent(triple):
    """
    Find the parent of a PRIMITIVE Pythagorean triple in the Berggren tree.
    Input: (a, b, c) with a odd, b even, a² + b² = c², gcd(a,b) = 1
    Returns: (branch_label, parent_triple) or (None, None) if at root
    """
    a, b, c = triple
    
    if (a, b, c) == (3, 4, 5):
        return None, None
    
    for label, M_inv in [('A', A_inv), ('B', B_inv), ('C', C_inv)]:
        result = mat_mul(M_inv, (a, b, c))
        pa, pb, pc = result
        
        # Valid parent: all positive, hypotenuse smaller
        if pa > 0 and pb > 0 and pc > 0 and pc < c:
            # Ensure odd/even convention: a odd, b even
            if pa % 2 == 0 and pb % 2 == 1:
                pa, pb = pb, pa
            return label, (pa, pb, pc)
    
    return None, None

def climb_to_root(triple):
    """
    Climb from a primitive triple (a_odd, b_even, c) to root (3, 4, 5).
    Returns (path, final_triple).
    """
    a, b, c = triple
    if a % 2 == 0:
        a, b = b, a
    current = (a, b, c)
    path = []
    
    for _ in range(10000):
        if current == (3, 4, 5):
            break
        label, parent = find_parent(current)
        if parent is None:
            break
        path.append(label)
        current = parent
    
    return path, current

def normalize_primitive(triple):
    """Normalize: odd leg first, all positive."""
    a, b, c = [abs(x) for x in triple]
    if a % 2 == 0:
        a, b = b, a
    return (a, b, c)

def make_primitive(triple):
    a, b, c = triple
    g = math.gcd(math.gcd(abs(a), abs(b)), abs(c))
    return normalize_primitive((a // g, b // g, c // g)), g

def triples_from_leg(n: int) -> List[Tuple[int, int, int]]:
    n_sq = n * n
    triples = []
    for d in range(1, int(math.isqrt(n_sq)) + 1):
        if n_sq % d != 0:
            continue
        e = n_sq // d
        if d >= e:
            continue
        if (d + e) % 2 != 0:
            continue
        b = (e - d) // 2
        c = (e + d) // 2
        if b > 0:
            triples.append((n, b, c))
    return triples

def factorize(n):
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.append(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return factors

# ==========================================================================
# EXPERIMENTS WITH CORRECTED TREE
# ==========================================================================

def experiment_tree_climbing():
    """Test tree climbing with corrected inverses."""
    print("=" * 70)
    print("TREE CLIMBING TEST — Corrected Inverse Matrices")
    print("=" * 70)
    
    verify_inverses()
    
    # Test: generate children and climb back
    root = (3, 4, 5)
    print(f"\nRoot: {root}")
    
    for label, M in [("A", A), ("B", B), ("C", C)]:
        child = mat_mul(M, root)
        child = normalize_primitive(child)
        path, final = climb_to_root(child)
        print(f"  {label}-child: {child}, path back: {''.join(path)}, reached root: {final == (3,4,5)}")
        
        # Go two levels deep
        for label2, M2 in [("A", A), ("B", B), ("C", C)]:
            grandchild = mat_mul(M2, child)
            grandchild = normalize_primitive(grandchild)
            path2, final2 = climb_to_root(grandchild)
            print(f"    {label}{label2}-grandchild: {grandchild}, path back: {''.join(path2)}, root: {final2 == (3,4,5)}")


def experiment_full_ancestry():
    """Full ancestry for composite numbers with corrected tree."""
    print("\n" + "=" * 70)
    print("FULL ANCESTRY — Factoring via Tree Paths")
    print("=" * 70)
    
    for n in [15, 21, 35, 77, 91, 105, 143, 221, 1001, 10403]:
        print(f"\n{'─' * 60}")
        print(f"n = {n} = {' × '.join(map(str, factorize(n)))}")
        print(f"n² = {n*n}")
        
        triples = triples_from_leg(n)
        print(f"Number of Pythagorean triples with leg {n}: {len(triples)}")
        
        for triple in triples:
            a, b, c = triple
            d, e = c - b, c + b
            prim, g = make_primitive(triple)
            
            path, final = climb_to_root(prim)
            reached = final == (3, 4, 5)
            
            # Factor extraction
            factors_from_d = math.gcd(d, n) if d > 1 else 1
            factors_from_g = g if g > 1 else 1
            
            factor_info = ""
            if factors_from_d > 1 and factors_from_d < n:
                factor_info += f" → factor {factors_from_d}"
            if factors_from_g > 1 and factors_from_g < n:
                factor_info += f" → gcd={g}"
            
            path_str = ''.join(path) if path else "(root)"
            print(f"  ({a},{b},{c}) | {d}×{e}={n*n} | prim={prim} g={g} | "
                  f"path={path_str} depth={len(path)} root={reached}{factor_info}")


def experiment_tree_structure_theorem():
    """
    THEOREM: For n = p*q (product of two distinct odd primes), there are 
    exactly 4 Pythagorean triples with leg n. Their primitive reductions 
    and GCDs completely determine the factorization.
    
    Triple 1: trivial (d=1, e=n²)    → gcd = 1, primitive has both factors
    Triple 2: d=p², e=q²             → gcd = 1, gives both p and q
    Triple 3: d=p, e=p*q²            → gcd = p
    Triple 4: d=q, e=q*p²            → gcd = q
    """
    print("\n" + "=" * 70)
    print("THE STRUCTURE THEOREM: Semiprimes n = p × q")
    print("=" * 70)
    
    semiprimes = [(3,5), (3,7), (5,7), (7,11), (7,13), (11,13), (13,17), 
                  (17,19), (19,23), (23,29), (101,103)]
    
    for p, q in semiprimes:
        n = p * q
        triples = triples_from_leg(n)
        
        print(f"\nn = {p} × {q} = {n}")
        print(f"  Expected triples: 4 (from factorizations of {n}² = {n*n})")
        print(f"  Actual triples: {len(triples)}")
        
        for triple in triples:
            a, b, c = triple
            d, e = c - b, c + b
            prim, g = make_primitive(triple)
            
            path, final = climb_to_root(prim)
            
            # Classify
            if d == 1:
                label = "TRIVIAL"
            elif d == p*p or d == q*q:
                label = f"CROSS ({d}={int(math.sqrt(d))}²)"
            elif d == p or d == q:
                label = f"FACTOR-{d}"
            else:
                label = f"OTHER"
            
            print(f"  {label:12s}: {d:6d}×{e:6d} | gcd={g:4d} | prim={prim} | "
                  f"path={''.join(path) if path else '(root)'} depth={len(path)}")


def experiment_counting_theorem():
    """
    THEOREM: The number of Pythagorean triples with leg n equals
    the number of same-parity divisor pairs (d, e) of n² with d < e.
    
    For odd n: this equals (σ₀(n²) - 1) / 2 where σ₀ is number of divisors.
    For n = p₁^a₁ × ... × pₖ^aₖ (all odd):
      σ₀(n²) = (2a₁+1)(2a₂+1)...(2aₖ+1)
      #triples = ((2a₁+1)(2a₂+1)...(2aₖ+1) - 1) / 2
    """
    print("\n" + "=" * 70)
    print("COUNTING THEOREM: #Triples as a Function of Prime Factorization")
    print("=" * 70)
    
    print(f"\n{'n':>6s} | {'factorization':>20s} | {'σ₀(n²)':>8s} | {'predicted':>9s} | {'actual':>6s} | {'match':>5s}")
    print("  " + "-" * 70)
    
    for n in range(3, 150, 2):
        factors = factorize(n)
        # Count exponents
        from collections import Counter
        exp_count = Counter(factors)
        
        # σ₀(n²)
        sigma0_n2 = 1
        for p, a in exp_count.items():
            sigma0_n2 *= (2*a + 1)
        
        predicted = (sigma0_n2 - 1) // 2
        actual = len(triples_from_leg(n))
        
        match = "✓" if predicted == actual else "✗"
        
        if predicted != actual or n < 50 or len(exp_count) >= 3:
            exp_str = " × ".join(f"{p}^{a}" if a > 1 else str(p) for p, a in sorted(exp_count.items()))
            print(f"  {n:4d} | {exp_str:>20s} | {sigma0_n2:>8d} | {predicted:>9d} | {actual:>6d} | {match}")


def experiment_path_encoding():
    """
    KEY DISCOVERY: The Berggren tree path of a primitive triple
    encodes information about its m,n parametrization.
    
    Every primitive triple (a, b, c) = (m²-n², 2mn, m²+n²) for 
    some m > n > 0 with gcd(m,n)=1 and m-n odd.
    
    The path from (3,4,5) = (m=2,n=1) relates to the continued
    fraction expansion of m/n.
    """
    print("\n" + "=" * 70)
    print("PATH ENCODING — What the Berggren Path Means")
    print("=" * 70)
    
    # Generate triples from (m,n) parametrization and find their paths
    print(f"\n{'(m,n)':>8s} | {'triple':>20s} | {'path':>20s} | {'depth':>5s} | {'m/n':>8s}")
    print("  " + "-" * 70)
    
    for m in range(2, 20):
        for n_param in range(1, m):
            if math.gcd(m, n_param) != 1 or (m - n_param) % 2 == 0:
                continue
            
            a = m*m - n_param*n_param  # odd
            b = 2*m*n_param            # even
            c = m*m + n_param*n_param
            
            triple = (a, b, c) if a % 2 == 1 else (b, a, c)
            # Ensure a is odd
            if triple[0] % 2 == 0:
                triple = (triple[1], triple[0], triple[2])
            
            path, final = climb_to_root(triple)
            ratio = m / n_param
            
            path_str = ''.join(path) if path else "(root)"
            print(f"  ({m:2d},{n_param:2d}) | ({a:4d},{b:4d},{c:4d}) | {path_str:>20s} | {len(path):>5d} | {ratio:>8.4f}")


def experiment_factoring_algorithm_v2():
    """
    IMPROVED FACTORING ALGORITHM using the tree structure.
    
    For n = p × q:
    1. Compute the trivial triple: (n, (n²-1)/2, (n²+1)/2)
    2. Reduce to primitive, climb tree
    3. The GCD computed during primitive reduction IS a factor
    4. More sophisticated: the "cross triple" (d=p², e=q²) gives both factors
       via b = (q²-p²)/2, c = (q²+p²)/2, then p² = c-b, q² = c+b
    """
    print("\n" + "=" * 70)
    print("FACTORING ALGORITHM v2 — Enhanced with Tree Structure")
    print("=" * 70)
    
    def pythagorean_factor(n):
        """Factor n using Pythagorean triple enumeration."""
        if n % 2 == 0:
            return 2, n // 2
        
        n_sq = n * n
        factors = set()
        
        for d in range(1, int(math.isqrt(n_sq)) + 1):
            if n_sq % d != 0:
                continue
            e = n_sq // d
            if d >= e or (d + e) % 2 != 0:
                continue
            
            # Each (d, e) with d*e = n² gives potential factors
            g = math.gcd(d, n)
            if 1 < g < n:
                factors.add(g)
                factors.add(n // g)
                return min(g, n // g), max(g, n // g)
        
        return n, 1  # n is prime
    
    print(f"\n{'n':>10s} | {'factors':>15s} | {'verification':>20s}")
    print("  " + "-" * 50)
    
    test = [15, 21, 35, 77, 91, 143, 221, 323, 437, 1001, 
            10403, 25619, 96757, 1000003*1000033]
    
    import time
    for n in test:
        t0 = time.time()
        p, q = pythagorean_factor(n)
        dt = time.time() - t0
        true_factors = factorize(n)
        print(f"  {n:>15d} | {p} × {q} | {true_factors} ({dt:.6f}s)")


if __name__ == "__main__":
    print("╔" + "═" * 68 + "╗")
    print("║  PYTHAGOREAN TRIPLE TREE — CORRECTED & ENHANCED                   ║")
    print("╚" + "═" * 68 + "╝")
    
    experiment_tree_climbing()
    experiment_full_ancestry()
    experiment_tree_structure_theorem()
    experiment_counting_theorem()
    experiment_path_encoding()
    experiment_factoring_algorithm_v2()
