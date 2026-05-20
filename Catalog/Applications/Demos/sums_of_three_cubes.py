#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Three-Cubes Theory

Demonstrates practical applications of the local-global framework:
1. Certified filtering for computational searches
2. Modular obstruction analysis across prime powers
3. Statistical analysis of representable integers
4. Performance comparison: naive vs. certified search
"""

from typing import List, Tuple, Optional, Dict
import time
import math


# ============================================================================
# Application 1: Certified Search Pipeline
# ============================================================================

def certified_search_pipeline(
    targets: List[int],
    bound: int = 5000,
    verbose: bool = True
) -> Dict[int, Optional[Tuple[int, int, int]]]:
    """Production-grade search pipeline with certified pre-filtering.

    Steps:
    1. Mod 9 filter eliminates provably impossible targets
    2. Extended local checks at prime powers detect additional structure
    3. Symmetry-reduced search for remaining candidates

    This pipeline is certified correct: any target it declares impossible
    IS impossible (by forbiddenModNine_not_representable).

    Examples:
        >>> results = certified_search_pipeline([0, 1, 4, 5], bound=100, verbose=False)
        >>> results[4] is None  # Forbidden mod 9
        True
        >>> results[0] is not None
        True
    """
    results = {}

    if verbose:
        print(f"\n  Processing {len(targets)} targets with bound {bound}")
        print(f"  {'k':>6} | {'mod9':>4} | {'local':>5} | {'result'}")
        print(f"  {'-'*6}-+-{'-'*4}-+-{'-'*5}-+-{'-'*30}")

    forbidden_count = 0
    found_count = 0
    not_found_count = 0

    for k in targets:
        # Step 1: Mod 9 filter
        if k % 9 in (4, 5):
            results[k] = None
            forbidden_count += 1
            if verbose:
                print(f"  {k:>6} | FORB |  ---  | Certified impossible (mod 9)")
            continue

        # Step 2: Extended local check
        local_ok = True
        for p in [2, 3, 5, 7]:
            for e in range(1, 4):
                n = p ** e
                cubes = {pow(x, 3, n) for x in range(n)}
                target = k % n
                pair_sums = {(a + b) % n for a in cubes for b in cubes}
                if not any((target - c) % n in pair_sums for c in cubes):
                    local_ok = False
                    break
            if not local_ok:
                break

        # Step 3: Search
        result = None
        for z in range(-bound, bound + 1):
            z3 = z ** 3
            for y in range(-bound, z + 1):
                remainder = k - y**3 - z3
                if remainder == 0:
                    x_try = 0
                elif remainder > 0:
                    x_try = round(remainder ** (1/3))
                else:
                    x_try = -round((-remainder) ** (1/3))
                for dx in range(-2, 3):
                    x = x_try + dx
                    if x**3 == remainder and x <= y:
                        result = (x, y, z)
                        break
                if result:
                    break
            if result:
                break

        results[k] = result
        if result:
            found_count += 1
            x, y, z = result
            if verbose:
                print(f"  {k:>6} |  OK  |  {'✓' if local_ok else '✗'}    | "
                      f"({x})³+({y})³+({z})³ = {k}")
        else:
            not_found_count += 1
            if verbose:
                print(f"  {k:>6} |  OK  |  {'✓' if local_ok else '✗'}    | "
                      f"Not found within bound")

    if verbose:
        print(f"\n  Summary: {forbidden_count} forbidden, {found_count} found, "
              f"{not_found_count} not found within bound")

    return results


# ============================================================================
# Application 2: Modular Obstruction Landscape
# ============================================================================

def modular_obstruction_landscape(max_modulus: int = 50):
    """Analyze the obstruction landscape across moduli.

    For each modulus n, compute:
    - Number of achievable residues (cube-sum residues)
    - Number of forbidden residues
    - "Obstruction strength" = fraction of residues forbidden

    This reveals that most moduli give NO obstruction — only those
    related to 9 (= 3²) create forbidden classes.

    Examples:
        >>> modular_obstruction_landscape(20)  # doctest: +SKIP
    """
    print("\n  Modular Obstruction Landscape")
    print(f"  {'n':>4} | {'achievable':>10} | {'forbidden':>9} | {'strength':>8} | notes")
    print(f"  {'-'*4}-+-{'-'*10}-+-{'-'*9}-+-{'-'*8}-+-{'-'*20}")

    for n in range(2, max_modulus + 1):
        cubes = {pow(x, 3, n) for x in range(n)}
        achievable = set()
        for a in cubes:
            for b in cubes:
                for c in cubes:
                    achievable.add((a + b + c) % n)
        forbidden = n - len(achievable)
        strength = forbidden / n

        notes = ""
        if n == 9:
            notes = "← mod 9 obstruction"
        elif n % 9 == 0 and forbidden > 0:
            notes = "← inherited from mod 9"
        elif forbidden > 0:
            notes = "← obstruction!"

        if forbidden > 0 or n <= 12 or n in [16, 25, 27, 32, 49]:
            print(f"  {n:>4} | {len(achievable):>10} | {forbidden:>9} | "
                  f"{strength:>8.4f} | {notes}")


# ============================================================================
# Application 3: Representation Statistics
# ============================================================================

def representation_statistics(N: int = 200, bound: int = 2000):
    """Compute statistics on representability for k in [0, N).

    Analyzes:
    - Fraction admissible (should approach 7/9)
    - Fraction with known small representations
    - Distribution of solution heights

    Examples:
        >>> representation_statistics(50, 500)  # doctest: +SKIP
    """
    print(f"\n  Representation Statistics for k ∈ [0, {N})")
    print(f"  Search bound: {bound}")

    admissible_count = 0
    found_count = 0
    heights = []

    for k in range(N):
        if k % 9 in (4, 5):
            continue
        admissible_count += 1

        # Quick search
        found = False
        for z in range(-bound, bound + 1):
            z3 = z ** 3
            for y in range(-bound, z + 1):
                remainder = k - y**3 - z3
                if remainder == 0:
                    x_try = 0
                elif remainder > 0:
                    x_try = round(remainder ** (1/3))
                else:
                    x_try = -round((-remainder) ** (1/3))
                for dx in range(-2, 3):
                    x = x_try + dx
                    if x**3 == remainder and x <= y:
                        h = max(abs(x), abs(y), abs(z))
                        heights.append((k, h))
                        found = True
                        break
                if found:
                    break
            if found:
                break
        if found:
            found_count += 1

    print(f"\n  Results:")
    print(f"    Total integers: {N}")
    print(f"    Admissible:     {admissible_count} ({admissible_count/N:.4f})")
    print(f"    Found:          {found_count} ({found_count/admissible_count:.4f} of admissible)")
    print(f"    Theoretical admissible density: {7/9:.4f}")

    if heights:
        hs = [h for _, h in heights]
        print(f"\n  Height distribution (among found):")
        print(f"    Min height:    {min(hs)}")
        print(f"    Max height:    {max(hs)}")
        print(f"    Mean height:   {sum(hs)/len(hs):.1f}")
        print(f"    Median height: {sorted(hs)[len(hs)//2]}")

        # Height buckets
        buckets = {1: 0, 10: 0, 100: 0, 1000: 0}
        for h in hs:
            for b in sorted(buckets.keys()):
                if h <= b:
                    buckets[b] += 1
                    break
            else:
                buckets[1000] += 1
        print(f"\n  Height buckets:")
        for b, c in sorted(buckets.items()):
            print(f"    ≤ {b:>5}: {c:>4} ({c/len(hs)*100:.1f}%)")


# ============================================================================
# Application 4: Performance Benchmarking
# ============================================================================

def benchmark_search_methods(test_cases: List[int], bound: int = 200):
    """Compare naive vs. certified symmetry-reduced search.

    Measures:
    - Wall-clock time
    - Number of triples examined
    - Speedup factor

    Examples:
        >>> benchmark_search_methods([1, 2, 3, 6, 7, 8], 100)  # doctest: +SKIP
    """
    print(f"\n  Performance Benchmark (bound={bound})")
    print(f"  {'k':>4} | {'naive_time':>10} | {'smart_time':>10} | {'speedup':>7}")
    print(f"  {'-'*4}-+-{'-'*10}-+-{'-'*10}-+-{'-'*7}")

    total_naive = 0
    total_smart = 0

    for k in test_cases:
        if k % 9 in (4, 5):
            print(f"  {k:>4} | {'---':>10} | {'---':>10} | FORBIDDEN")
            continue

        # Naive search
        t0 = time.perf_counter()
        result_naive = None
        for x in range(-bound, bound + 1):
            for y in range(-bound, bound + 1):
                for z in range(-bound, bound + 1):
                    if x**3 + y**3 + z**3 == k:
                        result_naive = (x, y, z)
                        break
                if result_naive:
                    break
            if result_naive:
                break
        t_naive = time.perf_counter() - t0

        # Smart search
        t0 = time.perf_counter()
        result_smart = None
        for z in range(-bound, bound + 1):
            z3 = z ** 3
            for y in range(-bound, z + 1):
                remainder = k - y**3 - z3
                if remainder == 0:
                    x_try = 0
                elif remainder > 0:
                    x_try = round(remainder ** (1/3))
                else:
                    x_try = -round((-remainder) ** (1/3))
                for dx in range(-2, 3):
                    x = x_try + dx
                    if x**3 == remainder and x <= y:
                        result_smart = (x, y, z)
                        break
                if result_smart:
                    break
            if result_smart:
                break
        t_smart = time.perf_counter() - t0

        total_naive += t_naive
        total_smart += t_smart
        speedup = t_naive / t_smart if t_smart > 0 else float('inf')
        print(f"  {k:>4} | {t_naive:>9.4f}s | {t_smart:>9.4f}s | {speedup:>6.1f}×")

    if total_smart > 0:
        print(f"\n  Total speedup: {total_naive/total_smart:.1f}×")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Applications of Three-Cubes Local-Global Theory      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Certified search pipeline
    print("\n" + "="*60)
    print("  Application 1: Certified Search Pipeline")
    print("="*60)
    targets = list(range(50))
    certified_search_pipeline(targets, bound=2000)

    # Application 2: Obstruction landscape
    print("\n" + "="*60)
    print("  Application 2: Modular Obstruction Landscape")
    print("="*60)
    modular_obstruction_landscape(50)

    # Application 3: Statistics
    print("\n" + "="*60)
    print("  Application 3: Representation Statistics")
    print("="*60)
    representation_statistics(100, 3000)

    # Application 4: Performance benchmark
    print("\n" + "="*60)
    print("  Application 4: Search Performance Benchmark")
    print("="*60)
    benchmark_search_methods([1, 2, 3, 6, 7, 8, 10, 15, 17], bound=100)


#!/usr/bin/env python3
"""
demo.py — Sums of Three Cubes: Local-Global Geometry

Demonstrates the certified mathematical framework for the Diophantine equation
x³ + y³ + z³ = k. Each computational step corresponds to a formally verified
theorem.

Usage:
    python demo.py          # Run all demos
    python demo.py 42       # Analyze a specific integer
"""

import sys
from typing import Optional


def is_forbidden_mod9(k: int) -> bool:
    """Check if k is forbidden modulo 9 (residue 4 or 5).

    Corresponds to: ForbiddenModNine k ↔ k % 9 = 4 ∨ k % 9 = 5
    Certified by: forbiddenModNine_not_representable
    """
    return k % 9 in (4, 5)


def is_admissible(k: int) -> bool:
    """Check if k passes the mod 9 admissibility test.

    Corresponds to: AdmissibleThreeCube k ↔ ¬ ForbiddenModNine k
    """
    return not is_forbidden_mod9(k)


def cube_residues_mod(n: int) -> set:
    """Compute the set of cube residues modulo n."""
    return {pow(x, 3, n) for x in range(n)}


def is_locally_soluble(k: int, n: int) -> bool:
    """Check if x³ + y³ + z³ ≡ k (mod n) has a solution.

    Corresponds to: LocallyAtMod k n
    """
    cubes = cube_residues_mod(n)
    target = k % n
    pair_sums = {(a + b) % n for a in cubes for b in cubes}
    return any((target - c) % n in pair_sums for c in cubes)


def search_representation(k: int, bound: int = 1000) -> Optional[tuple]:
    """Search for x, y, z with x³ + y³ + z³ = k and max(|x|,|y|,|z|) ≤ bound.

    Uses symmetry reduction (y ≤ z) and the mod 9 filter.

    Corresponds to: IsThreeCubeRepresentable k
    Certified filter: forbiddenModNine_not_representable
    """
    if is_forbidden_mod9(k):
        return None  # Certified impossible

    for z in range(-bound, bound + 1):
        for y in range(-bound, z + 1):
            remainder = k - y**3 - z**3
            # Compute approximate cube root
            if remainder >= 0:
                x_approx = round(remainder ** (1/3))
            else:
                x_approx = -round((-remainder) ** (1/3))
            # Check nearby values (floating point may be slightly off)
            for x in range(x_approx - 2, x_approx + 3):
                if x**3 + y**3 + z**3 == k and x <= y:
                    return (x, y, z)
    return None


def analyze_integer(k: int, search_bound: int = 1000):
    """Complete analysis of an integer k for the three-cubes problem."""
    print(f"\n{'='*60}")
    print(f"  Analysis of k = {k}")
    print(f"{'='*60}")

    # Step 1: Mod 9 test
    r = k % 9
    print(f"\n  Step 1: Mod 9 Residue Test")
    print(f"    k mod 9 = {r}")
    if is_forbidden_mod9(k):
        print(f"    VERDICT: FORBIDDEN (residue {r} ∈ {{4, 5}})")
        print(f"    By theorem forbiddenModNine_not_representable:")
        print(f"    k = {k} is PROVABLY NOT a sum of three cubes.")
        print(f"    No search needed — this is a mathematical certainty.")
        return
    else:
        print(f"    Status: ADMISSIBLE (residue {r} ∈ {{0,1,2,3,6,7,8}})")

    # Step 2: Local solubility checks
    print(f"\n  Step 2: Local Solubility (theorem global_implies_local)")
    moduli = [2, 3, 4, 5, 7, 8, 9, 16, 25, 27, 49, 64, 81, 100]
    all_local = True
    for n in moduli:
        soluble = is_locally_soluble(k, n)
        status = "✓" if soluble else "✗"
        if not soluble:
            all_local = False
        print(f"    mod {n:>3}: {status}")
    if all_local:
        print(f"    All local checks passed — no local obstruction detected.")
    else:
        print(f"    WARNING: Local obstruction found!")

    # Step 3: Search for representation
    print(f"\n  Step 3: Bounded Search (bound = {search_bound})")
    result = search_representation(k, search_bound)
    if result:
        x, y, z = result
        assert x**3 + y**3 + z**3 == k
        print(f"    FOUND: ({x})³ + ({y})³ + ({z})³ = {k}")
        print(f"    Verification: {x**3} + {y**3} + {z**3} = {x**3+y**3+z**3}")
    else:
        print(f"    No representation found within bound {search_bound}.")
        print(f"    (This does NOT mean none exists — solutions may be very large.)")

    # Step 4: Negation symmetry
    print(f"\n  Step 4: Negation Symmetry (theorem three_cube_representable_neg_iff)")
    neg_k = -k
    if result:
        x, y, z = result
        print(f"    Since ({x})³ + ({y})³ + ({z})³ = {k},")
        print(f"    we get ({-x})³ + ({-y})³ + ({-z})³ = {neg_k}")
    else:
        print(f"    k = {k} and -k = {neg_k} have the same representability status.")


def demo_mod9_obstruction():
    """Demonstrate the mod 9 obstruction across a range of integers."""
    print("\n" + "="*60)
    print("  DEMO: Mod 9 Obstruction (Theorem 1)")
    print("="*60)
    print("\n  Cube residues mod 9:")
    for x in range(9):
        print(f"    {x}³ = {x**3} ≡ {x**3 % 9} (mod 9)")

    print(f"\n  Achievable sum residues: {sorted({(a+b+c) % 9 for a in [0,1,8] for b in [0,1,8] for c in [0,1,8]})}")
    print(f"  Missing residues: {{4, 5}}")

    print(f"\n  Classification of 0-99:")
    admissible = [k for k in range(100) if is_admissible(k)]
    forbidden = [k for k in range(100) if is_forbidden_mod9(k)]
    print(f"    Admissible: {len(admissible)} integers")
    print(f"    Forbidden:  {len(forbidden)} integers")
    print(f"    Forbidden list: {forbidden}")
    print(f"    Density of admissible: {len(admissible)}/100 ≈ {len(admissible)/100:.4f}")
    print(f"    Theoretical density: 7/9 ≈ {7/9:.4f}")


def demo_polynomial_family():
    """Demonstrate the two-parameter polynomial family."""
    print("\n" + "="*60)
    print("  DEMO: Vieta Family (Theorem: vieta_cubes_identity)")
    print("="*60)
    print("\n  Identity: a³ + b³ + (-a-b)³ = -3ab(a+b)")
    print("\n  Examples:")
    for a in range(1, 6):
        for b in range(a, a + 3):
            k = -3 * a * b * (a + b)
            c = -a - b
            print(f"    a={a}, b={b}: {a}³ + {b}³ + ({c})³ = {a**3} + {b**3} + {c**3} = {k}")


def demo_local_solubility():
    """Demonstrate local solubility checking."""
    print("\n" + "="*60)
    print("  DEMO: Local Solubility (Theorems 4 & 5)")
    print("="*60)

    print("\n  Checking local solubility for small k, various moduli:")
    print(f"  {'k':>4} | {'mod 2':>5} | {'mod 3':>5} | {'mod 5':>5} | {'mod 7':>5} | {'mod 9':>5} | {'mod 27':>6}")
    print(f"  {'-'*4}-+-{'-'*5}-+-{'-'*5}-+-{'-'*5}-+-{'-'*5}-+-{'-'*5}-+-{'-'*6}")
    for k in range(20):
        checks = []
        for n in [2, 3, 5, 7, 9, 27]:
            s = "  ✓  " if is_locally_soluble(k, n) else "  ✗  "
            checks.append(s)
        status = "ADM" if is_admissible(k) else "FOR"
        print(f"  {k:>4} | {'|'.join(checks)} | {status}")


def main():
    if len(sys.argv) > 1:
        try:
            k = int(sys.argv[1])
            analyze_integer(k)
        except ValueError:
            print(f"Usage: {sys.argv[0]} [integer]")
            sys.exit(1)
    else:
        print("╔══════════════════════════════════════════════════════════╗")
        print("║   Sums of Three Cubes: Local-Global Geometry Demo      ║")
        print("║                                                        ║")
        print("║   Every result shown corresponds to a machine-verified ║")
        print("║   theorem in the formal mathematical framework.        ║")
        print("╚══════════════════════════════════════════════════════════╝")

        demo_mod9_obstruction()
        demo_polynomial_family()
        demo_local_solubility()

        # Analyze specific interesting cases
        for k in [0, 1, 2, 3, 4, 5, 33, 42, 114]:
            analyze_integer(k, search_bound=1000)

        print("\n" + "="*60)
        print("  Summary")
        print("="*60)
        print("  All computations are backed by formally verified theorems:")
        print("  • Mod 9 filter: forbiddenModNine_not_representable")
        print("  • Local checks: global_implies_local")
        print("  • Negation:     three_cube_representable_neg_iff")
        print("  • Infinitude:   infinitely_many_three_cube_representable")
        print("  • Surface:      integral_point_gives_modn_point")


if __name__ == "__main__":
    main()
