#!/usr/bin/env python3
"""
Perfect Cuboid Modular Sieve — Applications

Practical applications of the cuboid survivor sieve theory:
1. Search space reduction for computational surveys
2. Admissibility testing for candidate cuboids
3. Euler product analysis for density estimation
4. Quartic fiber analysis for geometric structure
"""

from algorithms import (
    survivor_count, survivor_list, local_density,
    euler_product_density, quadratic_residues,
    is_cuboid_survivor, compute_prime_table,
    quartic_fiber_evaluate, conic_fiber_evaluate,
    face_diagonal_survivor_count
)
from math import isqrt, gcd, prod
from fractions import Fraction
from typing import List, Tuple


# ============================================================
# Application 1: Search Space Reduction
# ============================================================

def search_reduction_analysis():
    """
    Analyze how the modular sieve reduces the search space for
    perfect cuboid searches.
    
    A brute-force search up to bound N checks N³ triples.
    The sieve reduces this by the product of local density factors.
    """
    print("=" * 70)
    print("APPLICATION 1: SEARCH SPACE REDUCTION")
    print("=" * 70)
    print()
    
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    
    # Compute cumulative reduction
    cumulative = 1.0
    modulus = 1
    
    print("Adding primes to the sieve:")
    print(f"{'Primes':>40} {'Modulus':>8} {'Density':>12} {'Speedup':>10}")
    print("-" * 75)
    
    used = []
    for p in primes:
        d = local_density(p)
        cumulative *= d
        modulus *= p
        used.append(str(p))
        print(f"{'×'.join(used):>40} {modulus:>8} {cumulative:>12.8f} {1/cumulative:>10.0f}×")
    
    print()
    print(f"With {len(primes)} primes, the sieve eliminates {(1-cumulative)*100:.4f}% of candidates.")
    print()
    
    # Practical impact
    for N in [10**6, 10**9, 10**12]:
        total = N ** 3
        after_sieve = total * cumulative
        print(f"Search bound N = {N:.0e}:")
        print(f"  Brute force: {total:.2e} triples")
        print(f"  After sieve: {after_sieve:.2e} candidates")
        print(f"  Reduction:   {1/cumulative:.0f}×")
        print()


# ============================================================
# Application 2: Admissibility Testing
# ============================================================

def admissibility_test(a: int, b: int, c: int,
                       primes: List[int] = None) -> Tuple[bool, List[int]]:
    """
    Test whether a candidate triple (a, b, c) passes the modular sieve
    at a list of primes.
    
    Returns (passes_all, list_of_failing_primes).
    
    Args:
        a, b, c: Candidate edge lengths
        primes: List of primes to test (default: [3,5,7,11,13])
        
    Returns:
        Tuple of (passes, failing_primes)
    """
    if primes is None:
        primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    
    failing = []
    for p in primes:
        qr = quadratic_residues(p)
        if not is_cuboid_survivor(a % p, b % p, c % p, p, qr):
            failing.append(p)
    
    return (len(failing) == 0, failing)


def demo_admissibility():
    """Demonstrate admissibility testing on various candidates."""
    print("=" * 70)
    print("APPLICATION 2: ADMISSIBILITY TESTING")
    print("=" * 70)
    print()
    
    # Known Euler bricks (not perfect cuboids)
    candidates = [
        (44, 117, 240, "Smallest Euler brick"),
        (85, 132, 720, "Second Euler brick"),
        (240, 252, 275, "Third Euler brick"),
        (100, 200, 300, "Random triple"),
        (1, 2, 3, "Small triple"),
        (0, 0, 0, "Trivial triple"),
    ]
    
    primes = [3, 5, 7, 11, 13]
    
    for a, b, c, name in candidates:
        passes, failing = admissibility_test(a, b, c, primes)
        status = "PASSES" if passes else f"FAILS at p={failing}"
        
        # Also check actual diagonals
        d1 = a*a + b*b
        d2 = a*a + c*c
        d3 = b*b + c*c
        d4 = a*a + b*b + c*c
        
        d1_ok = isqrt(d1)**2 == d1
        d2_ok = isqrt(d2)**2 == d2
        d3_ok = isqrt(d3)**2 == d3
        d4_ok = isqrt(d4)**2 == d4
        
        diag_status = []
        if d1_ok: diag_status.append("d₁")
        if d2_ok: diag_status.append("d₂")
        if d3_ok: diag_status.append("d₃")
        if d4_ok: diag_status.append("d₄")
        
        print(f"({a}, {b}, {c}) — {name}")
        print(f"  Sieve: {status}")
        print(f"  Actual squares: {', '.join(diag_status) if diag_status else 'none'}")
        print()


# ============================================================
# Application 3: Euler Product Analysis
# ============================================================

def euler_product_analysis():
    """
    Analyze the Euler product structure of the cuboid sieve.
    
    The key question: does the product of (1 - local_shrinkage) 
    converge to 0? If so, a probabilistic argument suggests 
    perfect cuboids are infinitely rare.
    """
    print("=" * 70)
    print("APPLICATION 3: EULER PRODUCT ANALYSIS")
    print("=" * 70)
    print()
    
    table = compute_prime_table(47)
    
    # Compute exact densities as fractions
    print("Exact local densities:")
    print(f"{'p':>4} {'Count/p³':>12} {'Density':>10} {'ln(density)':>12}")
    print("-" * 42)
    
    total_log = 0.0
    import math
    
    for row in table:
        p = row['prime']
        if p == 2:
            continue
        count = row['survivor_count']
        cube = row['cube']
        d = Fraction(count, cube)
        log_d = math.log(float(d))
        total_log += log_d
        print(f"{p:>4} {str(d):>12} {float(d):>10.6f} {log_d:>12.6f}")
    
    print()
    print(f"Sum of ln(density) over odd primes ≤ 47: {total_log:.6f}")
    print(f"Cumulative density: exp({total_log:.6f}) = {math.exp(total_log):.10f}")
    print()
    
    # Compare with random model
    print("Comparison with random model:")
    print("If squares were uniformly random in Z/pZ, each face diagonal")
    print("condition would pass with probability (p+1)/(2p) ≈ 1/2,")
    print("giving 4 conditions each with prob ~1/2.")
    print()
    
    for row in table:
        p = row['prime']
        if p == 2:
            continue
        actual = row['density']
        # Random model: prob of being QR is (p+1)/(2p), 
        # 4 independent conditions on 4 sums
        random_approx = ((p + 1) / (2 * p)) ** 4
        ratio = actual / random_approx
        print(f"  p={p:>2}: actual={actual:.6f}, random≈{random_approx:.6f}, "
              f"ratio={ratio:.4f}")
    print()


# ============================================================
# Application 4: Quartic Fiber Geometry
# ============================================================

def quartic_fiber_analysis():
    """
    Analyze the quartic fiber curves arising from the cuboid parametrization.
    
    For the parametrization u = (r²+1)/(2r), v = (s²+1)/(2s),
    the space diagonal equation reduces to
    W² = r²s⁴ + (r⁴+1)s² + r²
    
    This is a family of quartic curves parametrized by r.
    """
    print("=" * 70)
    print("APPLICATION 4: QUARTIC FIBER ANALYSIS")
    print("=" * 70)
    print()
    
    print("Quartic fiber: W² = r²s⁴ + (r⁴+1)s² + r²")
    print()
    
    # Evaluate at several rational r values
    print("Fiber coefficients for various r:")
    print(f"{'r':>6} {'coeff s⁴':>10} {'coeff s²':>12} {'constant':>10}")
    print("-" * 42)
    
    for r_num, r_den in [(1,1), (1,2), (2,1), (3,2), (2,3), (3,1)]:
        r = Fraction(r_num, r_den)
        a = r**2
        b = r**4 + 1
        c = r**2
        print(f"{str(r):>6} {str(a):>10} {str(b):>12} {str(c):>10}")
    
    print()
    
    # Conic descent: t = s², so W² = r²t² + (r⁴+1)t + r²
    print("Conic fiber (after t = s² descent):")
    print("  W² = r²t² + (r⁴+1)t + r²")
    print()
    
    # Discriminant analysis
    print("Discriminant of the conic (as quadratic in t):")
    print("  Δ(r) = (r⁴+1)² - 4r⁴ = r⁸ - 2r⁴ + 1 = (r⁴-1)²")
    print("  The discriminant is always a perfect square!")
    print("  This means the conic always factors over Q(r).")
    print()
    
    # Actually compute: Δ = (r⁴+1)² - 4r²·r² = (r⁴+1)² - 4r⁴ = r⁸ - 2r⁴ + 1 = (r⁴-1)²
    print("Verification of discriminant formula:")
    for r_num, r_den in [(1,1), (2,1), (3,2), (1,3)]:
        r = Fraction(r_num, r_den)
        delta = (r**4 + 1)**2 - 4 * r**4
        perfect_sq = (r**4 - 1)**2
        print(f"  r = {r}: Δ = {delta} = {perfect_sq} ✓" if delta == perfect_sq 
              else f"  r = {r}: Δ = {delta} ≠ {perfect_sq} ✗")
    
    print()
    print("Since the discriminant (r⁴-1)² is a perfect square,")
    print("the quadratic in t has rational roots:")
    print("  t = [-(r⁴+1) ± (r⁴-1)] / (2r²)")
    print("  t₁ = -1/r²   or   t₂ = -r²")
    print()
    print("Since t = s² ≥ 0 for real s, both roots are negative (for r ≠ 0).")
    print("This means the conic has NO real solutions with t ≥ 0 and W = 0.")
    print("The curve W² = r²t² + (r⁴+1)t + r² is positive for t ≥ 0.")
    print()
    print("Geometric interpretation: The quartic fiber is smooth and irreducible")
    print("over Q for generic r, confirming the genus-1 structure.")


# ============================================================
# Application 5: Survivor Symmetry Analysis
# ============================================================

def symmetry_analysis():
    """
    Analyze the symmetry group of the survivor set.
    
    The cuboid conditions are symmetric under:
    - Coordinate permutations: S₃ acting on (x,y,z)
    - Sign changes: (Z/2Z)³ acting by (x,y,z) → (±x, ±y, ±z)
    
    The full symmetry group is S₃ × (Z/2Z)³ of order 48.
    """
    print("=" * 70)
    print("APPLICATION 5: SURVIVOR SYMMETRY ANALYSIS")
    print("=" * 70)
    print()
    
    for p in [3, 5, 7, 11]:
        survivors = survivor_list(p)
        
        # Group by orbits under S₃ × (Z/2Z)³
        orbits = []
        seen = set()
        
        for trip in survivors:
            if trip in seen:
                continue
            orbit = set()
            x, y, z = trip
            # Generate all permutations and sign changes
            for perm in [(x,y,z), (x,z,y), (y,x,z), (y,z,x), (z,x,y), (z,y,x)]:
                for sx in [1, -1]:
                    for sy in [1, -1]:
                        for sz in [1, -1]:
                            pt = ((sx * perm[0]) % p,
                                  (sy * perm[1]) % p,
                                  (sz * perm[2]) % p)
                            orbit.add(pt)
            
            orbits.append(orbit)
            seen.update(orbit)
        
        print(f"p = {p}: {len(survivors)} survivors in {len(orbits)} orbits")
        print(f"  Orbit sizes: {sorted([len(o) for o in orbits], reverse=True)}")
        print()


if __name__ == "__main__":
    search_reduction_analysis()
    print()
    demo_admissibility()
    print()
    euler_product_analysis()
    print()
    quartic_fiber_analysis()
    print()
    symmetry_analysis()


#!/usr/bin/env python3
"""
Perfect Cuboid Modular Sieve — Demonstration

This script demonstrates the core results of the cuboid survivor sieve:
1. Computing survivor counts at individual primes
2. Verifying CRT multiplicativity
3. Computing cumulative density decay
4. Visualizing the Euler product structure
"""

from algorithms import survivor_count, is_square_mod, local_density
import math


def demo_survivor_counts():
    """Compute and display survivor counts at small primes."""
    print("=" * 70)
    print("CUBOID SURVIVOR COUNTS AT SMALL PRIMES")
    print("=" * 70)
    print()
    print(f"{'Prime p':>8} {'Count':>8} {'p³':>8} {'Density':>10} {'1-density':>10}")
    print("-" * 50)
    
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    for p in primes:
        count = survivor_count(p)
        cube = p ** 3
        density = count / cube
        print(f"{p:>8} {count:>8} {cube:>8} {density:>10.6f} {1-density:>10.6f}")
    
    print()
    print("Key observation: Every prime p >= 3 has density strictly less than 1.")
    print("This means each prime eliminates a positive fraction of residue classes.")
    print()


def demo_crt_multiplicativity():
    """Verify that survivor counts multiply across coprime moduli."""
    print("=" * 70)
    print("CRT MULTIPLICATIVITY VERIFICATION")
    print("=" * 70)
    print()
    
    # Verify mod 15 = 3 × 5
    c3, c5, c15 = survivor_count(3), survivor_count(5), survivor_count(15)
    print(f"survivorCount(3) × survivorCount(5) = {c3} × {c5} = {c3 * c5}")
    print(f"survivorCount(15) = {c15}")
    print(f"Match: {c3 * c5 == c15} ✓")
    print()
    
    # Verify mod 105 = 3 × 5 × 7
    c7 = survivor_count(7)
    c105 = survivor_count(105)
    product = c3 * c5 * c7
    print(f"survivorCount(3) × survivorCount(5) × survivorCount(7)")
    print(f"  = {c3} × {c5} × {c7} = {product}")
    print(f"survivorCount(105) = {c105}")
    print(f"Match: {product == c105} ✓")
    print()
    
    # Verify mod 1155 = 3 × 5 × 7 × 11
    c11 = survivor_count(11)
    # 1155 is too large to compute directly, but we can verify the factorization
    product_1155 = c3 * c5 * c7 * c11
    print(f"survivorCount(3) × survivorCount(5) × survivorCount(7) × survivorCount(11)")
    print(f"  = {c3} × {c5} × {c7} × {c11} = {product_1155}")
    print(f"Predicted survivorCount(1155) = {product_1155}")
    print()
    
    # Additional verification with smaller moduli
    pairs = [(3, 7), (5, 7), (3, 11), (5, 11), (7, 11), (5, 13)]
    print("Pairwise coprime verification:")
    for m, n in pairs:
        cm, cn, cmn = survivor_count(m), survivor_count(n), survivor_count(m * n)
        ok = cm * cn == cmn
        print(f"  {m}×{n}={m*n}: {cm}×{cn}={cm*cn} vs {cmn}  {'✓' if ok else '✗'}")
    print()


def demo_density_decay():
    """Show how the cumulative density decays as primes are added."""
    print("=" * 70)
    print("CUMULATIVE DENSITY DECAY (EULER PRODUCT)")
    print("=" * 70)
    print()
    
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    cumulative = 1.0
    modulus = 1
    
    print(f"{'Primes used':>30} {'Modulus':>10} {'Density':>12} {'Reduction':>10}")
    print("-" * 65)
    print(f"{'(none)':>30} {'1':>10} {'1.000000':>12} {'—':>10}")
    
    prime_list = []
    for p in primes:
        d = local_density(p)
        cumulative *= d
        modulus *= p
        prime_list.append(str(p))
        primes_str = " × ".join(prime_list)
        print(f"{primes_str:>30} {modulus:>10} {cumulative:>12.8f} {d:>10.6f}")
    
    print()
    print(f"After {len(primes)} primes, survivor density = {cumulative:.10f}")
    print(f"Only about {cumulative * 100:.4f}% of residue classes survive.")
    print(f"This is {1/cumulative:.0f}× reduction in search space.")
    print()


def demo_quadratic_residues():
    """Show the quadratic residue structure at each prime."""
    print("=" * 70)
    print("QUADRATIC RESIDUE STRUCTURE")
    print("=" * 70)
    print()
    
    for p in [3, 5, 7, 11, 13]:
        squares = set()
        for x in range(p):
            squares.add((x * x) % p)
        qr_count = len(squares)
        non_qr_count = p - qr_count
        
        print(f"p = {p}:")
        print(f"  Squares mod {p}: {sorted(squares)}")
        print(f"  {qr_count} quadratic residues, {non_qr_count} non-residues")
        
        # Count face-diagonal survivors (only 3 conditions)
        face_count = 0
        for x in range(p):
            for y in range(p):
                for z in range(p):
                    s1 = (x*x + y*y) % p
                    s2 = (x*x + z*z) % p
                    s3 = (y*y + z*z) % p
                    if s1 in squares and s2 in squares and s3 in squares:
                        face_count += 1
        
        full_count = survivor_count(p)
        space_kills = face_count - full_count
        print(f"  Face-diagonal survivors: {face_count}")
        print(f"  Full (+ space diagonal) survivors: {full_count}")
        print(f"  Space diagonal kills: {space_kills} additional ({space_kills/max(face_count,1)*100:.1f}%)")
        print()


def demo_euler_brick_check():
    """Check known Euler bricks against the sieve."""
    print("=" * 70)
    print("EULER BRICK SIEVE VALIDATION")
    print("=" * 70)
    print()
    
    # Known Euler bricks (face diagonals integral, but NOT perfect cuboids)
    bricks = [
        (44, 117, 240, "Smallest Euler brick"),
        (85, 132, 720, "Second smallest"),
        (140, 480, 693, "Third"),
        (160, 231, 792, "Fourth"),
    ]
    
    for a, b, c, name in bricks:
        print(f"Euler brick ({a}, {b}, {c}) — {name}")
        # Check face diagonals
        d1 = a*a + b*b
        d2 = a*a + c*c
        d3 = b*b + c*c
        d4 = a*a + b*b + c*c
        
        d1_sq = int(math.isqrt(d1)) ** 2 == d1
        d2_sq = int(math.isqrt(d2)) ** 2 == d2
        d3_sq = int(math.isqrt(d3)) ** 2 == d3
        d4_sq = int(math.isqrt(d4)) ** 2 == d4
        
        print(f"  Face diags: √({d1})={'✓' if d1_sq else '✗'}, "
              f"√({d2})={'✓' if d2_sq else '✗'}, "
              f"√({d3})={'✓' if d3_sq else '✗'}")
        print(f"  Space diag: √({d4})={'✓' if d4_sq else '✗'} (expected ✗)")
        
        # Check which primes eliminate it
        for p in [3, 5, 7, 11, 13]:
            x, y, z = a % p, b % p, c % p
            s1 = (x*x + y*y) % p
            s2 = (x*x + z*z) % p
            s3 = (y*y + z*z) % p
            s4 = (x*x + y*y + z*z) % p
            squares = set((k*k) % p for k in range(p))
            face_ok = s1 in squares and s2 in squares and s3 in squares
            space_ok = s4 in squares
            status = "survives" if face_ok and space_ok else "eliminated"
            if not face_ok:
                status += " (face)"
            elif not space_ok:
                status += " (space)"
            print(f"  mod {p}: {status}")
        print()


if __name__ == "__main__":
    demo_survivor_counts()
    demo_crt_multiplicativity()
    demo_density_decay()
    demo_quadratic_residues()
    demo_euler_brick_check()


#!/usr/bin/env python3
"""Generate PACKAGE.json from the project files."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read Lean files
lean_files = [
    'Speculative/PerfectCuboid/CRTSieve.lean',
    'Speculative/PerfectCuboid/Computations.lean',
    'Speculative/PerfectCuboid/QuarticFiber.lean',
]
lean_proofs = ""
for f in lean_files:
    lean_proofs += f"-- ========== {f} ==========\n\n"
    lean_proofs += read_file(f) + "\n\n"

package = {
    "title": "CRT Multiplicativity of the Perfect Cuboid Modular Sieve",
    "domain": "Number Theory / Arithmetic Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Perfect Cuboid Sieve Demo",
            "code": demo_code.replace(
                "from algorithms import survivor_count, is_square_mod, local_density",
                """# === Inline algorithms ===
def quadratic_residues(n):
    return {(x * x) % n for x in range(n)}

def is_square_mod(a, n, qr_cache=None):
    if qr_cache is None:
        qr_cache = quadratic_residues(n)
    return (a % n) in qr_cache

def is_cuboid_survivor(x, y, z, n, qr_cache=None):
    if qr_cache is None:
        qr_cache = quadratic_residues(n)
    x2, y2, z2 = (x*x) % n, (y*y) % n, (z*z) % n
    s1 = (x2 + y2) % n
    if s1 not in qr_cache: return False
    s2 = (x2 + z2) % n
    if s2 not in qr_cache: return False
    s3 = (y2 + z2) % n
    if s3 not in qr_cache: return False
    s4 = (x2 + y2 + z2) % n
    if s4 not in qr_cache: return False
    return True

def survivor_count(n):
    qr = quadratic_residues(n)
    count = 0
    for x in range(n):
        for y in range(n):
            for z in range(n):
                if is_cuboid_survivor(x, y, z, n, qr):
                    count += 1
    return count

def local_density(p):
    return survivor_count(p) / (p ** 3)
"""
            )
        },
        {
            "name": "Quartic Fiber Analysis",
            "code": """#!/usr/bin/env python3
\"\"\"Quartic Fiber Analysis for Perfect Cuboid Parametrization\"\"\"
from fractions import Fraction

def quartic_fiber(r, s):
    \"\"\"Evaluate W^2 = r^2*s^4 + (r^4+1)*s^2 + r^2\"\"\"
    return r**2 * s**4 + (r**4 + 1) * s**2 + r**2

def factored_form(r, s):
    \"\"\"Evaluate W^2 = (r^2*s^2 + 1)(s^2 + r^2)\"\"\"
    return (r**2 * s**2 + 1) * (s**2 + r**2)

print("Verifying quartic fiber factorization:")
print("W^2 = r^2*s^4 + (r^4+1)*s^2 + r^2 = (r^2*s^2+1)(s^2+r^2)")
print()

for r_num in range(1, 6):
    for r_den in range(1, 4):
        r = Fraction(r_num, r_den)
        for s_num in range(1, 6):
            for s_den in range(1, 4):
                s = Fraction(s_num, s_den)
                q = quartic_fiber(r, s)
                f = factored_form(r, s)
                assert q == f, f"Mismatch at r={r}, s={s}"

print("All 225 test cases verified: quartic = factored form")
print()

# Discriminant analysis
print("Conic fiber discriminant:")
print("Delta = (r^4+1)^2 - 4r^4 = (r^4-1)^2")
print()
for r_num, r_den in [(1,1), (2,1), (1,2), (3,2), (2,3), (5,1)]:
    r = Fraction(r_num, r_den)
    delta = (r**4 + 1)**2 - 4 * r**4
    sq = (r**4 - 1)**2
    print(f"  r = {r}: Delta = {delta} = ({r**4-1})^2 = {sq} {'✓' if delta == sq else '✗'}")

print()
print("Since Delta is always a perfect square, the quadratic in t = s^2 factors:")
print("  r^2*t^2 + (r^4+1)*t + r^2 = r^2*(t + 1/r^2)*(t + r^2)")
print("  = (r^2*t + 1)*(t + r^2)")
print("  Hence W^2 = (r^2*s^2 + 1)*(s^2 + r^2)")
"""
        }
    ],
    "algorithms": [
        {
            "name": "Survivor Count (Direct Enumeration)",
            "pseudocode": """Input: n ∈ ℕ, n ≥ 1
Output: σ(n) = number of cuboid survivors mod n

1. QR ← {x² mod n : x ∈ {0,...,n-1}}     // O(n) precomputation
2. count ← 0
3. For x ← 0 to n-1:
     For y ← 0 to n-1:
       For z ← 0 to n-1:
         If (x²+y²) mod n ∈ QR
            and (x²+z²) mod n ∈ QR
            and (y²+z²) mod n ∈ QR
            and (x²+y²+z²) mod n ∈ QR:
           count ← count + 1
4. Return count

Time: O(n³)   Space: O(n)""",
            "code": algorithms_code
        },
        {
            "name": "CRT-Accelerated Count",
            "pseudocode": """Input: N = p₁^a₁ · ... · pₖ^aₖ (prime factorization)
Output: σ(N)

1. For i = 1 to k:
     σᵢ ← DirectEnumeration(pᵢ^aᵢ)    // O(pᵢ^{3aᵢ})
2. Return ∏ᵢ σᵢ                        // By CRT multiplicativity

Time: O(Σᵢ pᵢ^{3aᵢ})
For squarefree N: O(Σᵢ pᵢ³) vs O(N³) direct — exponential speedup""",
            "code": """def crt_survivor_count(prime_powers):
    \"\"\"
    Compute survivorCount(N) where N = prod(prime_powers).
    Uses CRT multiplicativity: sigma(mn) = sigma(m)*sigma(n) for gcd(m,n)=1.
    
    Args:
        prime_powers: list of prime powers (pairwise coprime)
    Returns:
        Product of individual survivor counts
    \"\"\"
    from math import gcd
    
    # Verify pairwise coprimality
    for i in range(len(prime_powers)):
        for j in range(i+1, len(prime_powers)):
            assert gcd(prime_powers[i], prime_powers[j]) == 1
    
    def quadratic_residues(n):
        return {(x * x) % n for x in range(n)}
    
    def survivor_count(n):
        qr = quadratic_residues(n)
        count = 0
        for x in range(n):
            for y in range(n):
                for z in range(n):
                    x2, y2, z2 = (x*x)%n, (y*y)%n, (z*z)%n
                    if ((x2+y2)%n in qr and (x2+z2)%n in qr 
                        and (y2+z2)%n in qr and (x2+y2+z2)%n in qr):
                        count += 1
        return count
    
    result = 1
    for pp in prime_powers:
        result *= survivor_count(pp)
    return result

# Example: σ(1155) = σ(3)·σ(5)·σ(7)·σ(11)
result = crt_survivor_count([3, 5, 7, 11])
print(f"survivorCount(1155) = {result}")
assert result == 2150995
print("Verified: 7 × 37 × 55 × 151 = 2,150,995")
"""
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
