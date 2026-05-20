#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Egyptian Fraction Decompositions

Demonstrates connections between Erdős–Straus decompositions and:
1. Fair division / resource allocation
2. Simplex geometry and probability distributions
3. Lattice point geometry on cubic surfaces
4. Scheduling with unit-fraction time slots
"""

from fractions import Fraction
from typing import Optional
import math


# ─── Core solver (self-contained) ────────────────────────────────────

def _candidate_z(n: int, x: int, y: int) -> Optional[int]:
    denom = 4 * x * y - n * x - n * y
    if denom <= 0:
        return None
    num = n * x * y
    if num % denom != 0:
        return None
    z = num // denom
    return z if z >= 1 else None


def solve_es(n: int, bound: int = 10000) -> Optional[tuple[int, int, int]]:
    """Find a decomposition 4/n = 1/x + 1/y + 1/z."""
    if n < 2:
        return None
    if n % 2 == 0:
        m = n // 2
        return (m, 2 * m, 2 * m)
    if n % 4 == 3:
        k = (n - 3) // 4
        return (k + 2, (k + 1) * (k + 2), (k + 1) * (4 * k + 3))
    for x in range(1, min(bound, 3 * n // 4) + 1):
        for y in range(x, bound + 1):
            z = _candidate_z(n, x, y)
            if z is not None and z >= y:
                return (x, y, z)
    return None


# ─── Application 1: Fair Division ────────────────────────────────────

def fair_division_example():
    """
    APPLICATION: Fair Division with Egyptian Fractions

    Problem: A resource of size 4/n must be divided among 3 recipients
    as unit fractions 1/x, 1/y, 1/z (each gets a "standard slice"
    from a denominator system).

    This models situations where:
    - Shares must be standard fractions (1/2, 1/3, 1/4, ...)
    - The total allocation must be exact (no waste)
    - Recipients get different-sized shares

    Example: Divide 4/7 of a resource among 3 people.
    """
    print("=" * 60)
    print("APPLICATION 1: Fair Division with Egyptian Fractions")
    print("=" * 60)

    print("\nScenario: Divide a resource proportional to 4/n among 3 recipients,")
    print("where each share must be a unit fraction 1/k.\n")

    for n in [3, 5, 7, 11, 13]:
        result = solve_es(n)
        if result:
            x, y, z = result
            total = Fraction(1, x) + Fraction(1, y) + Fraction(1, z)
            print(f"  Resource = 4/{n}:")
            print(f"    Recipient A gets 1/{x} = {1/x:.4f} ({Fraction(1,x)})")
            print(f"    Recipient B gets 1/{y} = {1/y:.6f} ({Fraction(1,y)})")
            print(f"    Recipient C gets 1/{z} = {1/z:.8f} ({Fraction(1,z)})")
            print(f"    Total = {total} = {float(total):.6f}")
            print(f"    Exact? {total == Fraction(4, n)}")
            print()


# ─── Application 2: Simplex Geometry ─────────────────────────────────

def simplex_geometry_example():
    """
    APPLICATION: Simplex Geometry of Decompositions

    Each decomposition 4/n = 1/x + 1/y + 1/z maps to a point on
    the probability simplex via:
      (n/(4x), n/(4y), n/(4z))

    These points always sum to 1 (Theorem 3.8) and lie on a
    discrete sublattice of the simplex determined by the reciprocal
    constraint.
    """
    print("=" * 60)
    print("APPLICATION 2: Simplex Geometry")
    print("=" * 60)

    print("\nEach decomposition maps to the probability simplex Δ²:")
    print("  (a, b, c) where a + b + c = 1, a = n/(4x), etc.\n")

    for n in [2, 3, 5, 7, 11, 13, 17]:
        result = solve_es(n)
        if result:
            x, y, z = result
            a = Fraction(n, 4 * x)
            b = Fraction(n, 4 * y)
            c = Fraction(n, 4 * z)
            print(f"  n={n:>3}: ({float(a):.4f}, {float(b):.6f}, {float(c):.8f})")
            print(f"         Exact: ({a}, {b}, {c})")
            print(f"         Sum = {a + b + c}")

            # Distance from center (1/3, 1/3, 1/3) — measures "unevenness"
            center = Fraction(1, 3)
            dist_sq = (a - center)**2 + (b - center)**2 + (c - center)**2
            print(f"         Distance² from center = {float(dist_sq):.6f}")
            print()


# ─── Application 3: Lattice Points on Cubic Surfaces ────────────────

def cubic_surface_analysis():
    """
    APPLICATION: Lattice Point Geometry

    The equation 4xyz = n(xy + xz + yz) defines a cubic surface S_n.
    We analyze the distribution of lattice points on these surfaces.
    """
    print("=" * 60)
    print("APPLICATION 3: Lattice Points on Cubic Surfaces")
    print("=" * 60)

    print("\nThe cubic surface S_n: 4xyz = n(xy + xz + yz)")
    print("Counting ordered lattice points (x ≤ y ≤ z ≤ B):\n")

    for n in [5, 7, 11, 13]:
        print(f"  S_{n}:")
        points = []
        for x in range(1, 201):
            for y in range(x, 201):
                z = _candidate_z(n, x, y)
                if z is not None and z >= y and z <= 500:
                    points.append((x, y, z))

        print(f"    Found {len(points)} lattice points with z ≤ 500")
        if points:
            xs = [p[0] for p in points]
            print(f"    x range: [{min(xs)}, {max(xs)}]")
            print(f"    Bound 3n/4 = {3*n/4:.1f}")
            print(f"    First 5: {points[:5]}")

            # Check geometric bound
            all_bounded = all(4 * p[0] <= 3 * n for p in points)
            print(f"    All satisfy 4x ≤ 3n? {all_bounded}")
        print()


# ─── Application 4: Scheduling ──────────────────────────────────────

def scheduling_example():
    """
    APPLICATION: Task Scheduling with Unit-Fraction Time Slots

    Problem: Schedule 3 tasks that together consume 4/n of the total
    time, where each task must occupy exactly 1/k of the time for
    some positive integer k.

    This models discrete scheduling where time slots must be
    "standard durations" (1/2 hour, 1/3 hour, 1/4 hour, etc.).
    """
    print("=" * 60)
    print("APPLICATION 4: Task Scheduling")
    print("=" * 60)

    print("\nSchedule 3 tasks using unit-fraction time slots summing to 4/n.\n")

    total_minutes = 60  # one hour
    for n in [3, 5, 7, 10, 12]:
        result = solve_es(n)
        if result:
            x, y, z = result
            t1 = total_minutes / x
            t2 = total_minutes / y
            t3 = total_minutes / z

            print(f"  Total allocation: 4/{n} of {total_minutes} min "
                  f"= {4*total_minutes/n:.2f} min")
            print(f"    Task A: 1/{x} of hour = {t1:.2f} min")
            print(f"    Task B: 1/{y} of hour = {t2:.2f} min")
            print(f"    Task C: 1/{z} of hour = {t3:.4f} min")
            print(f"    Sum: {t1 + t2 + t3:.4f} min")
            print(f"    Target: {4*total_minutes/n:.4f} min")
            print(f"    Match: {abs(t1 + t2 + t3 - 4*total_minutes/n) < 1e-10}")
            print()


# ─── Application 5: Coverage Analysis ────────────────────────────────

def coverage_analysis():
    """
    APPLICATION: Coverage Analysis — Which integers are "easy"?

    Analyze the fraction of integers covered by each family,
    demonstrating the 75% coverage theorem.
    """
    print("=" * 60)
    print("APPLICATION 5: Coverage Analysis (75% Theorem)")
    print("=" * 60)

    N = 1000
    even_count = 0
    mod3_count = 0
    search_count = 0
    total = 0

    for n in range(2, N + 1):
        total += 1
        if n % 2 == 0:
            even_count += 1
        elif n % 4 == 3:
            mod3_count += 1
        else:
            # n ≡ 1 (mod 4) — need search
            result = solve_es(n, bound=1000)
            if result:
                search_count += 1

    family_covered = even_count + mod3_count
    total_covered = family_covered + search_count
    remaining = total - total_covered

    print(f"\n  Range: n = 2 to {N}")
    print(f"  Total integers: {total}")
    print(f"  Covered by even family:    {even_count:>5} ({even_count/total*100:.1f}%)")
    print(f"  Covered by mod-4≡3 family: {mod3_count:>5} ({mod3_count/total*100:.1f}%)")
    print(f"  Covered by families total: {family_covered:>5} ({family_covered/total*100:.1f}%)")
    print(f"  Covered by search (n≡1):   {search_count:>5}")
    print(f"  Total covered:             {total_covered:>5} ({total_covered/total*100:.1f}%)")
    print(f"  Uncovered:                 {remaining:>5}")
    print(f"\n  The 75% theorem predicts: {family_covered/total*100:.1f}% from families alone")


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Egyptian Fraction Decompositions       ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    fair_division_example()
    print()
    simplex_geometry_example()
    print()
    cubic_surface_analysis()
    print()
    scheduling_example()
    print()
    coverage_analysis()


#!/usr/bin/env python3
"""
demo.py — Erdős–Straus Conjecture: Egyptian Fraction Decompositions

Demonstrates the formally verified families and search algorithm for
decomposing 4/n into three unit fractions: 4/n = 1/x + 1/y + 1/z.

Usage:
    python demo.py          # Run demos for sample values
    python demo.py 17       # Find decomposition for specific n
    python demo.py 2 100    # Find decompositions for all n in [2, 100]
"""

from fractions import Fraction
import sys


def decompose_even(n: int) -> tuple[int, int, int] | None:
    """Try the even family: 4/(2m) = 1/m + 1/(2m) + 1/(2m)."""
    if n % 2 != 0 or n < 2:
        return None
    m = n // 2
    return (m, 2 * m, 2 * m)


def decompose_mod4_eq3(n: int) -> tuple[int, int, int] | None:
    """Try the mod-4≡3 family:
    4/(4k+3) = 1/(k+2) + 1/((k+1)(k+2)) + 1/((k+1)(4k+3))."""
    if n % 4 != 3:
        return None
    k = (n - 3) // 4
    x = k + 2
    y = (k + 1) * (k + 2)
    z = (k + 1) * (4 * k + 3)
    return (x, y, z)


def search_es(n: int, bound: int = 10000) -> tuple[int, int, int] | None:
    """Search for an ESWitness: ordered pairs (x, y) with x ≤ y ≤ bound,
    solving for z = nxy / (4xy - nx - ny)."""
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            denom = 4 * x * y - n * x - n * y
            if denom <= 0:
                continue
            num = n * x * y
            if num % denom == 0:
                z = num // denom
                if z >= 1:
                    return (x, y, z)
    return None


def scale_solution(x: int, y: int, z: int, k: int) -> tuple[int, int, int]:
    """Apply the scaling principle: (x,y,z) → (kx,ky,kz)."""
    return (k * x, k * y, k * z)


def verify(n: int, x: int, y: int, z: int) -> bool:
    """Verify that 4/n = 1/x + 1/y + 1/z exactly using rational arithmetic."""
    lhs = Fraction(4, n)
    rhs = Fraction(1, x) + Fraction(1, y) + Fraction(1, z)
    return lhs == rhs


def verify_integer(n: int, x: int, y: int, z: int) -> bool:
    """Verify using the denominator-cleared equation: 4xyz = n(xy + xz + yz)."""
    return 4 * x * y * z == n * (x * y + x * z + y * z)


def normalized_mass(n: int, x: int, y: int, z: int) -> tuple[Fraction, Fraction, Fraction]:
    """Compute the simplex coordinates: (n/(4x), n/(4y), n/(4z))."""
    return (Fraction(n, 4 * x), Fraction(n, 4 * y), Fraction(n, 4 * z))


def find_decomposition(n: int) -> tuple[int, int, int] | None:
    """Find a decomposition for 4/n, trying parametric families first."""
    # Try even family
    result = decompose_even(n)
    if result and verify(n, *result):
        return result

    # Try mod-4≡3 family
    result = decompose_mod4_eq3(n)
    if result and verify(n, *result):
        return result

    # Fall back to search
    result = search_es(n)
    if result and verify(n, *result):
        return result

    return None


def demo_single(n: int) -> None:
    """Demonstrate decomposition for a single n."""
    print(f"\n{'='*60}")
    print(f"  Erdős–Straus decomposition for n = {n}")
    print(f"{'='*60}")

    result = find_decomposition(n)
    if result is None:
        print(f"  No decomposition found for n = {n}")
        return

    x, y, z = result
    print(f"  4/{n} = 1/{x} + 1/{y} + 1/{z}")
    print()

    # Rational verification
    lhs = Fraction(4, n)
    rhs = Fraction(1, x) + Fraction(1, y) + Fraction(1, z)
    print(f"  Rational check:  4/{n} = {lhs} = {rhs}  ✓" if lhs == rhs
          else f"  Rational check:  FAILED ✗")

    # Integer surface verification
    int_ok = verify_integer(n, x, y, z)
    print(f"  Surface check:   4·{x}·{y}·{z} = {4*x*y*z}")
    print(f"                   {n}·({x}·{y} + {x}·{z} + {y}·{z}) = {n*(x*y + x*z + y*z)}")
    print(f"                   {'✓' if int_ok else '✗'}")

    # Simplex normalization
    m1, m2, m3 = normalized_mass(n, x, y, z)
    print(f"  Simplex coords:  ({m1}, {m2}, {m3})")
    print(f"  Sum = {m1 + m2 + m3}  {'✓' if m1 + m2 + m3 == 1 else '✗'}")

    # Method used
    if n % 2 == 0:
        print(f"  Method: Even family (n = 2·{n//2})")
    elif n % 4 == 3:
        k = (n - 3) // 4
        print(f"  Method: Mod-4≡3 family (k = {k})")
    else:
        print(f"  Method: Computational search")


def demo_range(start: int, end: int) -> None:
    """Find decompositions for a range of n values."""
    print(f"\nErdős–Straus decompositions for n = {start} to {end}")
    print(f"{'n':>5} | {'x':>6} {'y':>8} {'z':>10} | {'Method':>12} | Check")
    print("-" * 60)

    failures = []
    for n in range(start, end + 1):
        result = find_decomposition(n)
        if result is None:
            failures.append(n)
            print(f"{n:>5} | {'NONE':>26} | {'FAILED':>12} | ✗")
        else:
            x, y, z = result
            ok = verify(n, x, y, z)
            if n % 2 == 0:
                method = "even"
            elif n % 4 == 3:
                method = "mod4≡3"
            else:
                method = "search"
            print(f"{n:>5} | {x:>6} {y:>8} {z:>10} | {method:>12} | {'✓' if ok else '✗'}")

    print(f"\nTotal: {end - start + 1} values, {len(failures)} failures")
    if failures:
        print(f"Failures: {failures}")
    else:
        print("All decompositions verified ✓")


def demo_scaling() -> None:
    """Demonstrate the scaling principle."""
    print(f"\n{'='*60}")
    print(f"  Scaling Principle Demonstration")
    print(f"{'='*60}")

    n, x, y, z = 5, 2, 4, 20
    print(f"\n  Seed: 4/{n} = 1/{x} + 1/{y} + 1/{z}")
    print(f"  Verify: {verify(n, x, y, z)}")

    for k in [2, 3, 5, 7, 10]:
        kn = k * n
        kx, ky, kz = scale_solution(x, y, z, k)
        ok = verify(kn, kx, ky, kz)
        print(f"  k={k}: 4/{kn} = 1/{kx} + 1/{ky} + 1/{kz}  {'✓' if ok else '✗'}")


def demo_bound() -> None:
    """Demonstrate the geometric bound 4x ≤ 3n for ordered witnesses."""
    print(f"\n{'='*60}")
    print(f"  Geometric Bound: 4x ≤ 3n for Ordered Witnesses")
    print(f"{'='*60}")
    print(f"\n  {'n':>5} | {'x':>5} {'y':>6} {'z':>8} | {'4x':>5} {'3n':>5} | Bound")
    print("  " + "-" * 50)

    for n in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        result = find_decomposition(n)
        if result:
            xyz = sorted(result)
            x, y, z = xyz
            bound_ok = 4 * x <= 3 * n
            print(f"  {n:>5} | {x:>5} {y:>6} {z:>8} | {4*x:>5} {3*n:>5} | {'✓' if bound_ok else '✗'}")


if __name__ == "__main__":
    if len(sys.argv) == 1:
        # Run all demos
        print("╔══════════════════════════════════════════════════════════╗")
        print("║  Erdős–Straus Conjecture: Egyptian Fraction Explorer    ║")
        print("╚══════════════════════════════════════════════════════════╝")

        # Demo individual cases
        for n in [2, 3, 5, 7, 13, 17, 97, 101]:
            demo_single(n)

        # Demo range
        demo_range(2, 50)

        # Demo scaling
        demo_scaling()

        # Demo bound
        demo_bound()

    elif len(sys.argv) == 2:
        n = int(sys.argv[1])
        if n < 2:
            print("Error: n must be ≥ 2")
            sys.exit(1)
        demo_single(n)

    elif len(sys.argv) == 3:
        start = int(sys.argv[1])
        end = int(sys.argv[2])
        demo_range(start, end)

    else:
        print("Usage: python demo.py [n] or python demo.py [start] [end]")
