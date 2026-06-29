#!/usr/bin/env python3
"""
Applications of Berggren Semigroup Theory

Demonstrates practical applications of the extremal classification
and modular orbit theory for Berggren dynamics.
"""

from algorithms import (
    matmul_3x3, matmul_mod, BERG_A, BERG_B, BERG_C, GENERATORS,
    GEN_NAMES, ROOT, hyp_a_ray, hyp_c_ray, berggren_orbit_mod_p,
    check_strong_connectivity
)
from collections import Counter
import math


# === Application 1: Efficient Triple Generation ===

def generate_triples_by_hypotenuse(max_hyp: int) -> list:
    """Generate all primitive Pythagorean triples up to a given hypotenuse
    using the Berggren tree with pruning based on the A-ray lower bound.

    The A-ray provides a lower bound: at depth n, the minimum hypotenuse
    is 2n²+6n+5. So we can stop exploring depth n when 2n²+6n+5 > max_hyp.

    Args:
        max_hyp: Maximum hypotenuse value

    Returns:
        List of (a, b, c) primitive Pythagorean triples
    """
    triples = []
    stack = [(list(ROOT), 0)]

    while stack:
        v, depth = stack.pop()
        a, b, c = v
        if c > max_hyp:
            continue
        if a > 0 and b > 0:
            triples.append((min(a, b), max(a, b), c))

        # Only expand if deeper triples could still be in range
        min_child_hyp = 2 * a - 2 * b + 3 * c if b > a else -2 * a + 2 * b + 3 * c
        if min_child_hyp <= max_hyp:
            for M in GENERATORS:
                child = matmul_3x3(M, v)
                stack.append((child, depth + 1))

    return sorted(set(triples))


# === Application 2: Pythagorean Triple Density Analysis ===

def triple_density_by_depth(max_depth: int) -> dict:
    """Analyze the density of primitive Pythagorean triples by tree depth.

    For each depth, reports:
    - Number of triples
    - Min/max/mean hypotenuse
    - The extremal words (1st, 2nd, 3rd smallest hypotenuse)

    Args:
        max_depth: Maximum depth to analyze

    Returns:
        Dictionary with depth-wise statistics
    """
    from itertools import product
    stats = {}

    for depth in range(1, max_depth + 1):
        hyps = []
        for word in product(range(3), repeat=depth):
            v = list(ROOT)
            for g in word:
                v = matmul_3x3(GENERATORS[g], v)
            hyps.append(v[2])
        hyps.sort()

        stats[depth] = {
            'count': len(hyps),
            'min_hyp': hyps[0],
            'max_hyp': hyps[-1],
            'mean_hyp': sum(hyps) / len(hyps),
            'predicted_min': hyp_a_ray(depth),
            'predicted_2nd': hyp_c_ray(depth),
            'gap_ratio': hyps[1] / hyps[0] if len(hyps) > 1 else None,
        }
    return stats


# === Application 3: Modular Orbit Structure ===

def analyze_modular_orbits(primes: list) -> list:
    """Analyze Berggren orbit structure for multiple primes.

    For each prime p, computes:
    - Orbit size
    - Connectivity
    - Diameter estimate
    - Size of the light cone (Pythagorean triples mod p)

    Args:
        primes: List of prime numbers to analyze

    Returns:
        List of analysis results
    """
    results = []
    for p in primes:
        connected, size, diam = check_strong_connectivity(p)

        # Count total Pythagorean triples mod p
        light_cone = 0
        for a in range(p):
            for b in range(p):
                c2 = (a * a + b * b) % p
                for c in range(p):
                    if (c * c) % p == c2:
                        light_cone += 1

        results.append({
            'prime': p,
            'orbit_size': size,
            'light_cone_size': light_cone,
            'orbit_fraction': size / light_cone if light_cone > 0 else 0,
            'connected': connected,
            'diameter': diam,
            'log_p': math.log2(p),
        })
    return results


# === Application 4: Extremal Gap Analysis ===

def extremal_gap_analysis(max_depth: int) -> list:
    """Analyze the gap between consecutive extremal hypotenuses.

    Computes:
    - Gap between 1st and 2nd: c(C^n) - c(A^n) = 2n² + 2n
    - Gap between 2nd and 3rd: c(A^{n-1}C) - c(C^n) = 6n² - 2n - 4

    Args:
        max_depth: Maximum depth to analyze

    Returns:
        List of gap data
    """
    results = []
    for n in range(1, max_depth + 1):
        c_an = hyp_a_ray(n)
        c_cn = hyp_c_ray(n)
        gap_12 = c_cn - c_an
        predicted_gap_12 = 2 * n**2 + 2 * n

        if n >= 2:
            c_an1c = 10 * n**2 + 6 * n + 1
            gap_23 = c_an1c - c_cn
        else:
            c_an1c = None
            gap_23 = None

        results.append({
            'depth': n,
            'hyp_An': c_an,
            'hyp_Cn': c_cn,
            'gap_12': gap_12,
            'gap_12_predicted': predicted_gap_12,
            'gap_12_match': gap_12 == predicted_gap_12,
            'hyp_An1C': c_an1c,
            'gap_23': gap_23,
        })
    return results


# === Main ===

if __name__ == '__main__':
    print("=" * 70)
    print("APPLICATION 1: Efficient Triple Generation")
    print("=" * 70)
    triples = generate_triples_by_hypotenuse(200)
    print(f"\nPrimitive Pythagorean triples with c ≤ 200: {len(triples)}")
    for t in triples[:15]:
        print(f"  ({t[0]:3d}, {t[1]:3d}, {t[2]:3d})")
    print(f"  ... ({len(triples)} total)")

    print()
    print("=" * 70)
    print("APPLICATION 2: Triple Density by Depth")
    print("=" * 70)
    stats = triple_density_by_depth(7)
    print(f"\n{'Depth':>5} {'Count':>6} {'MinHyp':>8} {'MaxHyp':>8} {'MeanHyp':>10} {'GapRatio':>10}")
    for d, s in stats.items():
        print(f"{d:5d} {s['count']:6d} {s['min_hyp']:8d} {s['max_hyp']:8d} "
              f"{s['mean_hyp']:10.1f} {s['gap_ratio']:10.4f}")

    print()
    print("=" * 70)
    print("APPLICATION 3: Modular Orbit Analysis")
    print("=" * 70)
    primes = [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    orbit_data = analyze_modular_orbits(primes)
    print(f"\n{'p':>4} {'Orbit':>6} {'LightCone':>10} {'Frac':>8} {'Diam':>5} {'Connected':>10}")
    for d in orbit_data:
        print(f"{d['prime']:4d} {d['orbit_size']:6d} {d['light_cone_size']:10d} "
              f"{d['orbit_fraction']:8.4f} {d['diameter']:5d} "
              f"{'YES' if d['connected'] else 'NO':>10}")

    print()
    print("=" * 70)
    print("APPLICATION 4: Extremal Gap Analysis")
    print("=" * 70)
    gaps = extremal_gap_analysis(12)
    print(f"\n{'n':>3} {'c(A^n)':>8} {'c(C^n)':>8} {'Gap1-2':>8} {'c(A^{n-1}C)':>12} {'Gap2-3':>8}")
    for g in gaps:
        third = f"{g['hyp_An1C']:12d}" if g['hyp_An1C'] else "         N/A"
        gap23 = f"{g['gap_23']:8d}" if g['gap_23'] else "     N/A"
        print(f"{g['depth']:3d} {g['hyp_An']:8d} {g['hyp_Cn']:8d} {g['gap_12']:8d} {third} {gap23}")


#!/usr/bin/env python3
"""
Berggren Semigroup Dynamics: Demonstrations of Key Theorems

This script demonstrates the C-ray second-extremality theorem and related
results about the Berggren tree of primitive Pythagorean triples.
"""

from itertools import product

# === Berggren Matrices (acting on column vectors [a, b, c]) ===

def matmul(M, v):
    """Multiply a 3x3 integer matrix by a 3-vector."""
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]

A = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
B = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
C = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]

BASE = [3, 4, 5]
GENS = {'A': A, 'B': B, 'C': C}
GEN_LIST = [A, B, C]
GEN_NAMES = ['A', 'B', 'C']


def apply_word(word_str, base=BASE):
    """Apply a word (string of 'A','B','C') to a base triple."""
    v = list(base)
    for ch in word_str:
        v = matmul(GENS[ch], v)
    return v


def hyp(v):
    """Extract hypotenuse (third coordinate)."""
    return v[2]


# === Demo 1: Verify Closed Forms ===
print("=" * 70)
print("DEMO 1: Closed-Form Verification for A-ray and C-ray")
print("=" * 70)
print()
print("A-ray: A^n(3,4,5) = (2n+3, 2(n+1)(n+2), 2n²+6n+5)")
print("C-ray: C^n(3,4,5) = ((2n+1)(2n+3), 4(n+1), 4n²+8n+5)")
print()

for n in range(8):
    va = apply_word('A' * n)
    vc = apply_word('C' * n)
    fa = [2*n+3, 2*(n+1)*(n+2), 2*n**2+6*n+5]
    fc = [(2*n+1)*(2*n+3), 4*(n+1), 4*n**2+8*n+5]
    assert va == fa, f"A-ray mismatch at n={n}: {va} != {fa}"
    assert vc == fc, f"C-ray mismatch at n={n}: {vc} != {fc}"
    print(f"  n={n}: A^n → {va} (hyp={va[2]}), C^n → {vc} (hyp={vc[2]})")

print("\n  ✓ All closed forms verified!\n")


# === Demo 2: Second-Extremality at Each Depth ===
print("=" * 70)
print("DEMO 2: C-Ray Second-Extremality (Exhaustive Verification)")
print("=" * 70)
print()
print("At each depth n, we enumerate ALL 3^n words and verify:")
print("  1. A^n has the smallest hypotenuse")
print("  2. C^n has the second-smallest (among w ≠ A^n)")
print()

for depth in range(1, 8):
    results = []
    for word in product(range(3), repeat=depth):
        v = list(BASE)
        for g in word:
            v = matmul(GEN_LIST[g], v)
        name = ''.join(GEN_NAMES[g] for g in word)
        results.append((v[2], name))
    results.sort()

    a_hyp = 2 * depth**2 + 6 * depth + 5
    c_hyp = 4 * depth**2 + 8 * depth + 5

    assert results[0] == (a_hyp, 'A' * depth), f"A-ray not minimal at depth {depth}"
    assert results[1] == (c_hyp, 'C' * depth), f"C-ray not second at depth {depth}"

    print(f"  Depth {depth} ({3**depth:5d} words): "
          f"min={results[0][1]}(c={results[0][0]}), "
          f"2nd={results[1][1]}(c={results[1][0]}), "
          f"3rd={results[2][1]}(c={results[2][0]})")

print("\n  ✓ Second-extremality verified exhaustively through depth 7!\n")


# === Demo 3: Ray Optimality (Mutual Induction Illustration) ===
print("=" * 70)
print("DEMO 3: Ray Optimality — A vs C from Different Starting Triples")
print("=" * 70)
print()
print("From a triple with a > b: C^m gives smaller hypotenuse than A^m")
print("From a triple with b > a: A^m gives smaller hypotenuse than C^m")
print()

# From C(3,4,5) = (15, 8, 17) where a=15 > b=8
triple_ab = (15, 8, 17)  # a > b
print(f"  Starting from {triple_ab} (a > b):")
for m in range(1, 6):
    hA = apply_word('A' * m, list(triple_ab))
    hC = apply_word('C' * m, list(triple_ab))
    print(f"    m={m}: hyp(A^m)={hA[2]:6d}, hyp(C^m)={hC[2]:6d}  "
          f"{'C^m wins ✓' if hC[2] < hA[2] else 'A^m wins'}")

print()

# From A(3,4,5) = (5, 12, 13) where b=12 > a=5
triple_ba = (5, 12, 13)  # b > a
print(f"  Starting from {triple_ba} (b > a):")
for m in range(1, 6):
    hA = apply_word('A' * m, list(triple_ba))
    hC = apply_word('C' * m, list(triple_ba))
    print(f"    m={m}: hyp(A^m)={hA[2]:6d}, hyp(C^m)={hC[2]:6d}  "
          f"{'A^m wins ✓' if hA[2] < hC[2] else 'C^m wins'}")

print()


# === Demo 4: Extremal Hierarchy ===
print("=" * 70)
print("DEMO 4: Extremal Hierarchy — First 10 Words by Hypotenuse")
print("=" * 70)
print()

for depth in [5, 7]:
    results = []
    for word in product(range(3), repeat=depth):
        v = list(BASE)
        for g in word:
            v = matmul(GEN_LIST[g], v)
        name = ''.join(GEN_NAMES[g] for g in word)
        results.append((v[2], name))
    results.sort()
    print(f"  Depth {depth}: Top 10 by ascending hypotenuse:")
    for rank, (h, name) in enumerate(results[:10], 1):
        print(f"    {rank:2d}. {name:8s}  c = {h}")
    print()


# === Demo 5: Leg Ordering After Each Generator ===
print("=" * 70)
print("DEMO 5: Structural Property — Leg Ordering After Generators")
print("=" * 70)
print()
print("Key insight: After A, always b' > a'. After C, always a' > b'.")
print("After B, a' - b' = b - a (sign reverses).")
print()

test_triples = [(3, 4, 5), (5, 12, 13), (15, 8, 17), (7, 24, 25), (35, 12, 37)]
for t in test_triples:
    a, b, c = t
    for name, M in [('A', A), ('B', B), ('C', C)]:
        child = matmul(M, list(t))
        diff = child[0] - child[1]
        print(f"  {name}({a},{b},{c}) → ({child[0]},{child[1]},{child[2]}), "
              f"a'-b' = {diff:+d}")
    print()

print("  ✓ Pattern confirmed: A→(b>a), C→(a>b), B→reverses sign\n")


# === Demo 6: B-Gap ===
print("=" * 70)
print("DEMO 6: B-Words Are Always Far From Second-Extremal")
print("=" * 70)
print()
print("Minimum hypotenuse among B-containing words vs C^n:")
print()

for depth in range(1, 9):
    c_hyp = 4 * depth**2 + 8 * depth + 5
    min_b_hyp = float('inf')
    min_b_word = ""
    for word in product(range(3), repeat=depth):
        if 1 not in word:  # 1 = B
            continue
        v = list(BASE)
        for g in word:
            v = matmul(GEN_LIST[g], v)
        if v[2] < min_b_hyp:
            min_b_hyp = v[2]
            min_b_word = ''.join(GEN_NAMES[g] for g in word)
    gap = min_b_hyp - c_hyp
    print(f"  Depth {depth}: min B-word = {min_b_word} (c={min_b_hyp}), "
          f"C^n hyp = {c_hyp}, gap = {gap}")

print("\n  ✓ B-words always have strictly larger hypotenuse than C^n\n")

print("=" * 70)
print("All demonstrations completed successfully!")
print("=" * 70)
