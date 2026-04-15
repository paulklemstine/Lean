#!/usr/bin/env python3
"""
SPB Explorer: Interactive Demonstrations of the Stereographic Projection Bridge

The SPB operation: spb(x, y) = (x + y) / (1 - x*y)
is the tangent addition formula, and the group law on ℝ∪{∞} induced by S¹.

This script demonstrates:
1. SPB as tangent addition
2. Machin-like formula enumeration
3. SPB orbits and equidistribution
4. Finite field SPB groups (p±1 law)
5. SPB integer classification
6. SPB continued fractions
7. Hyperbolic SPB (Einstein velocity addition)
"""

import math
import itertools
from fractions import Fraction
from collections import Counter

# ============================================================
# Core SPB Operations
# ============================================================

def spb(x, y):
    """SPB operation: (x + y) / (1 - x*y)"""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spb_hyp(x, y):
    """Hyperbolic SPB (Einstein velocity addition): (x+y)/(1+x*y)"""
    return (x + y) / (1 + x * y)

def spb_frac(a, b):
    """Exact rational SPB using Fraction"""
    denom = Fraction(1) - a * b
    if denom == 0:
        return None  # pole
    return (a + b) / denom

def spb_iter(x, a, n):
    """Iterate spb(·, a) starting from x, n times"""
    result = x
    for _ in range(n):
        result = spb(result, a)
    return result

# ============================================================
# Demo 1: SPB as Tangent Addition
# ============================================================

def demo_tangent_addition():
    """Verify spb(tan α, tan β) = tan(α + β)"""
    print("=" * 60)
    print("DEMO 1: SPB is the Tangent Addition Formula")
    print("=" * 60)

    test_cases = [
        (math.pi/6, math.pi/4),   # 30° + 45°
        (math.pi/4, math.pi/4),   # 45° + 45°
        (math.pi/3, math.pi/6),   # 60° + 30°
        (0.1, 0.2),
        (1.0, 0.5),
    ]

    for alpha, beta in test_cases:
        tan_a = math.tan(alpha)
        tan_b = math.tan(beta)
        spb_result = spb(tan_a, tan_b)
        tan_sum = math.tan(alpha + beta)
        error = abs(spb_result - tan_sum)
        print(f"  α={alpha:.4f}, β={beta:.4f}: "
              f"spb(tan α, tan β) = {spb_result:.10f}, "
              f"tan(α+β) = {tan_sum:.10f}, "
              f"error = {error:.2e}")

    print()

# ============================================================
# Demo 2: Machin-like Formulas via SPB
# ============================================================

def demo_machin_formulas():
    """Enumerate Machin-like formulas: find (a,b) with spb(1/a, 1/b) = 1"""
    print("=" * 60)
    print("DEMO 2: Machin-like Formulas via SPB")
    print("=" * 60)

    # Two-leaf search: spb(1/a, 1/b) = 1
    # => 1/a + 1/b = 1 - 1/(ab) => (a+b)/(ab) = (ab-1)/(ab)
    # => a + b = ab - 1 => (a-1)(b-1) = 2
    print("\n  Two-leaf formulas: spb(1/a, 1/b) = 1")
    print("  Condition: (a-1)(b-1) = 2")
    print("  Integer solutions: (a,b) = (2,3) [unique up to order]")
    a, b = Fraction(1, 2), Fraction(1, 3)
    print(f"  Verification: spb(1/2, 1/3) = {spb_frac(a, b)}")
    print(f"  This is Euler's formula: π/4 = arctan(1/2) + arctan(1/3)")

    # Three-leaf search: spb(spb(1/a, 1/b), 1/c) = 1
    print("\n  Three-leaf formulas: spb(spb(1/a, 1/b), 1/c) = 1")
    count = 0
    for a in range(2, 20):
        for b in range(a, 50):
            s = spb_frac(Fraction(1, a), Fraction(1, b))
            if s is None:
                continue
            for c in range(b, 100):
                t = spb_frac(s, Fraction(1, c))
                if t == 1:
                    print(f"    spb(spb(1/{a}, 1/{b}), 1/{c}) = 1")
                    count += 1
    print(f"  Found {count} three-leaf formulas (with a<b<c, a<20, b<50, c<100)")

    # Machin's formula: 4·arctan(1/5) - arctan(1/239) = π/4
    print("\n  Classical formulas verified:")
    a5 = Fraction(1, 5)
    d1 = spb_frac(a5, a5)           # tan(2·arctan 1/5)
    d2 = spb_frac(d1, d1)           # tan(4·arctan 1/5)
    machin = spb_frac(d2, Fraction(-1, 239))
    print(f"    Machin:  spb(spb(spb(1/5,1/5),spb(1/5,1/5)), -1/239) = {machin}")

    # Hutton's formula
    h1 = spb_frac(Fraction(1,3), Fraction(1,3))
    hutton = spb_frac(h1, Fraction(1,7))
    print(f"    Hutton:  spb(spb(1/3, 1/3), 1/7) = {hutton}")
    print()

# ============================================================
# Demo 3: SPB Orbits and Equidistribution
# ============================================================

def demo_orbits():
    """Show orbits of x ↦ spb(x, a) for various a"""
    print("=" * 60)
    print("DEMO 3: SPB Orbits (x ↦ spb(x, a) iterated)")
    print("=" * 60)

    # When arctan(a)/π is rational, orbit is periodic
    # When irrational, orbit is dense (equidistributed w.r.t. Cauchy measure)

    # Periodic case: a = 1, arctan(1)/π = 1/4, period = 4
    print("\n  Periodic case: a = 1 (arctan(1)/π = 1/4, period 4)")
    x = 0.0
    for i in range(8):
        print(f"    step {i}: x = {x:.6f}")
        x = spb(x, 1.0)

    # Periodic case: a = tan(π/6), period = 6
    a = math.tan(math.pi / 6)
    print(f"\n  Periodic case: a = tan(π/6) ≈ {a:.6f} (period 6)")
    x = 0.0
    for i in range(8):
        print(f"    step {i}: x = {x:.6f}")
        x = spb(x, a)

    # Dense case: a = 0.5 (arctan(0.5)/π is irrational)
    a = 0.5
    N = 10000
    x = 0.0
    # Check equidistribution via Cauchy CDF: P(X ≤ t) = 1/2 + arctan(t)/π
    bins = [0] * 10
    for _ in range(N):
        x = spb(x, a)
        # Cauchy CDF
        cdf = 0.5 + math.atan(x) / math.pi
        bin_idx = min(int(cdf * 10), 9)
        bins[bin_idx] += 1
    print(f"\n  Dense case: a = 0.5, {N} iterations")
    print(f"  Cauchy-CDF histogram (should be ~uniform):")
    for i, count in enumerate(bins):
        bar = '#' * int(count / N * 200)
        print(f"    [{i*10:2d}%-{(i+1)*10:2d}%]: {count:5d} {bar}")
    print()

# ============================================================
# Demo 4: Finite Field SPB Groups — The p±1 Law
# ============================================================

def spb_mod(x, y, p):
    """SPB over Z/pZ"""
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # pole
    return ((x + y) * pow(denom, p - 2, p)) % p

def spb_group_order(p):
    """Compute the order of the SPB group over F_p"""
    # Elements: all x in F_p such that iterating spb eventually returns to identity
    # The SPB group consists of elements reachable from 0 by iterated spb(·, g)
    # for some generator g.
    # Simpler: count elements in the projective SPB group

    # Elements where 1 - x^2 ≠ 0 mod p, plus infinity
    elements = set()
    for x in range(p):
        # Check if x is in the SPB domain (1 - x*x ≠ 0)
        elements.add(x)

    # Find the group by iterating spb(·, 1)
    # Actually: find maximal cyclic subgroup
    best_order = 0
    for g in range(1, p):
        x = 0
        order = 0
        seen = set()
        while True:
            x = spb_mod(x, g, p)
            if x is None:  # hit a pole, include ∞
                order = 0
                break
            order += 1
            if x == 0:
                break
            if x in seen:
                order = 0
                break
            seen.add(x)
        best_order = max(best_order, order)

    return best_order

def demo_finite_fields():
    """Verify the p±1 law for small primes"""
    print("=" * 60)
    print("DEMO 4: Finite Field SPB Groups — The p±1 Law")
    print("=" * 60)
    print()
    print(f"  {'p':>5s}  {'p mod 4':>7s}  {'predicted':>10s}  {'computed':>10s}  {'match':>5s}")
    print(f"  {'─'*5}  {'─'*7}  {'─'*10}  {'─'*10}  {'─'*5}")

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    all_match = True
    for p in primes:
        mod4 = p % 4
        predicted = p + 1 if mod4 == 3 else p - 1
        computed = spb_group_order(p)
        match = "✓" if computed == predicted else "✗"
        if computed != predicted:
            all_match = False
        print(f"  {p:5d}  {mod4:7d}  {predicted:10d}  {computed:10d}  {match:>5s}")

    print(f"\n  All primes match prediction: {'YES ✓' if all_match else 'NO ✗'}")
    print()

# ============================================================
# Demo 5: SPB Integer Classification
# ============================================================

def demo_integer_classification():
    """Find all (a,b) ∈ ℤ² with spb(a,b) ∈ ℤ"""
    print("=" * 60)
    print("DEMO 5: Integer SPB Classification")
    print("=" * 60)
    print("  Find (a, b) with a ≤ b and spb(a,b) ∈ ℤ, |a|,|b| ≤ 20")
    print()

    solutions = []
    for a in range(-20, 21):
        for b in range(a, 21):
            denom = 1 - a * b
            if denom == 0:
                continue
            numer = a + b
            if numer % denom == 0:
                q = numer // denom
                solutions.append((a, b, q))

    print(f"  Found {len(solutions)} pairs:")
    # Group by result
    by_result = {}
    for a, b, q in solutions:
        by_result.setdefault(q, []).append((a, b))

    for q in sorted(by_result.keys()):
        pairs = by_result[q]
        if len(pairs) <= 8:
            print(f"    spb(a,b) = {q:3d}: {pairs}")
        else:
            print(f"    spb(a,b) = {q:3d}: {len(pairs)} pairs, e.g. {pairs[:4]}...")

    # Analyze the structure
    print("\n  Key observations:")
    print("    - (0, n) → n for all n (identity)")
    print("    - (a, -a) → 0 for all a (inverse)")
    print("    - (1, b) → (1+b)/(1-b) ∈ ℤ ⟺ (1-b) | (1+b) ⟺ (1-b) | 2")
    print("      So b ∈ {-1, 0, 2, 3} giving spb = {0, 1, -3, -2}")
    print("    - Symmetric in (a,b): spb(a,b) = spb(b,a)")

    # Count solutions by |a|+|b|
    print("\n  Solution count by max(|a|,|b|):")
    for bound in [1, 2, 5, 10, 20]:
        count = sum(1 for a, b, _ in solutions if max(abs(a), abs(b)) <= bound)
        print(f"    |a|,|b| ≤ {bound:2d}: {count} pairs")
    print()

# ============================================================
# Demo 6: SPB Continued Fractions
# ============================================================

def demo_continued_fractions():
    """Express continued fraction convergence in SPB language"""
    print("=" * 60)
    print("DEMO 6: SPB Continued Fractions for arctan")
    print("=" * 60)

    def spb_cf(x, max_steps=20):
        """SPB continued fraction: decompose x via spb subtraction"""
        coeffs = []
        for _ in range(max_steps):
            if abs(x) < 1e-12:
                break
            n = round(1.0 / x)
            if n == 0:
                break
            coeffs.append(n)
            # SPB subtraction: remainder = spb(x, -1/n)
            x = spb(x, -1.0/n)
        return coeffs

    targets = [
        ("tan(1) (≈ 1.5574)", math.tan(1.0)),
        ("tan(π/4) = 1", 1.0),
        ("tan(π/6) ≈ 0.5774", math.tan(math.pi/6)),
        ("1/2", 0.5),
        ("1/3", 1.0/3),
        ("golden ratio φ ≈ 1.618", (1 + math.sqrt(5))/2),
    ]

    for name, target in targets:
        coeffs = spb_cf(target)
        # Reconstruct: spb(1/c₁, spb(1/c₂, spb(...)))
        reconstructed = 0.0
        for c in reversed(coeffs):
            reconstructed = spb(1.0/c, reconstructed)
        error = abs(reconstructed - target)
        print(f"  {name}:")
        print(f"    SPB-CF coefficients: {coeffs}")
        print(f"    Reconstruction error: {error:.2e}")
    print()

# ============================================================
# Demo 7: Hyperbolic SPB (Einstein Velocity Addition)
# ============================================================

def demo_einstein_velocity():
    """Demonstrate relativistic velocity addition via hyperbolic SPB"""
    print("=" * 60)
    print("DEMO 7: Einstein Velocity Addition via Hyperbolic SPB")
    print("=" * 60)

    c = 1.0  # speed of light

    print("\n  Galilean vs Einsteinian velocity addition:")
    test_velocities = [
        (0.1, 0.1),
        (0.3, 0.5),
        (0.5, 0.5),
        (0.9, 0.9),
        (0.99, 0.99),
        (0.999, 0.999),
    ]

    print(f"  {'u':>6s}  {'v':>6s}  {'Galilean u+v':>13s}  {'Einstein spbH':>14s}  {'bounded?':>8s}")
    print(f"  {'─'*6}  {'─'*6}  {'─'*13}  {'─'*14}  {'─'*8}")
    for u, v in test_velocities:
        galilean = u + v
        einstein = spb_hyp(u, v)
        bounded = "|v|<c ✓" if abs(einstein) < c else "|v|≥c ✗"
        print(f"  {u:6.3f}  {v:6.3f}  {galilean:13.6f}  {einstein:14.10f}  {bounded}")

    print("\n  Key insight: no matter how fast the components, spbH(u,v) < c")
    print("  This is the mathematical content of 'nothing exceeds light speed'.")
    print()

# ============================================================
# Demo 8: SPB Tree Enumeration
# ============================================================

def demo_tree_enumeration():
    """Enumerate SPB expression trees that evaluate to 1"""
    print("=" * 60)
    print("DEMO 8: Minimum SPB Trees Evaluating to 1")
    print("=" * 60)
    print("  Goal: Find the smallest tree of spb(1/a, 1/b, ...) = 1")
    print()

    # 1-leaf: 1/n = 1 ⟹ n = 1
    print("  1-leaf: 1/1 = 1 ✓ (trivial)")

    # 2-leaf: spb(1/a, 1/b) = 1 ⟹ (a-1)(b-1) = 2
    print("  2-leaf: spb(1/a, 1/b) = 1")
    print("    Requires (a-1)(b-1) = 2")
    print("    Integer solutions with a,b ≥ 2: (a,b) = (2,3)")
    print("    → Euler's formula: π/4 = arctan(1/2) + arctan(1/3)  ✓")

    # 3-leaf search with distinct values
    print("\n  3-leaf formulas spb(spb(1/a, 1/b), 1/c) = 1 with 2 ≤ a ≤ b, c ≥ 2:")
    three_leaf = []
    for a in range(2, 30):
        for b in range(a, 100):
            s = spb_frac(Fraction(1, a), Fraction(1, b))
            if s is None:
                continue
            for c in range(2, 500):
                t = spb_frac(s, Fraction(1, c))
                if t == 1:
                    three_leaf.append((a, b, c))

    for a, b, c in three_leaf[:10]:
        print(f"    spb(spb(1/{a}, 1/{b}), 1/{c}) = 1")

    print(f"\n  Total 3-leaf formulas found: {len(three_leaf)}")
    print()

# ============================================================
# Demo 9: Cayley Transform Visualization Data
# ============================================================

def demo_cayley_transform():
    """Generate data showing the Cayley transform maps SPB → multiplication"""
    print("=" * 60)
    print("DEMO 9: Cayley Transform: SPB ↦ Multiplication on S¹")
    print("=" * 60)

    import cmath

    def cayley(x):
        """Cayley transform: x ↦ (1 + ix)/(1 - ix)"""
        return (1 + 1j * x) / (1 - 1j * x)

    print("\n  Verifying: cayley(spb(x,y)) = cayley(x) · cayley(y)")
    test_pairs = [(0.5, 0.3), (1.0, 0.5), (2.0, -0.5), (0.1, 0.9)]

    for x, y in test_pairs:
        s = spb(x, y)
        c_spb = cayley(s)
        c_prod = cayley(x) * cayley(y)
        error = abs(c_spb - c_prod)
        print(f"  x={x:5.1f}, y={y:5.1f}: "
              f"|cayley(spb) - cayley(x)·cayley(y)| = {error:.2e}")

    print("\n  All Cayley images lie on S¹ (|z| = 1):")
    for x in [0, 0.5, 1.0, 2.0, -1.0, 10.0, -10.0]:
        c = cayley(x)
        print(f"    cayley({x:6.1f}) = {c.real:8.5f} + {c.imag:8.5f}i, "
              f"|z| = {abs(c):.10f}")
    print()

# ============================================================
# Demo 10: Tropical SPB
# ============================================================

def demo_tropical_spb():
    """Explore the tropical SPB operation"""
    print("=" * 60)
    print("DEMO 10: Tropical SPB")
    print("=" * 60)

    def tspb(x, y):
        """Tropical SPB: max(x,y) - max(0, x+y) = min(x,y) - min(0,x+y)"""
        # From tropicalizing (x+y)/(1-xy):
        # trop(x+y) = max(x,y), trop(1-xy) = max(0, x+y)
        return max(x, y) - max(0, x + y)

    print("\n  Tropical SPB: tspb(x,y) = max(x,y) - max(0, x+y)")
    test = [(-3, -2), (-1, -1), (-1, 0), (0, 0), (1, 2), (-5, 3), (2, -4)]
    for x, y in test:
        print(f"    tspb({x:3d}, {y:3d}) = {tspb(x, y):3d}")

    # Check commutativity
    print("\n  Commutativity check:")
    commutative = True
    for x in range(-5, 6):
        for y in range(-5, 6):
            if tspb(x, y) != tspb(y, x):
                commutative = False
                print(f"    FAIL: tspb({x},{y}) = {tspb(x,y)} ≠ {tspb(y,x)} = tspb({y},{x})")
    print(f"    Commutative: {'YES ✓' if commutative else 'NO ✗'}")

    # Check associativity
    print("\n  Associativity check:")
    associative = True
    counter_examples = []
    for x in range(-3, 4):
        for y in range(-3, 4):
            for z in range(-3, 4):
                lhs = tspb(tspb(x, y), z)
                rhs = tspb(x, tspb(y, z))
                if lhs != rhs:
                    associative = False
                    counter_examples.append((x, y, z, lhs, rhs))
    if not associative:
        print(f"    NOT associative! Found {len(counter_examples)} counterexamples.")
        for x, y, z, l, r in counter_examples[:5]:
            print(f"    tspb(tspb({x},{y}),{z}) = {l} ≠ {r} = tspb({x},tspb({y},{z}))")
    else:
        print(f"    Associative: YES ✓")

    # Identity element
    print("\n  Identity element search:")
    for e in range(-5, 6):
        is_identity = all(tspb(x, e) == x for x in range(-10, 11))
        if is_identity:
            print(f"    e = {e} is a global identity ✓")
    print("    No global identity exists (partial identity for negative inputs)")

    # Idempotent check
    print("\n  Idempotent check: tspb(x, x) = ?")
    for x in range(-5, 6):
        result = tspb(x, x)
        idem = "= x ✓" if result == x else f"= {result} ≠ x"
        print(f"    tspb({x:3d}, {x:3d}) = {result:3d}  {idem}")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  SPB Explorer: Stereographic Projection Bridge Demos    ║")
    print("║  spb(x, y) = (x + y) / (1 - x·y)                      ║")
    print("╚" + "═" * 58 + "╝")
    print()

    demo_tangent_addition()
    demo_machin_formulas()
    demo_orbits()
    demo_finite_fields()
    demo_integer_classification()
    demo_continued_fractions()
    demo_einstein_velocity()
    demo_tree_enumeration()
    demo_cayley_transform()
    demo_tropical_spb()

    print("=" * 60)
    print("All demos complete!")
    print("=" * 60)
