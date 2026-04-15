#!/usr/bin/env python3
"""
Gravitational Factoring on Pythagorean k-Tuple Trees:
Computational Exploration of Future Research Directions

This script demonstrates:
1. The peel channel factoring mechanism
2. Density of factoring-revealing k-tuples (empirical)
3. Quaternion norm factoring
4. Octonionic 8-square identity verification
5. Parity obstruction analysis
6. Channel count scaling
7. Factoring energy landscape
8. Statistical mechanics analogy
"""

import math
import random
from collections import defaultdict
from itertools import product as cartesian_product

# ═══════════════════════════════════════════════════════════════════════════
# §1. PEEL CHANNEL FACTORING
# ═══════════════════════════════════════════════════════════════════════════

def gcd(a, b):
    """Euclidean GCD."""
    a, b = abs(a), abs(b)
    while b:
        a, b = b, a % b
    return a

def find_pythagorean_quadruples(N, max_search=10000):
    """Find Pythagorean quadruples a²+b²+c²=N² by random search."""
    quadruples = []
    N2 = N * N
    for _ in range(max_search):
        a = random.randint(0, N-1)
        b = random.randint(0, int(math.sqrt(N2 - a*a)))
        rem = N2 - a*a - b*b
        if rem < 0:
            continue
        c = int(math.sqrt(rem))
        if c*c == rem:
            quadruples.append((a, b, c, N))
    return quadruples

def peel_factor(quad, N):
    """Try all peel channels of a quadruple to factor N."""
    a, b, c, d = quad
    for x in [a, b, c]:
        g = gcd(d - x, N)
        if 1 < g < N:
            return g
        g = gcd(d + x, N)
        if 1 < g < N:
            return g
    return None

def demo_peel_factoring():
    """Demonstrate peel channel factoring on small semiprimes."""
    print("=" * 70)
    print("§1. PEEL CHANNEL FACTORING DEMO")
    print("=" * 70)

    test_cases = [
        (3, 5),   # 15
        (5, 7),   # 35
        (7, 11),  # 77
        (11, 13), # 143
        (13, 17), # 221
        (17, 19), # 323
        (23, 29), # 667
        (31, 37), # 1147
    ]

    for p, q in test_cases:
        N = p * q
        quads = find_pythagorean_quadruples(N, max_search=50000)
        factor_found = None
        revealing_count = 0

        for quad in quads:
            f = peel_factor(quad, N)
            if f:
                revealing_count += 1
                if factor_found is None:
                    factor_found = f

        density = revealing_count / max(len(quads), 1)
        status = f"✓ Found factor {factor_found}" if factor_found else "✗ No factor"
        print(f"  N = {p}×{q} = {N:>6d} | {len(quads):>4d} quadruples | "
              f"{revealing_count:>3d} revealing ({density:.1%}) | {status}")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §2. DENSITY OF FACTORING-REVEALING K-TUPLES
# ═══════════════════════════════════════════════════════════════════════════

def compute_factoring_density(N, k, num_samples=10000):
    """Estimate the fraction of random k-tuples with hypotenuse N
    that reveal a factor via GCD."""
    N2 = N * N
    revealing = 0
    valid = 0

    for _ in range(num_samples):
        # Generate random components
        components = []
        remaining = N2
        for i in range(k - 1):
            max_val = int(math.sqrt(remaining))
            if max_val <= 0:
                break
            x = random.randint(0, max_val)
            components.append(x)
            remaining -= x * x

        if remaining < 0 or len(components) < k - 1:
            continue

        last = int(math.sqrt(remaining))
        if last * last == remaining:
            components.append(last)
            valid += 1

            # Check all peel channels
            for x in components:
                g = gcd(N - x, N)
                if 1 < g < N:
                    revealing += 1
                    break
                g = gcd(N + x, N)
                if 1 < g < N:
                    revealing += 1
                    break

    return revealing / max(valid, 1), valid

def demo_density():
    """Measure factoring density across dimensions and semiprimes."""
    print("=" * 70)
    print("§2. FACTORING DENSITY vs DIMENSION k")
    print("=" * 70)

    semiprimes = [(5, 7), (11, 13), (23, 29), (41, 43)]

    for p, q in semiprimes:
        N = p * q
        print(f"\n  N = {p}×{q} = {N}")
        for k in [3, 4, 5, 8]:
            density, valid = compute_factoring_density(N, k, num_samples=20000)
            print(f"    k={k}: density ≈ {density:.4f} (from {valid} valid tuples)")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §3. QUATERNION NORM FACTORING
# ═══════════════════════════════════════════════════════════════════════════

def quaternion_norm(a, b, c, d):
    return a*a + b*b + c*c + d*d

def quaternion_multiply(q1, q2):
    """Hamilton quaternion product."""
    a1, b1, c1, d1 = q1
    a2, b2, c2, d2 = q2
    return (
        a1*a2 - b1*b2 - c1*c2 - d1*d2,
        a1*b2 + b1*a2 + c1*d2 - d1*c2,
        a1*c2 - b1*d2 + c1*a2 + d1*b2,
        a1*d2 + b1*c2 - c1*b2 + d1*a2
    )

def find_four_square_rep(n, max_search=10000):
    """Find a representation n = a²+b²+c²+d²."""
    for _ in range(max_search):
        a = random.randint(0, int(math.sqrt(n)))
        rem1 = n - a*a
        if rem1 < 0: continue
        b = random.randint(0, int(math.sqrt(rem1)))
        rem2 = rem1 - b*b
        if rem2 < 0: continue
        c = random.randint(0, int(math.sqrt(rem2)))
        rem3 = rem2 - c*c
        if rem3 < 0: continue
        d = int(math.sqrt(rem3))
        if d*d == rem3:
            return (a, b, c, d)
    return None

def demo_quaternion_factoring():
    """Demonstrate quaternion-based factoring."""
    print("=" * 70)
    print("§3. QUATERNION NORM FACTORING")
    print("=" * 70)

    test_cases = [(5, 7), (11, 13), (17, 19), (23, 29), (31, 37)]

    for p, q in test_cases:
        N = p * q
        rep_p = find_four_square_rep(p)
        rep_q = find_four_square_rep(q)

        if rep_p and rep_q:
            product = quaternion_multiply(rep_p, rep_q)
            norm_prod = quaternion_norm(*product)
            assert norm_prod == N, f"Norm mismatch: {norm_prod} ≠ {N}"

            # Try to extract factors from the product representation
            factors_found = set()
            for x in product:
                g = gcd(abs(x), N)
                if 1 < g < N:
                    factors_found.add(g)

            print(f"  N = {p}×{q} = {N:>6d}")
            print(f"    p={p} as 4-sq: {rep_p}")
            print(f"    q={q} as 4-sq: {rep_q}")
            print(f"    Product quaternion: {product}")
            print(f"    Norm check: {norm_prod} = {N} ✓")
            if factors_found:
                print(f"    Factors found via GCD: {factors_found} ✓")
            else:
                print(f"    No factors from direct GCD (need peel channels)")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §4. EIGHT-SQUARE IDENTITY VERIFICATION
# ═══════════════════════════════════════════════════════════════════════════

def octonion_norm(v):
    return sum(x*x for x in v)

def degen_product(a, b):
    """Compute the Degen eight-square product (matching verified Lean formula)."""
    a1,a2,a3,a4,a5,a6,a7,a8 = a
    b1,b2,b3,b4,b5,b6,b7,b8 = b
    return (
        a1*b1 - a2*b2 - a3*b3 - a4*b4 - a5*b5 - a6*b6 - a7*b7 - a8*b8,
        a1*b2 + a2*b1 + a3*b4 - a4*b3 + a5*b6 - a6*b5 - a7*b8 + a8*b7,
        a1*b3 - a2*b4 + a3*b1 + a4*b2 + a5*b7 + a6*b8 - a7*b5 - a8*b6,
        a1*b4 + a2*b3 - a3*b2 + a4*b1 + a5*b8 - a6*b7 + a7*b6 - a8*b5,
        a1*b5 - a2*b6 - a3*b7 - a4*b8 + a5*b1 + a6*b2 + a7*b3 + a8*b4,
        a1*b6 + a2*b5 - a3*b8 + a4*b7 - a5*b2 + a6*b1 - a7*b4 + a8*b3,
        a1*b7 + a2*b8 + a3*b5 - a4*b6 - a5*b3 + a6*b4 + a7*b1 - a8*b2,
        a1*b8 - a2*b7 + a3*b6 + a4*b5 - a5*b4 - a6*b3 + a7*b2 + a8*b1,
    )

def demo_eight_square():
    """Verify the Degen eight-square identity computationally."""
    print("=" * 70)
    print("§4. DEGEN EIGHT-SQUARE IDENTITY VERIFICATION")
    print("=" * 70)

    # Test with random vectors
    for trial in range(5):
        a = tuple(random.randint(-10, 10) for _ in range(8))
        b = tuple(random.randint(-10, 10) for _ in range(8))

        product = degen_product(a, b)
        lhs = octonion_norm(a) * octonion_norm(b)
        rhs = octonion_norm(product)

        status = "✓" if lhs == rhs else "✗ FAILED"
        print(f"  Trial {trial+1}: ||a||²={octonion_norm(a):>6d}, ||b||²={octonion_norm(b):>6d} | "
              f"LHS={lhs:>10d}, RHS={rhs:>10d} {status}")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §5. PARITY OBSTRUCTION ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════

def demo_parity():
    """Analyze parity patterns in factoring-revealing tuples."""
    print("=" * 70)
    print("§5. PARITY OBSTRUCTION ANALYSIS")
    print("=" * 70)

    N = 77  # 7 × 11
    print(f"\n  N = 7 × 11 = {N} (odd)")

    parity_stats = defaultdict(lambda: {"total": 0, "revealing": 0})

    N2 = N * N
    for a in range(N):
        for b in range(a, N):
            rem = N2 - a*a - b*b
            if rem < 0: break
            c = int(math.sqrt(rem))
            if c*c == rem and c >= b:
                parity = (a % 2, b % 2, c % 2)
                parity_stats[parity]["total"] += 1

                # Check peel channels
                for x in [a, b, c]:
                    g = gcd(N - x, N)
                    if 1 < g < N:
                        parity_stats[parity]["revealing"] += 1
                        break
                    g = gcd(N + x, N)
                    if 1 < g < N:
                        parity_stats[parity]["revealing"] += 1
                        break

    print(f"\n  Parity pattern analysis (a%2, b%2, c%2):")
    print(f"  {'Pattern':<15} {'Total':>8} {'Revealing':>10} {'Density':>10}")
    print(f"  {'-'*45}")
    for parity in sorted(parity_stats.keys()):
        stats = parity_stats[parity]
        density = stats["revealing"] / max(stats["total"], 1)
        label = f"({parity[0]},{parity[1]},{parity[2]})"
        print(f"  {label:<15} {stats['total']:>8} {stats['revealing']:>10} {density:>10.4f}")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §6. CHANNEL COUNT SCALING
# ═══════════════════════════════════════════════════════════════════════════

def demo_channel_scaling():
    """Show how factoring channels scale with dimension."""
    print("=" * 70)
    print("§6. CHANNEL COUNT SCALING")
    print("=" * 70)

    print(f"\n  {'k':>4} {'Peel':>8} {'Cross':>8} {'Total':>8} {'Algebra':>12}")
    print(f"  {'-'*44}")

    algebras = {
        1: "ℝ (reals)",
        2: "ℂ (complex)",
        4: "ℍ (quaternion)",
        8: "𝕆 (octonion)",
        16: "𝕊 (sedenion)",
    }

    for k in range(1, 33):
        peel = k
        cross = k * (k - 1) // 2
        total = peel + cross
        alg = algebras.get(k, "")
        print(f"  {k:>4} {peel:>8} {cross:>8} {total:>8}   {alg}")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §7. ENERGY LANDSCAPE VISUALIZATION DATA
# ═══════════════════════════════════════════════════════════════════════════

def factoring_energy(x, N):
    """Energy: distance from having d² - x² be a product revealing a factor."""
    min_energy = float('inf')
    for offset in range(-5, 6):
        d = N + offset
        rem = d*d - x*x
        if rem > 0:
            g = gcd(d - x, N)
            if g > 1:
                energy = abs(offset)
            else:
                # Distance to nearest factoring-revealing point
                energy = min(abs(x - (N % p)) for p in [7, 11] if N % p == 0 or True)
                energy = abs(offset) + 1
            min_energy = min(min_energy, energy)
    return min_energy

def demo_energy_landscape():
    """Generate energy landscape data."""
    print("=" * 70)
    print("§7. ENERGY LANDSCAPE (N = 77 = 7 × 11)")
    print("=" * 70)

    N = 77
    p, q = 7, 11

    print(f"\n  Revealing x values (where gcd(N-x, N) > 1):")
    revealing = []
    for x in range(N):
        g = gcd(N - x, N)
        if 1 < g < N:
            revealing.append((x, g))

    for x, g in revealing[:20]:
        print(f"    x = {x:>3d} → gcd({N}-{x}, {N}) = gcd({N-x}, {N}) = {g}")

    print(f"\n  Total revealing values in [0, {N}): {len(revealing)}")
    print(f"  Expected: N/p + N/q - N/(pq) = {N//p} + {N//q} - {N//(p*q)} = {N//p + N//q - N//(p*q)}")
    print()

# ═══════════════════════════════════════════════════════════════════════════
# §8. STATISTICAL MECHANICS ANALOGY
# ═══════════════════════════════════════════════════════════════════════════

def demo_stat_mech():
    """Explore the statistical mechanics of factoring."""
    print("=" * 70)
    print("§8. STATISTICAL MECHANICS OF FACTORING")
    print("=" * 70)

    N = 143  # 11 × 13
    p, q = 11, 13

    print(f"\n  N = {p}×{q} = {N}")
    print(f"\n  Temperature scan (T = search coarseness):")
    print(f"  {'T':>8} {'Z (partition fn)':>18} {'⟨E⟩ (avg energy)':>18} {'P(factor)':>12}")
    print(f"  {'-'*58}")

    for T in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        Z = 0.0
        E_avg = 0.0
        P_factor = 0.0

        for x in range(1, N):
            g = gcd(N - x, N)
            if g == 1 or g == N:
                E = 1.0  # high energy (no factor)
            else:
                E = 0.0  # zero energy (factor found!)

            boltzmann = math.exp(-E / T)
            Z += boltzmann
            E_avg += E * boltzmann
            if E == 0:
                P_factor += boltzmann

        E_avg /= Z
        P_factor /= Z

        print(f"  {T:>8.1f} {Z:>18.2f} {E_avg:>18.4f} {P_factor:>12.4f}")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# §9. CROSS-COLLISION DEMONSTRATION
# ═══════════════════════════════════════════════════════════════════════════

def demo_cross_collision():
    """Demonstrate cross-collision factoring."""
    print("=" * 70)
    print("§9. CROSS-COLLISION FACTORING")
    print("=" * 70)

    N = 65  # 5 × 13
    print(f"\n  N = 5 × 13 = {N}")
    print(f"  Finding pairs of quadruples sharing hypotenuse {N}...")

    quads = find_pythagorean_quadruples(N, max_search=100000)
    # Remove duplicates (up to ordering)
    unique_quads = set()
    for a, b, c, d in quads:
        key = tuple(sorted([abs(a), abs(b), abs(c)]))
        unique_quads.add(key + (d,))

    unique_quads = list(unique_quads)
    print(f"  Found {len(unique_quads)} distinct quadruples with d={N}")

    # Show cross-collision
    if len(unique_quads) >= 2:
        for i in range(min(3, len(unique_quads))):
            for j in range(i+1, min(4, len(unique_quads))):
                q1 = unique_quads[i]
                q2 = unique_quads[j]
                print(f"\n  Quad 1: {q1[:3]}² sums to {N}²")
                print(f"  Quad 2: {q2[:3]}² sums to {N}²")

                # Cross-collision: differences of squares
                for idx in range(3):
                    diff = q1[idx]**2 - q2[idx]**2
                    if diff != 0:
                        g = gcd(diff, N)
                        if 1 < g < N:
                            print(f"    Cross-collision at index {idx}: "
                                  f"{q1[idx]}²-{q2[idx]}² = {diff}, "
                                  f"gcd({diff}, {N}) = {g} ← FACTOR!")
    print()

# ═══════════════════════════════════════════════════════════════════════════
# §10. OPTIMAL DIMENSION SEARCH
# ═══════════════════════════════════════════════════════════════════════════

def demo_optimal_dimension():
    """Search for the optimal dimension for factoring various N."""
    print("=" * 70)
    print("§10. OPTIMAL DIMENSION SEARCH")
    print("=" * 70)

    semiprimes = [(5, 7), (11, 13), (23, 29), (41, 43), (61, 67)]

    for p, q in semiprimes:
        N = p * q
        print(f"\n  N = {p}×{q} = {N}")
        best_k = 3
        best_score = 0

        for k in [3, 4, 5, 8]:
            # Score = channels × density
            channels = k + k*(k-1)//2
            density, valid = compute_factoring_density(N, k, num_samples=5000)
            score = channels * density
            print(f"    k={k}: channels={channels:>3d}, density≈{density:.4f}, score={score:.4f}")
            if score > best_score:
                best_score = score
                best_k = k

        print(f"    → Best dimension: k={best_k}")

    print()

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    random.seed(42)

    print("\n" + "█" * 70)
    print("  GRAVITATIONAL FACTORING: COMPUTATIONAL EXPLORATION")
    print("  Future Research Directions")
    print("█" * 70 + "\n")

    demo_peel_factoring()
    demo_quaternion_factoring()
    demo_eight_square()
    demo_parity()
    demo_channel_scaling()
    demo_energy_landscape()
    demo_stat_mech()
    demo_cross_collision()
    demo_density()
    demo_optimal_dimension()

    print("\n" + "█" * 70)
    print("  EXPLORATION COMPLETE")
    print("█" * 70)
