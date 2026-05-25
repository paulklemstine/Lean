#!/usr/bin/env python3
"""
applications.py — Real-world applications and extended experiments
for the sums-of-three-cubes local-global framework.

Demonstrates:
  1. Systematic exploration of local obstruction patterns
  2. The gap between local and global solvability
  3. Connections to algebraic number theory (Eisenstein norm forms)
  4. Computational verification of the local sufficiency conjecture
"""

import math
from collections import defaultdict
from typing import Optional


# ──────────────────────────────────────────────────────────────────────
# Application 1: Local obstruction analysis
# ──────────────────────────────────────────────────────────────────────

def cube_residues(n: int) -> set[int]:
    """Cube residues modulo n."""
    return {pow(x, 3, n) for x in range(n)}


def three_cube_sums(n: int) -> set[int]:
    """All residues mod n that are sums of three cubes."""
    cubes = cube_residues(n)
    result = set()
    for a in cubes:
        for b in cubes:
            for c in cubes:
                result.add((a + b + c) % n)
    return result


def analyze_prime_obstructions(bound: int = 100) -> None:
    """
    Analyze which primes produce local obstructions.

    Key finding: only p = 9 (= 3²) gives obstructions among small moduli.
    This is connected to the fact that 3 is special for cubes (Fermat quotient).
    """
    print("=" * 60)
    print("  Local Obstruction Analysis by Prime Powers")
    print("=" * 60)

    primes = [p for p in range(2, bound) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]

    for p in primes[:20]:
        for e in range(1, 5):
            n = p ** e
            if n > bound:
                break
            admissible = three_cube_sums(n)
            blocked = n - len(admissible)
            if blocked > 0:
                print(f"  p^e = {p}^{e} = {n:>5}: "
                      f"{len(admissible)}/{n} admissible, "
                      f"{blocked} blocked = {sorted(set(range(n)) - admissible)}")

    print()
    print("  Observation: Only powers of 3 produce local obstructions")
    print("  for sums of three cubes. This is because cube roots of unity")
    print("  in Z/pZ for p ≠ 3 provide enough flexibility.")
    print()


def analyze_mod_powers_of_3(max_exp: int = 5) -> None:
    """
    Detailed analysis of obstructions at powers of 3.

    The mod-9 obstruction is the simplest case. What happens at 27, 81, ...?
    """
    print("=" * 60)
    print("  Obstructions at Powers of 3")
    print("=" * 60)

    for e in range(1, max_exp + 1):
        n = 3 ** e
        admissible = three_cube_sums(n)
        blocked = set(range(n)) - admissible
        ratio = len(blocked) / n
        print(f"\n  mod 3^{e} = {n}:")
        print(f"    Admissible: {len(admissible)}/{n} ({len(admissible)/n:.1%})")
        print(f"    Blocked:    {len(blocked)}/{n} ({ratio:.1%})")
        if len(blocked) <= 20:
            print(f"    Blocked residues: {sorted(blocked)}")
        else:
            print(f"    Sample blocked: {sorted(blocked)[:10]}...")

    print()


# ──────────────────────────────────────────────────────────────────────
# Application 2: Eisenstein norm form connection
# ──────────────────────────────────────────────────────────────────────

def eisenstein_norm(a: int, b: int) -> int:
    """
    Norm in the Eisenstein integers Z[ω], where ω = e^(2πi/3).

    N(a + bω) = a² - ab + b² = a² + b² - ab

    This is the binary quadratic form appearing in the factorization
    x³ + y³ = (x+y)(x² - xy + y²).
    """
    return a * a - a * b + b * b


def representable_by_norm(m: int, bound: int = 100) -> Optional[tuple[int, int]]:
    """
    Check if m = a² - ab + b² for some integers a, b.

    These are exactly the norms of elements in Z[ω].
    By the theory of binary quadratic forms, m is representable iff
    all prime factors p ≡ 2 (mod 3) appear to even power in m.
    """
    if m < 0:
        return None
    if m == 0:
        return (0, 0)
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            if eisenstein_norm(a, b) == m:
                return (a, b)
    return None


def factorization_analysis(k: int, z_bound: int = 50) -> None:
    """
    For a given k, analyze the factorization landscape k - z³ = s · q.

    Shows how the Eisenstein norm form constrains solutions.
    """
    print(f"\n  Factorization landscape for k = {k}:")
    print(f"  {'z':>5} {'m=k-z³':>12} {'# divisors':>12} {'norm rep?':>10}")
    print(f"  {'-'*42}")

    for z in range(-min(z_bound, 10), min(z_bound, 10) + 1):
        m = k - z ** 3
        if m == 0:
            print(f"  {z:>5} {m:>12} {'—':>12} {'trivial':>10}")
            continue
        divs = []
        absm = abs(m)
        for i in range(1, int(math.isqrt(absm)) + 1):
            if absm % i == 0:
                divs.extend([i, -i, absm // i, -(absm // i)])
        divs = sorted(set(divs))

        # Check if any factorization s*q = m has q representable by Eisenstein norm
        found = False
        for s in divs:
            if s == 0:
                continue
            q = m // s
            if q >= 0 and representable_by_norm(q, 50) is not None:
                found = True
                break

        norm_str = "✓" if found else "✗"
        print(f"  {z:>5} {m:>12} {len(divs):>12} {norm_str:>10}")


# ──────────────────────────────────────────────────────────────────────
# Application 3: Local sufficiency conjecture verification
# ──────────────────────────────────────────────────────────────────────

def verify_local_sufficiency_conjecture(N: int = 200, mod_bound: int = 50) -> None:
    """
    Test the conjecture: if k ≢ 4,5 (mod 9), then k is locally
    admissible at every modulus n.

    This is the computational shadow of the conjecture that the only
    congruence obstruction is the mod-9 one.
    """
    print("=" * 60)
    print("  Testing Local Sufficiency Conjecture")
    print("=" * 60)
    print(f"  Range: k ∈ [0, {N}], moduli n ∈ [2, {mod_bound}]")
    print()

    # Precompute admissible sets
    admissible_sets: dict[int, set[int]] = {}
    for n in range(2, mod_bound + 1):
        admissible_sets[n] = three_cube_sums(n)

    counterexamples = []
    tested = 0

    for k in range(N + 1):
        if k % 9 in (4, 5):
            continue
        tested += 1
        for n in range(2, mod_bound + 1):
            if k % n not in admissible_sets[n]:
                counterexamples.append((k, n))
                break

    if counterexamples:
        print(f"  ✗ CONJECTURE FAILS!")
        for k, n in counterexamples[:10]:
            print(f"    k = {k}: fails at modulus n = {n}")
    else:
        print(f"  ✓ Conjecture holds for all {tested} tested values")
        print(f"    No k ∈ [0, {N}] with k ≢ 4,5 (mod 9) fails")
        print(f"    local admissibility at any modulus n ≤ {mod_bound}")

    print()


# ──────────────────────────────────────────────────────────────────────
# Application 4: Symmetry group action on solutions
# ──────────────────────────────────────────────────────────────────────

def enumerate_symmetry_orbit(x: int, y: int, z: int) -> set[tuple[int, int, int]]:
    """
    Compute the orbit of (x, y, z) under the symmetry group of x³+y³+z³.

    The full symmetry group is S₃ × (Z/2Z)³ (permutations and individual sign flips).
    But only S₃ preserves the sum; sign flips change k to -k.
    For the same k, the symmetry group is S₃ (order 6).
    """
    from itertools import permutations
    orbit = set()
    for perm in permutations([x, y, z]):
        orbit.add(perm)
    return orbit


def solution_orbit_analysis(k: int, bound: int = 100) -> None:
    """Analyze solution orbits for a given k."""
    print(f"\n  Solution orbits for k = {k}:")

    solutions = set()
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            z3 = k - x**3 - y**3
            z = round(abs(z3) ** (1/3)) * (1 if z3 >= 0 else -1)
            for zz in [z-1, z, z+1]:
                if x**3 + y**3 + zz**3 == k:
                    # Canonical form: sorted triple
                    triple = tuple(sorted([x, y, zz]))
                    solutions.add(triple)

    if not solutions:
        print(f"    No solutions found in [-{bound}, {bound}]")
        return

    print(f"    Found {len(solutions)} distinct orbits (canonical form: sorted):")
    for sol in sorted(solutions)[:20]:
        x, y, z = sol
        orbit_size = len(enumerate_symmetry_orbit(x, y, z))
        print(f"    ({x}, {y}, {z}) — orbit size {orbit_size}")


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Applications: Local-Global Geometry of Three Cubes   ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    # Application 1: Local obstructions
    analyze_prime_obstructions(50)
    analyze_mod_powers_of_3(4)

    # Application 2: Eisenstein norm analysis
    print("=" * 60)
    print("  Eisenstein Norm Form Analysis")
    print("=" * 60)
    print("  x³ + y³ = (x+y)(x² - xy + y²)")
    print("  where x² - xy + y² is the Eisenstein norm form N(x + yω)")
    factorization_analysis(29)
    factorization_analysis(33)

    # Application 3: Conjecture test
    verify_local_sufficiency_conjecture(500, 50)

    # Application 4: Solution orbits
    print("=" * 60)
    print("  Solution Orbit Analysis")
    print("=" * 60)
    for k in [0, 1, 2, 3, 6, 8, 9, 10]:
        solution_orbit_analysis(k, 30)

    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive exploration of the sums-of-three-cubes problem.

Demonstrates:
  1. The mod-9 obstruction (local non-admissibility)
  2. Factorization-based solution search
  3. Local admissibility coverage across moduli
  4. Statistics on the search process
"""

import math
import sys
from collections import Counter
from typing import Optional


# ──────────────────────────────────────────────────────────────────────
# Core definitions
# ──────────────────────────────────────────────────────────────────────

def cube_residues_mod(n: int) -> set[int]:
    """Return the set of cube residues modulo n."""
    return {pow(x, 3, n) for x in range(n)}


def three_cube_local_admissible(n: int, a: int) -> bool:
    """Check if residue a is locally admissible mod n (sum of three cubes)."""
    a_mod = a % n
    cubes = cube_residues_mod(n)
    for c1 in cubes:
        for c2 in cubes:
            rem = (a_mod - c1 - c2) % n
            if rem in cubes:
                return True
    return False


def mod9_obstructed(k: int) -> bool:
    """Check if k is obstructed by the mod 9 condition."""
    return k % 9 in (4, 5)


def everywhere_locally_admissible(k: int, max_modulus: int = 100) -> tuple[bool, Optional[int]]:
    """
    Check local admissibility for all moduli up to max_modulus.
    Returns (is_admissible, first_failing_modulus_or_None).
    """
    for n in range(2, max_modulus + 1):
        if not three_cube_local_admissible(n, k):
            return False, n
    return True, None


# ──────────────────────────────────────────────────────────────────────
# Factorization-based search (Algorithm from the research)
# ──────────────────────────────────────────────────────────────────────

def find_xy_from_sq(s: int, q: int) -> Optional[tuple[int, int]]:
    """
    Given s = x+y and q = x²-xy+y², find integer x, y if they exist.

    From the discriminant relation: 4q - s² = 3(x-y)².
    So d² = (4q - s²) / 3 where d = x - y.
    Then x = (s + d) / 2, y = (s - d) / 2.
    """
    disc = 4 * q - s * s
    if disc < 0:
        return None
    if disc % 3 != 0:
        return None
    dsq = disc // 3
    d = int(math.isqrt(dsq))
    if d * d != dsq:
        return None
    # x = (s + d) / 2, y = (s - d) / 2
    if (s + d) % 2 != 0:
        return None
    x = (s + d) // 2
    y = (s - d) // 2
    # Verify
    if x ** 3 + y ** 3 == s * q:
        return x, y
    # Try negative d
    d = -d
    if (s + d) % 2 != 0:
        return None
    x = (s + d) // 2
    y = (s - d) // 2
    if x ** 3 + y ** 3 == s * q:
        return x, y
    return None


def divisors(n: int) -> list[int]:
    """Return all divisors of n (positive and negative)."""
    if n == 0:
        return []
    absn = abs(n)
    divs = []
    for i in range(1, int(math.isqrt(absn)) + 1):
        if absn % i == 0:
            divs.extend([i, -i, absn // i, -(absn // i)])
    return list(set(divs))


def search_factorization(k: int, bound: int = 1000) -> Optional[tuple[int, int, int]]:
    """
    Search for x, y, z with x³ + y³ + z³ = k using factorization.

    For each z in [-bound, bound], compute m = k - z³, then
    search for factorizations m = s * q with s = x+y, q = x²-xy+y².
    """
    if mod9_obstructed(k):
        return None  # provably impossible

    stats = {"z_tested": 0, "factor_pairs": 0}

    for z in range(0, bound + 1):
        for sign in [1, -1]:
            zz = z * sign
            if z == 0 and sign == -1:
                continue
            m = k - zz ** 3
            stats["z_tested"] += 1

            if m == 0:
                # x³ + y³ = 0, so y = -x
                return (0, 0, zz)

            for s in divisors(m):
                if s == 0:
                    continue
                q = m // s
                stats["factor_pairs"] += 1
                result = find_xy_from_sq(s, q)
                if result is not None:
                    x, y = result
                    assert x ** 3 + y ** 3 + zz ** 3 == k, "Verification failed!"
                    return (x, y, zz)

    return None


# ──────────────────────────────────────────────────────────────────────
# Residue coverage analysis
# ──────────────────────────────────────────────────────────────────────

def residue_coverage(n: int) -> dict:
    """Analyze which residues mod n are locally admissible."""
    admissible = set()
    non_admissible = set()
    for a in range(n):
        if three_cube_local_admissible(n, a):
            admissible.add(a)
        else:
            non_admissible.add(a)
    return {
        "modulus": n,
        "admissible": sorted(admissible),
        "non_admissible": sorted(non_admissible),
        "coverage": len(admissible) / n,
    }


# ──────────────────────────────────────────────────────────────────────
# Display
# ──────────────────────────────────────────────────────────────────────

def display_analysis(k: int, search_bound: int = 1000):
    """Full analysis of an integer k."""
    print(f"\n{'='*60}")
    print(f"  Analysis of k = {k}")
    print(f"{'='*60}")

    # Mod 9 check
    r = k % 9
    print(f"\n  k mod 9 = {r}")
    if mod9_obstructed(k):
        print(f"  ✗ OBSTRUCTED: k ≡ {r} (mod 9)")
        print(f"    No integer solution to x³+y³+z³ = {k} exists.")
        print(f"    (Proved: residues 4,5 mod 9 are not three-cube admissible)")
        return
    else:
        print(f"  ✓ Passes mod-9 test (not ≡ 4 or 5)")

    # Local admissibility
    print(f"\n  Local admissibility check (moduli 2..50):")
    all_local = True
    for n in range(2, 51):
        if not three_cube_local_admissible(n, k):
            print(f"    ✗ FAILS at modulus {n}")
            all_local = False
            break
    if all_local:
        print(f"    ✓ Locally admissible at all tested moduli")

    # Solution search
    print(f"\n  Searching for solution (z ∈ [-{search_bound}, {search_bound}])...")
    result = search_factorization(k, search_bound)
    if result is not None:
        x, y, z = result
        print(f"    ✓ FOUND: {x}³ + {y}³ + {z}³ = {k}")
        print(f"      Verification: {x**3} + {y**3} + {z**3} = {x**3+y**3+z**3}")
    else:
        print(f"    ✗ No solution found within search bound")

    # Sign symmetry
    print(f"\n  Sign symmetry: k ↦ -k = {-k}")
    result_neg = search_factorization(-k, search_bound)
    if result_neg is not None:
        x, y, z = result_neg
        print(f"    ✓ FOUND: {x}³ + {y}³ + {z}³ = {-k}")
    else:
        if mod9_obstructed(-k):
            print(f"    ✗ -k ≡ {(-k)%9} (mod 9) — obstructed")
        else:
            print(f"    ✗ No solution found for -k within search bound")


def display_residue_table():
    """Display residue coverage for several moduli."""
    print(f"\n{'='*60}")
    print(f"  Residue Coverage Table")
    print(f"{'='*60}")
    print(f"  {'Modulus':>8} {'Admissible':>12} {'Blocked':>8} {'Coverage':>10}")
    print(f"  {'-'*42}")
    for n in [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 25, 27]:
        info = residue_coverage(n)
        blocked = info['non_admissible']
        blocked_str = str(blocked) if blocked else "none"
        print(f"  {n:>8} {len(info['admissible']):>12} {len(blocked):>8} {info['coverage']:>9.1%}")
        if blocked:
            print(f"           blocked: {blocked_str}")


def display_mod9_histogram():
    """Show which residues mod 9 appear in sums of three cubes."""
    print(f"\n{'='*60}")
    print(f"  Mod 9 Residue Histogram (cube sums)")
    print(f"{'='*60}")
    cubes_mod9 = [pow(x, 3, 9) for x in range(9)]
    print(f"  Cube residues mod 9: {sorted(set(cubes_mod9))} = {{0, 1, 8}}")
    print()

    sums = Counter()
    for a in cubes_mod9:
        for b in cubes_mod9:
            for c in cubes_mod9:
                sums[(a + b + c) % 9] += 1

    print(f"  {'Residue':>8} {'# of ways':>10} {'Admissible':>12}")
    print(f"  {'-'*34}")
    for r in range(9):
        adm = "✓" if sums[r] > 0 else "✗ BLOCKED"
        bar = "█" * (sums[r] // 5 + 1) if sums[r] > 0 else ""
        print(f"  {r:>8} {sums[r]:>10} {adm:>12}  {bar}")


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Sums of Three Cubes: Local-Global Geometry Explorer   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Show the mod 9 histogram
    display_mod9_histogram()

    # Show residue coverage
    display_residue_table()

    # Analyze specific integers
    test_values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 17, 29, 33, 42, 100]

    if len(sys.argv) > 1:
        try:
            test_values = [int(x) for x in sys.argv[1:]]
        except ValueError:
            print("Usage: python demo.py [k1 k2 k3 ...]")
            sys.exit(1)

    for k in test_values:
        display_analysis(k, search_bound=500)

    # Summary statistics
    print(f"\n{'='*60}")
    print(f"  Summary: representability for k ∈ [0, 100]")
    print(f"{'='*60}")
    found = 0
    obstructed = 0
    not_found = 0
    for k in range(101):
        if mod9_obstructed(k):
            obstructed += 1
        elif search_factorization(k, 500) is not None:
            found += 1
        else:
            not_found += 1

    print(f"  Obstructed (mod 9):    {obstructed:>4}")
    print(f"  Solution found:        {found:>4}")
    print(f"  Open (no solution):    {not_found:>4}")
    print(f"  Total:                 {found + obstructed + not_found:>4}")
    print()


if __name__ == "__main__":
    main()
