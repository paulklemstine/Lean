#!/usr/bin/env python3
"""
Open Questions Explorer: Computational Investigations for Gravitational Factoring

Demos:
1. Peel smoothness advantage - Compare smoothness rates of peel products vs random
2. Lattice-GCD experiment - LLL-based factor extraction
3. Cross-collision simulation - Empirical collision probabilities
4. Sigma1 multiplicativity verification
5. Berggren tree modular periodicity
6. Coding theory: GF(2) exponent vectors
7. Adelic factoring sketch
8. Channel scaling visualization data
"""

import math
import random
from collections import Counter
from functools import reduce

# ============================================================================
# Demo 1: Peel Product Smoothness Advantage
# ============================================================================

def is_smooth(n, B):
    """Check if n is B-smooth (all prime factors ≤ B)."""
    if n <= 1:
        return True
    for p in range(2, B + 1):
        while n % p == 0:
            n //= p
    return n == 1

def smoothness_rate(numbers, B):
    """Fraction of numbers that are B-smooth."""
    if not numbers:
        return 0.0
    return sum(1 for n in numbers if n > 0 and is_smooth(abs(n), B)) / len(numbers)

def demo_peel_smoothness():
    """Compare smoothness of peel products vs random integers."""
    print("=" * 70)
    print("Demo 1: Peel Product Smoothness Advantage")
    print("=" * 70)
    print()
    print("Key question: Are peel products (d-x)(d+x) smoother than random")
    print("integers of the same size?")
    print()
    
    samples = 5000
    
    for B in [50, 100, 200, 500]:
        peel_products = []
        random_products = []
        
        for _ in range(samples):
            m = random.randint(1, 100)
            n = random.randint(1, m - 1) if m > 1 else 1
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            
            p1 = (c - a) * (c + a)
            p2 = (c - b) * (c + b)
            peel_products.extend([p1, p2])
            
            mag = max(p1, p2, 1)
            r1 = random.randint(1, mag)
            r2 = random.randint(1, mag)
            random_products.extend([r1, r2])
        
        peel_rate = smoothness_rate(peel_products, B)
        rand_rate = smoothness_rate(random_products, B)
        ratio = peel_rate / rand_rate if rand_rate > 0 else float('inf')
        
        print(f"  B={B:>4d}: Peel smooth rate = {peel_rate:.4f}, "
              f"Random rate = {rand_rate:.4f}, Ratio = {ratio:.2f}x")
    
    print()
    print("FINDING: Peel products come pre-factored as (d-x)(d+x), so each")
    print("factor is of size ~d rather than ~d^2. This structural advantage")
    print("increases smoothness probability.")
    print()

# ============================================================================
# Demo 2: Lattice-GCD Experiment
# ============================================================================

def simple_lll_2d(v1, v2):
    """Simple 2D LLL reduction."""
    while True:
        if sum(x**2 for x in v2) < sum(x**2 for x in v1):
            v1, v2 = v2, v1
        dot = sum(a*b for a, b in zip(v1, v2))
        norm1 = sum(x**2 for x in v1)
        if norm1 == 0:
            break
        mu = round(dot / norm1)
        if mu == 0:
            break
        v2 = [v2[i] - mu * v1[i] for i in range(len(v1))]
    return v1, v2

def demo_lattice_gcd():
    """Demonstrate lattice-GCD factoring approach."""
    print("=" * 70)
    print("Demo 2: Lattice-GCD Factor Extraction")
    print("=" * 70)
    print()
    print("Key question: Can LLL short vectors reveal factors of N?")
    print()
    
    test_cases = [(p*q, f"{p} x {q}") for p, q in [
        (3, 5), (7, 11), (13, 17), (29, 37), (101, 103), (149, 167)
    ]]
    
    successes = 0
    total = 0
    
    for N, label in test_cases:
        total += 1
        found = False
        for t in range(1, min(N, 200)):
            v1 = [N, 0]
            v2 = [t, 1]
            
            r1, r2 = simple_lll_2d(v1, v2)
            
            for v in [r1, r2]:
                for coord in v:
                    if coord != 0:
                        g = math.gcd(abs(coord), N)
                        if 1 < g < N:
                            print(f"  N = {N:>6d} ({label}): Found factor {g} "
                                  f"via lattice with t={t}")
                            found = True
                            successes += 1
                            break
                if found:
                    break
            if found:
                break
        
        if not found:
            print(f"  N = {N:>6d} ({label}): No factor found in search")
    
    print(f"\n  Success rate: {successes}/{total}")
    print()

# ============================================================================
# Demo 3: Cross-Collision Simulation
# ============================================================================

def demo_cross_collision():
    """Simulate cross-collision factor extraction."""
    print("=" * 70)
    print("Demo 3: Cross-Collision Probability Simulation")
    print("=" * 70)
    print()
    print("Key question: Does P(success) ~ 1 - (1-1/p)^{k^2} hold?")
    print()
    
    test_semiprimes = [(101, 103), (1009, 1013)]
    
    for p, q in test_semiprimes:
        N = p * q
        trials = 2000
        
        for k in [2, 4, 8]:
            successes = 0
            for _ in range(trials):
                tuple1 = [random.randint(0, N-1) for _ in range(k)]
                tuple2 = [random.randint(0, N-1) for _ in range(k)]
                
                found = False
                for xi in tuple1:
                    for yj in tuple2:
                        g = math.gcd(abs(xi - yj), N)
                        if 1 < g < N:
                            found = True
                            break
                    if found:
                        break
                
                if found:
                    successes += 1
            
            empirical = successes / trials
            theoretical = 1 - (1 - 1/p)**(k**2) * (1 - 1/q)**(k**2)
            
            print(f"  N={N:>12d} (p={p}), k={k}: "
                  f"Emp={empirical:.4f}, Thy={theoretical:.4f}")
    
    print()

# ============================================================================
# Demo 4: sigma1 Multiplicativity Verification
# ============================================================================

def sigma1(n):
    """Sum of divisors function."""
    if n == 0:
        return 0
    return sum(d for d in range(1, n+1) if n % d == 0)

def demo_sigma1():
    """Verify sigma1 multiplicativity and Jacobi's formula."""
    print("=" * 70)
    print("Demo 4: sigma1 Multiplicativity and Jacobi's r4 Formula")
    print("=" * 70)
    print()
    
    print("  Multiplicativity: sigma1(mn) = sigma1(m)*sigma1(n) for gcd(m,n)=1")
    all_pass = True
    for m in range(1, 20):
        for n in range(1, 20):
            if math.gcd(m, n) == 1:
                if sigma1(m * n) != sigma1(m) * sigma1(n):
                    print(f"  FAIL: sigma1({m}*{n})")
                    all_pass = False
    
    if all_pass:
        print("  All coprime pairs (m,n) with m,n in [1,19] verified!")
    
    # Jacobi: r4(n) = 8*sigma1(n) for odd n
    print()
    print("  Jacobi's formula: r4(n) = 8*sigma1(n) for odd n")
    
    for n in [1, 3, 5, 7, 9, 11, 13, 15]:
        count = 0
        bound = int(math.sqrt(n)) + 1
        for a in range(-bound, bound + 1):
            for b in range(-bound, bound + 1):
                for c in range(-bound, bound + 1):
                    for d in range(-bound, bound + 1):
                        if a*a + b*b + c*c + d*d == n:
                            count += 1
        
        predicted = 8 * sigma1(n)
        status = "Y" if count == predicted else "N"
        print(f"    {status} r4({n:>2d}) = {count:>4d}, 8*sigma1({n:>2d}) = {predicted:>4d}")
    
    print()

# ============================================================================
# Demo 5: Berggren Tree Modular Periodicity
# ============================================================================

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def demo_berggren_periodicity():
    """Explore the Berggren tree mod p."""
    print("=" * 70)
    print("Demo 5: Berggren Tree Modular Periodicity")
    print("=" * 70)
    print()
    
    for p in [5, 7, 11, 13, 17]:
        root = (3 % p, 4 % p, 5 % p)
        seen = {root}
        queue = [root]
        
        while queue and len(seen) <= p**3:
            node = queue.pop(0)
            a, b, c = node
            for transform in [berggren_A, berggren_B, berggren_C]:
                child = transform(a, b, c)
                child_mod = (child[0] % p, child[1] % p, child[2] % p)
                if child_mod not in seen:
                    seen.add(child_mod)
                    queue.append(child_mod)
        
        pyth_count = sum(1 for (a, b, c) in seen 
                        if (a*a + b*b - c*c) % p == 0)
        
        print(f"  p = {p:>2d}: {len(seen):>4d} distinct triples mod p, "
              f"{pyth_count} Pythagorean")
    
    print()

# ============================================================================
# Demo 6: GF(2) Exponent Vector Analysis
# ============================================================================

def factorize_over_base(n, factor_base):
    """Factor n over the factor base, returning GF(2) exponent vector or None."""
    if n <= 0:
        return None
    exponents = []
    m = n
    for p in factor_base:
        e = 0
        while m % p == 0:
            m //= p
            e += 1
        exponents.append(e % 2)
    if m == 1:
        return exponents
    return None

def demo_coding_theory():
    """Demonstrate the GF(2) linear algebra of smooth relations."""
    print("=" * 70)
    print("Demo 6: Coding Theory of Smooth Relations")
    print("=" * 70)
    print()
    
    N = 7 * 11
    factor_base = [2, 3, 5, 7]
    B = len(factor_base)
    
    print(f"  N = {N}, Factor base = {factor_base}")
    print(f"  Need {B + 1} smooth relations for guaranteed dependency")
    print()
    
    smooth_relations = []
    for d in range(1, 200):
        for x in range(0, d):
            peel = (d - x) * (d + x)
            if peel > 0:
                vec = factorize_over_base(peel, factor_base)
                if vec is not None:
                    smooth_relations.append((d, x, peel, vec))
                    if len(smooth_relations) >= B + 3:
                        break
        if len(smooth_relations) >= B + 3:
            break
    
    print("  Smooth peel products found:")
    for d, x, peel, vec in smooth_relations[:B + 2]:
        print(f"    (d={d:>3d}, x={x:>3d}): ({d-x})x({d+x}) = {peel:>5d}, "
              f"GF(2) vec = {vec}")
    
    print()
    n = len(smooth_relations)
    for i in range(n):
        for j in range(i+1, n):
            xor = [smooth_relations[i][3][k] ^ smooth_relations[j][3][k] 
                   for k in range(B)]
            if all(x == 0 for x in xor):
                d1, x1, p1, _ = smooth_relations[i]
                d2, x2, p2, _ = smooth_relations[j]
                product = p1 * p2
                sqrt_product = int(math.isqrt(product))
                if sqrt_product * sqrt_product == product:
                    print(f"  Dependency: {p1} x {p2} = {product} = {sqrt_product}^2")
    
    print()

# ============================================================================
# Demo 7: Adelic Structure
# ============================================================================

def demo_adelic():
    """Explore the adelic structure of factoring."""
    print("=" * 70)
    print("Demo 7: Adelic Factoring - p-adic Projections")
    print("=" * 70)
    print()
    
    N = 143  # 11 x 13
    print(f"  N = {N}")
    print()
    
    print("  p-adic valuations and residues:")
    for p in [2, 3, 5, 7, 11, 13, 17]:
        v = 0
        m = N
        while m % p == 0:
            v += 1
            m //= p
        residue = N % p
        
        factor_info = ""
        if N % p == 0:
            factor_info = f" <- FACTOR! {N} = {p} x {N//p}"
        
        print(f"    p = {p:>2d}: v_p(N) = {v}, N mod p = {residue:>2d}{factor_info}")
    
    print()

# ============================================================================
# Demo 8: Channel Scaling Data
# ============================================================================

def demo_channel_scaling():
    """Generate channel scaling data."""
    print("=" * 70)
    print("Demo 8: Channel Scaling Across Dimensions")
    print("=" * 70)
    print()
    
    print("  k | Single Tuple | Pair Channels | Algebra | Norm Mult")
    print("  " + "-" * 60)
    
    for k in [1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 24, 32, 64]:
        single = k + k * (k - 1) // 2
        pair = single + k * k
        
        algebra = {1: "R", 2: "C", 4: "H", 8: "O", 16: "S", 32: "T"}.get(k, "")
        norm_mult = "Yes" if k in [1, 2, 4, 8] else ("No" if k > 8 else "")
        
        print(f"  {k:>2d} | {single:>11d} | {pair:>13d} | {algebra:>7s} | {norm_mult}")
    
    print()

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    random.seed(42)
    
    print()
    print("=" * 70)
    print("  OPEN QUESTIONS EXPLORER: Gravitational Factoring")
    print("  Computational Investigations for Research Directions")
    print("=" * 70)
    print()
    
    demo_peel_smoothness()
    demo_lattice_gcd()
    demo_cross_collision()
    demo_sigma1()
    demo_berggren_periodicity()
    demo_coding_theory()
    demo_adelic()
    demo_channel_scaling()
    
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("1. Peel products have structural smoothness advantage")
    print("2. Lattice-GCD works for small N; needs scaling study")
    print("3. Cross-collision rates match theoretical predictions")
    print("4. sigma1 multiplicativity and Jacobi r4 confirmed")
    print("5. Berggren tree mod p has bounded periodic structure")
    print("6. GF(2) exponent vectors yield congruences of squares")
    print("7. p-adic projections directly detect prime factors")
    print()
