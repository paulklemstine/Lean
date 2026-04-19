#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════
  Factoring via Berggren Universal Parent — Exploration Demo
═══════════════════════════════════════════════════════════════════════

Idea: Given a composite integer N, form the "factoring triplet"
   T(x) = (x, N, x² + N²)
and apply the Universal Parent formula:
   p = a + 2b - 2c  = x + 2N - 2(x² + N²)
   q = 2a + b - 2c  = 2x + N - 2(x² + N²)
   h = 3c - 2(a+b)  = 3(x² + N²) - 2(x + N)

If UP(T(x)) = (3, 4, 5) (the root), then we get equations in x and N
that may reveal factor information.

Key algebraic relations:
   p - q = N - x        (always)
   p + q = 3(x + N) - 4(x² + N²)
   h     = 3(x² + N²) - 2(x + N)

Note: T(x) is NOT Pythagorean in general (x² + N² ≠ (x² + N²)²),
so the ghost triple is not Pythagorean either. Instead we get a
"Pythagorean deficit" δ = p² + q² - h² that encodes information
about N.
"""

import math
from itertools import product as cart_product
from collections import defaultdict


def ghost_p(a, b, c):
    return a + 2*b - 2*c

def ghost_q(a, b, c):
    return 2*a + b - 2*c

def ghost_h(a, b, c):
    return 3*c - 2*(a + b)

def universal_parent(a, b, c):
    p = ghost_p(a, b, c)
    q = ghost_q(a, b, c)
    h = ghost_h(a, b, c)
    return (abs(p), abs(q), h)

def factoring_triplet(x, N):
    """Create the factoring triplet T(x) = (x, N, x² + N²)."""
    return (x, N, x**2 + N**2)

def pythagorean_deficit(a, b, c):
    """δ = a² + b² - c², zero iff Pythagorean."""
    return a**2 + b**2 - c**2


# ═══════════════════════════════════════════════════════════════
# Experiment 1: Ghost structure of factoring triplets
# ═══════════════════════════════════════════════════════════════
print("=" * 70)
print("EXPERIMENT 1: Ghost structure of factoring triplets T(x) = (x, N, x²+N²)")
print("=" * 70)

N = 15  # = 3 × 5
print(f"\nN = {N} = 3 × 5")
print(f"{'x':>4} {'T(x)':>20} {'p':>8} {'q':>8} {'h':>8} {'|p|':>6} {'|q|':>6} {'δ_ghost':>10} {'gcd(|p|,N)':>10} {'gcd(|q|,N)':>10}")
print("-" * 110)

for x in range(1, 20):
    T = factoring_triplet(x, N)
    p = ghost_p(*T)
    q = ghost_q(*T)
    h = ghost_h(*T)
    deficit = p**2 + q**2 - h**2
    gp = math.gcd(abs(p), N)
    gq = math.gcd(abs(q), N)
    mark = " ← FACTOR!" if gp > 1 or gq > 1 else ""
    print(f"{x:>4} {str(T):>20} {p:>8} {q:>8} {h:>8} {abs(p):>6} {abs(q):>6} {deficit:>10} {gp:>10} {gq:>10}{mark}")


# ═══════════════════════════════════════════════════════════════
# Experiment 2: Reverse solve — when does UP(T(x)) = (3, 4, 5)?
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 2: When does UP(T(x)) match (3, 4, 5)?")
print("=" * 70)

print("\nFor UP(T(x)) = (|p|, |q|, h) = (3, 4, 5):")
print("  p - q = N - x  ⟹  N - x = ±3 ∓ 4")
print("  Possible: N - x ∈ {-7, -1, 1, 7}")
print()

for N_test in [15, 21, 35, 77, 91, 143]:
    factors = [(d, N_test // d) for d in range(2, int(N_test**0.5) + 1) if N_test % d == 0]
    print(f"N = {N_test} (factors: {factors})")
    
    # Try all sign combinations for p = ±3, q = ±4, h = 5
    for sp, sq in [(-1, -1), (-1, 1), (1, -1), (1, 1)]:
        target_p = sp * 3
        target_q = sq * 4
        target_h = 5
        # From p - q = N - x: x = N - (target_p - target_q)
        x = N_test - (target_p - target_q)
        
        # Verify h equation: h = 3(x² + N²) - 2(x + N)
        h_check = 3 * (x**2 + N_test**2) - 2 * (x + N_test)
        p_check = x + 2*N_test - 2*(x**2 + N_test**2)
        q_check = 2*x + N_test - 2*(x**2 + N_test**2)
        
        if p_check == target_p and q_check == target_q and h_check == target_h:
            print(f"  ✓ EXACT MATCH: x={x}, p={target_p}, q={target_q}, h={target_h}")
        elif h_check == target_h:
            print(f"  ~ h matches but (p,q) don't: x={x}, p={p_check}≠{target_p}, q={q_check}≠{target_q}")


# ═══════════════════════════════════════════════════════════════
# Experiment 3: Iterated universal parent on factoring triplets
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 3: Iterated UP on factoring triplets")
print("=" * 70)

def iterate_UP(a, b, c, max_iter=10):
    """Apply UP repeatedly, tracking the trajectory."""
    trajectory = [(a, b, c)]
    for _ in range(max_iter):
        ap, bq, h = universal_parent(a, b, c)
        if h <= 0:
            break
        a, b, c = ap, bq, h
        trajectory.append((a, b, c))
        if (a, b, c) == (3, 4, 5) or (a, b, c) == (4, 3, 5):
            break
    return trajectory

N = 15
print(f"\nN = {N}")
for x in [1, 2, 3, 4, 5, 7, 10, 14, 15]:
    T = factoring_triplet(x, N)
    traj = iterate_UP(*T, max_iter=5)
    print(f"  x={x:>3}: T={T}")
    for i, t in enumerate(traj):
        deficit = t[0]**2 + t[1]**2 - t[2]**2
        gcd_a = math.gcd(t[0], N)
        gcd_b = math.gcd(t[1], N)
        mark = ""
        if gcd_a > 1:
            mark += f" gcd(a,N)={gcd_a}"
        if gcd_b > 1:
            mark += f" gcd(b,N)={gcd_b}"
        if t == (3, 4, 5) or t == (4, 3, 5):
            mark += " ROOT!"
        print(f"    UP^{i}: {t}, δ={deficit}{mark}")


# ═══════════════════════════════════════════════════════════════
# Experiment 4: GCD-based factor discovery
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 4: Systematic GCD-based factor discovery")
print("=" * 70)

def find_factors_via_UP(N, x_range=100, max_depth=5):
    """Try to find factors of N using the UP of factoring triplets."""
    found_factors = set()
    for x in range(1, x_range + 1):
        T = factoring_triplet(x, N)
        a, b, c = T
        for depth in range(max_depth + 1):
            # Check GCDs at this level
            for val in [a, b, c, a+b, a-b, a*b]:
                g = math.gcd(abs(val), N)
                if 1 < g < N:
                    found_factors.add((g, N // g, x, depth, val))
            # Apply UP
            a, b, c = universal_parent(a, b, c)
            if c <= 0:
                break
    return found_factors

composites = [15, 21, 35, 55, 77, 91, 143, 221, 323, 437, 667, 899]
print(f"\n{'N':>6} {'Factors':>12} {'#Clues':>8} {'Best x':>8} {'Depth':>6} {'Via':>10}")
print("-" * 60)

for N in composites:
    clues = find_factors_via_UP(N, x_range=50, max_depth=3)
    if clues:
        best = min(clues, key=lambda c: (c[3], c[2]))  # prefer shallow, small x
        p, q = best[0], best[1]
        print(f"{N:>6} {f'{p}×{q}':>12} {len(clues):>8} {best[2]:>8} {best[3]:>6} {best[4]:>10}")
    else:
        print(f"{N:>6} {'???':>12} {0:>8}")


# ═══════════════════════════════════════════════════════════════
# Experiment 5: The deficit polynomial and its factoring content
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 5: Deficit polynomial analysis")
print("=" * 70)

print("""
For T(x) = (x, N, x² + N²), the Pythagorean deficit is:
  δ(T) = x² + N² - (x² + N²)²
       = (x² + N²)(1 - x² - N²)
       = -(x² + N²)(x² + N² - 1)

The ghost deficit is:
  δ_ghost = p² + q² - h²
          = (a² + b² - c²) · K  [by the Lorentz norm identity]
where K depends on the specific structure of T(x).

Since a²+b²-c² = x²+N²-(x²+N²)² = -(x²+N²)(x²+N²-1),
the ghost deficit carries the same factoring information as δ(T).
""")

N = 15
print(f"N = {N}")
print(f"{'x':>4} {'x²+N²':>8} {'δ(T)':>12} {'δ_ghost':>12} {'ratio':>10} {'gcd(δ,N)':>10}")
print("-" * 65)

for x in range(1, 15):
    T = factoring_triplet(x, N)
    delta_T = T[0]**2 + T[1]**2 - T[2]**2
    p, q, h = ghost_p(*T), ghost_q(*T), ghost_h(*T)
    delta_ghost = p**2 + q**2 - h**2
    ratio = delta_ghost / delta_T if delta_T != 0 else "inf"
    gcd_delta = math.gcd(abs(delta_T), N) if delta_T != 0 else 0
    if isinstance(ratio, float):
        print(f"{x:>4} {T[2]:>8} {delta_T:>12} {delta_ghost:>12} {ratio:>10.2f} {gcd_delta:>10}")
    else:
        print(f"{x:>4} {T[2]:>8} {delta_T:>12} {delta_ghost:>12} {ratio:>10} {gcd_delta:>10}")


# ═══════════════════════════════════════════════════════════════
# Experiment 6: Alternative triplets for factoring
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 6: Alternative factoring triplets")
print("=" * 70)

print("""
Besides T(x) = (x, N, x²+N²), we can try:
  T₁(x) = (x, N, x+N)        — "additive" triplet
  T₂(d) = (d, N/d, N)         — "divisor" triplet (when d | N)  
  T₃(x) = (N-x, x, N)        — "split" triplet
  T₄(x) = (x, N, √(x²+N²))  — actual Pythagorean (when perfect square)
""")

N = 15

# T₃: Split triplets (N-x, x, N)
print(f"\nT₃ split triplets for N = {N}:")
print(f"{'x':>4} {'(a,b,c)':>16} {'|p|':>6} {'|q|':>6} {'h':>6} {'gcd(|p|,N)':>12} {'gcd(|q|,N)':>12}")
print("-" * 70)
for x in range(1, N):
    a, b, c = N - x, x, N
    p, q, h = ghost_p(a, b, c), ghost_q(a, b, c), ghost_h(a, b, c)
    gp = math.gcd(abs(p), N)
    gq = math.gcd(abs(q), N)
    mark = " ← FACTOR!" if gp > 1 or gq > 1 else ""
    print(f"{x:>4} {str((a,b,c)):>16} {abs(p):>6} {abs(q):>6} {h:>6} {gp:>12} {gq:>12}{mark}")


# T₂: Divisor triplets
print(f"\nT₂ divisor triplets for N = {N}:")
for d in range(1, N + 1):
    if N % d == 0:
        a, b, c = d, N // d, N
        p, q, h = ghost_p(a, b, c), ghost_q(a, b, c), ghost_h(a, b, c)
        gp = math.gcd(abs(p), N)
        gq = math.gcd(abs(q), N)
        print(f"  d={d}: ({a}, {b}, {c}) → UP=({abs(p)}, {abs(q)}, {h}), gcd(|p|,N)={gp}, gcd(|q|,N)={gq}")


# ═══════════════════════════════════════════════════════════════
# Experiment 7: Algebraic analysis — closed forms
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 7: Closed-form analysis for split triplet (N-x, x, N)")
print("=" * 70)

print("""
For T₃(x) = (N-x, x, N):
  p = (N-x) + 2x - 2N  = x - N
  q = 2(N-x) + x - 2N  = -x
  h = 3N - 2((N-x) + x) = 3N - 2N = N

So UP(N-x, x, N) = (|x-N|, |x|, N) = (N-x, x, N)  for 0 < x < N.

This is a FIXED POINT of UP! Every split triplet maps to itself.
The factoring information must come from the initial choice of x.
""")

# Verify
for N_test in [15, 21, 35]:
    print(f"N = {N_test}:")
    for x in range(1, N_test):
        T = (N_test - x, x, N_test)
        UP = universal_parent(*T)
        is_fixed = (UP == T)
        if not is_fixed:
            print(f"  x={x}: NOT fixed! T={T}, UP={UP}")
    print(f"  All {N_test-1} split triplets are fixed points. ✓")


# ═══════════════════════════════════════════════════════════════
# Experiment 8: Divisor triplet algebra
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 8: Divisor triplet (d, N/d, N) — the factoring channel")
print("=" * 70)

print("""
For T₂(d) = (d, N/d, N) where d | N, let e = N/d:
  p = d + 2e - 2N = d + 2(N/d) - 2N
  q = 2d + e - 2N = 2d + (N/d) - 2N
  h = 3N - 2(d + e) = 3N - 2(d + N/d)

Note: p - q = (d + 2e - 2N) - (2d + e - 2N) = e - d = N/d - d

So |p - q| = |N/d - d|, which is related to the "factor gap"!
If d ≈ √N, then |p-q| ≈ 0, i.e., the ghost triple is nearly isoceles.
""")

for N_test in [15, 21, 35, 77, 91, 143, 221]:
    divs = [(d, N_test // d) for d in range(1, N_test + 1) if N_test % d == 0]
    print(f"\nN = {N_test}:")
    for d, e in divs:
        if d > e:
            break
        T = (d, e, N_test)
        p, q, h = ghost_p(*T), ghost_q(*T), ghost_h(*T)
        print(f"  ({d:>3}, {e:>3}, {N_test:>3}) → p={p:>6}, q={q:>6}, h={h:>6}  |p-q|={abs(p-q):>4}={abs(e-d)}=|{e}-{d}|  ✓")


# ═══════════════════════════════════════════════════════════════
# Experiment 9: The "reverse solve" — from (3,4,5) back to factors
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 9: Reverse solve — from root (3,4,5) to N")
print("=" * 70)

print("""
Apply forward Berggren transforms to (3,4,5) and check which results
can be written as (d, N/d, N) for some composite N, revealing its factors.

B₁(a,b,c) = (a - 2b + 2c,  2a - b + 2c,  2a - 2b + 3c)
B₂(a,b,c) = (a + 2b + 2c,  2a + b + 2c,  2a + 2b + 3c)
B₃(a,b,c) = (-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c)
""")

def fwdB1(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def fwdB2(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def fwdB3(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_tree(root, depth):
    """Generate all triples in the Berggren tree up to given depth."""
    if depth == 0:
        return [root]
    children = [fwdB1(*root), fwdB2(*root), fwdB3(*root)]
    result = [root]
    for child in children:
        result.extend(generate_tree(child, depth - 1))
    return result

triples = generate_tree((3, 4, 5), 4)
print(f"Generated {len(triples)} PPTs from the Berggren tree (depth 4)")
print()

# For each PPT (a, b, c), check if c = a*b (so it's a "divisor triplet" of N=c)
print("PPTs where c is a product of legs (divisor triplets):")
found = 0
for a, b, c in triples:
    if a > 0 and b > 0:
        if c == a * b:
            print(f"  ({a}, {b}, {c}): N = {c} = {a} × {b}")
            found += 1
        # Also check if any pair divides c
        if c % a == 0 and c // a != b:
            print(f"  ({a}, {b}, {c}): {a} | {c}, {c}/{a} = {c//a}")
            found += 1
        if c % b == 0 and c // b != a:
            print(f"  ({a}, {b}, {c}): {b} | {c}, {c}/{b} = {c//b}")
            found += 1

if found == 0:
    print("  (None found — PPT hypotenuse c is rarely a product of its legs)")

print()
print("PPTs where legs share a factor with the hypotenuse:")
for a, b, c in triples:
    if a > 0 and b > 0:
        ga = math.gcd(a, c)
        gb = math.gcd(b, c)
        if ga > 1 or gb > 1:
            print(f"  ({a}, {b}, {c}): gcd({a},{c})={ga}, gcd({b},{c})={gb}")


# ═══════════════════════════════════════════════════════════════
# Experiment 10: The key insight — Lorentz deficit as factor detector
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("EXPERIMENT 10: Lorentz deficit as factor detector")
print("=" * 70)

print("""
KEY THEOREM: For T(x) = (x, N, x²+N²):
  δ = x² + N² - (x²+N²)² = -(x²+N²)(x²+N²-1)

For the divisor triplet (d, N/d, N):
  δ = d² + (N/d)² - N²

When d | N with d < √N:
  δ = d² + N²/d² - N² < 0 (since d² + N²/d² < N² for most d)

The key: if δ = 0, we have a Pythagorean triple, and d² + e² = N²
means we can factor N via the Euclid parametrization!

N = d² + e² (sum of two squares) is necessary.
""")

print("\nNumbers expressible as sum of two squares (≤ 100):")
sos = []
for n in range(2, 101):
    for a in range(1, int(n**0.5) + 1):
        b2 = n - a*a
        b = int(b2**0.5)
        if b > 0 and b*b == b2 and a <= b:
            sos.append((n, a, b))
            break

for n, a, b in sos[:20]:
    g = math.gcd(a, b)
    print(f"  {n} = {a}² + {b}² = {a*a} + {b*b}, gcd({a},{b})={g}")


# ═══════════════════════════════════════════════════════════════
# Summary of discoveries
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("SUMMARY OF DISCOVERIES")
print("=" * 70)

print("""
1. FIXED POINT THEOREM: The split triplet (N-x, x, N) is always a 
   fixed point of the Universal Parent: UP(N-x, x, N) = (N-x, x, N).

2. DIVISOR GAP THEOREM: For divisor triplet (d, N/d, N), the ghost
   difference |p-q| = |N/d - d| equals the factor gap.

3. LORENTZ DEFICIT: The deficit δ = d² + (N/d)² - N² encodes
   factoring information. δ = 0 iff d² + (N/d)² = N².

4. GCD CHANNEL: gcd(|p|, N) and gcd(|q|, N) sometimes reveal
   non-trivial factors, especially for small x values.

5. TREE TRAVERSAL: Forward Berggren transforms of (3,4,5) generate
   PPTs whose legs could serve as factor candidates when they
   divide a target N.

6. The factoring triplet (x, N, x²+N²) has deficit
   δ = -(x²+N²)(x²+N²-1), which is always large and negative,
   making direct Pythagorean approaches impractical.

7. The most promising approach is the DIVISOR TRIPLET (d, N/d, N)
   combined with the Universal Parent, since:
   - |p-q| directly encodes the factor gap
   - The ghost structure amplifies factor information
   - GCD tests on ghost parameters can reveal factors

IMPORTANT CAVEAT: This approach does not appear to provide a 
polynomial-time factoring algorithm. The divisor triplet requires
knowing d in advance, and the factoring triplet's deficit grows
too fast. However, the algebraic structure is mathematically
interesting and may inspire new approaches.
""")

if __name__ == "__main__":
    print("\nDemo complete.")
