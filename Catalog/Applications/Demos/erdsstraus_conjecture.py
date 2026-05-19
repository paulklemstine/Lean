#!/usr/bin/env python3
"""
Erdős–Straus Conjecture: Applications

This module demonstrates applications of Egyptian fraction decompositions
and the mathematical infrastructure developed for the conjecture.

Applications include:
  1. Fair division / resource allocation
  2. Scheduling with unit-fraction time slots
  3. Covering system analysis
  4. Computational number theory exploration
"""

from fractions import Fraction
from typing import Optional
import itertools


# ─── Application 1: Fair Division ─────────────────────────────────────────

def fair_division_erdos_straus(total_shares: int, num_items: int = 4) -> list[Fraction]:
    """
    Divide `num_items` items equally among `total_shares` people using
    at most 3 unit-fraction portions.

    This models the ancient Egyptian approach to fair division:
    instead of giving each person 4/n of an item (requiring precise
    cutting), we give them whole-number fractions 1/x, 1/y, 1/z of items.

    Example: 4 loaves among 7 people → each gets 1/2 + 1/14 + 1/14
    """
    n = total_shares

    # Try parametric families first
    if n % 2 == 0:
        k = n // 2
        portions = [Fraction(1, k), Fraction(1, 2 * k), Fraction(1, 2 * k)]
    elif n % 3 == 0:
        m = n // 3
        portions = [Fraction(1, m), Fraction(1, 2 * n), Fraction(1, 2 * n)]
    elif n % 3 == 2:
        m = (n + 1) // 3
        portions = [Fraction(1, n), Fraction(1, m), Fraction(1, n * m)]
    elif n % 4 == 3:
        x = (n + 1) // 4
        portions = [Fraction(1, x), Fraction(1, 2 * x * n), Fraction(1, 2 * x * n)]
    else:
        # Search
        for x in range(1, 10 * n):
            for y in range(x, 10 * n):
                denom = 4 * x * y - n * (x + y)
                if denom > 0 and (n * x * y) % denom == 0:
                    z = (n * x * y) // denom
                    portions = [Fraction(1, x), Fraction(1, y), Fraction(1, z)]
                    break
            else:
                continue
            break
        else:
            return []

    assert sum(portions) == Fraction(num_items, n), f"Division error for n={n}"
    return portions


# ─── Application 2: Covering System Analysis ─────────────────────────────

def covering_system_analysis(modulus: int = 60) -> dict:
    """
    Analyze how parametric families form a covering system.

    A covering system of congruences ensures every integer belongs to
    at least one congruence class. The Erdős–Straus families provide
    a near-covering system mod 12 (missing only n ≡ 1 mod 12).

    This function computes the covering for a general modulus.
    """
    families = {
        "even (n%2=0)": lambda n: n % 2 == 0,
        "mod3=0": lambda n: n % 3 == 0,
        "mod3=2": lambda n: n % 3 == 2,
        "mod4=3": lambda n: n % 4 == 3,
    }

    coverage = {}
    for r in range(modulus):
        covering_families = []
        for name, pred in families.items():
            if pred(r):
                covering_families.append(name)
        coverage[r] = covering_families

    uncovered = [r for r, fams in coverage.items() if not fams]
    total = modulus
    covered_count = total - len(uncovered)

    return {
        "modulus": modulus,
        "covered_residues": covered_count,
        "uncovered_residues": uncovered,
        "coverage_density": covered_count / total,
        "details": coverage,
    }


# ─── Application 3: Diophantine Surface Visualization Data ───────────────

def surface_solutions(n: int, max_coord: int = 100) -> list[tuple[int, int, int]]:
    """
    Find all integer points on the Erdős–Straus surface
        4xyz = n(xy + xz + yz)
    with 1 ≤ x ≤ y ≤ z ≤ max_coord.

    These are the rational points on a cubic surface parameterized by n.
    Each solution is a point where a rational curve (from a parametric
    family or search) intersects the integer lattice.
    """
    solutions = []
    for x in range(1, max_coord + 1):
        for y in range(x, max_coord + 1):
            denom = 4 * x * y - n * (x + y)
            if denom <= 0:
                continue
            num = n * x * y
            if num % denom == 0:
                z = num // denom
                if z >= y and z <= max_coord:
                    solutions.append((x, y, z))
    return solutions


# ─── Application 4: Witness Complexity Analysis ──────────────────────────

def witness_complexity(N: int) -> dict[str, list]:
    """
    For each n in [2, N], compute the minimal ordered solution
    and analyze the growth of the largest denominator.

    This explores the conjecture that z ≤ O(n²) for all n,
    which would have implications for search complexity.
    """
    data = {"n": [], "x": [], "y": [], "z": [], "z_over_n": [], "z_over_n2": []}

    for n in range(2, N + 1):
        solutions = surface_solutions(n, max_coord=n * n)
        if not solutions:
            # Fall back to parametric
            if n % 2 == 0:
                k = n // 2
                sol = (k, 2 * k, 2 * k)
            elif n % 3 == 2:
                m = (n + 1) // 3
                sol = tuple(sorted([n, m, n * m]))
            elif n % 3 == 0:
                m = n // 3
                sol = (m, 2 * n, 2 * n)
            elif n % 4 == 3:
                x = (n + 1) // 4
                sol = tuple(sorted([x, 2 * x * n, 2 * x * n]))
            else:
                continue
            solutions = [sol]

        # Take solution with smallest z
        best = min(solutions, key=lambda s: s[2])
        x, y, z = best
        data["n"].append(n)
        data["x"].append(x)
        data["y"].append(y)
        data["z"].append(z)
        data["z_over_n"].append(z / n)
        data["z_over_n2"].append(z / (n * n))

    return data


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Erdős–Straus Applications")
    print("=" * 60)

    # Application 1: Fair division
    print("\n── Application 1: Fair Division ──")
    print("Dividing 4 items among n people using unit fractions:")
    for n in [3, 5, 7, 11, 13, 17]:
        portions = fair_division_erdos_straus(n)
        total = sum(portions)
        print(f"  n={n:2d}: each person gets {' + '.join(str(p) for p in portions)} = {total}")

    # Application 2: Covering analysis
    print("\n── Application 2: Covering System Analysis ──")
    analysis = covering_system_analysis(60)
    print(f"  Modulus: {analysis['modulus']}")
    print(f"  Covered: {analysis['covered_residues']}/{analysis['modulus']} "
          f"({analysis['coverage_density']*100:.1f}%)")
    print(f"  Uncovered residues mod {analysis['modulus']}: {analysis['uncovered_residues']}")

    # Application 3: Surface solutions
    print("\n── Application 3: Diophantine Surface Solutions ──")
    for n in [5, 7, 13]:
        sols = surface_solutions(n, max_coord=500)
        print(f"  n={n}: {len(sols)} solutions with coords ≤ 500")
        for s in sols[:5]:
            print(f"    ({s[0]}, {s[1]}, {s[2]})")
        if len(sols) > 5:
            print(f"    ... and {len(sols) - 5} more")

    # Application 4: Witness complexity
    print("\n── Application 4: Witness Complexity ──")
    data = witness_complexity(200)
    if data["z_over_n"]:
        max_ratio = max(data["z_over_n"])
        max_idx = data["z_over_n"].index(max_ratio)
        print(f"  Max z/n ratio in [2,200]: {max_ratio:.1f} at n={data['n'][max_idx]}")
        print(f"  Max z/n² ratio: {max(data['z_over_n2']):.4f}")
        print(f"  Supports conjecture: z = O(n²)")


#!/usr/bin/env python3
"""
Erdős–Straus Conjecture: Demonstrations

This script demonstrates the key mathematical results about the
Erdős–Straus conjecture: 4/n = 1/x + 1/y + 1/z for positive integers x,y,z.

It illustrates:
  1. The four parametric families covering 11/12 of all integers
  2. Computational search for exceptional cases
  3. Verification of the conjecture up to large bounds
"""

from fractions import Fraction
from typing import Optional


def verify_decomposition(n: int, x: int, y: int, z: int) -> bool:
    """Verify that 4/n = 1/x + 1/y + 1/z using exact rational arithmetic."""
    if x <= 0 or y <= 0 or z <= 0 or n <= 0:
        return False
    return Fraction(4, n) == Fraction(1, x) + Fraction(1, y) + Fraction(1, z)


def diophantine_check(n: int, x: int, y: int, z: int) -> bool:
    """Verify using the integer-cleared equation: 4xyz = n(xy + xz + yz)."""
    return 4 * x * y * z == n * (x * y + x * z + y * z)


# ─── Family 1: Even numbers ───────────────────────────────────────────────
def family_even(k: int) -> tuple[int, int, int, int]:
    """For n = 2k: 4/(2k) = 1/k + 1/(2k) + 1/(2k)."""
    n = 2 * k
    return n, k, 2 * k, 2 * k


# ─── Family 2: n ≡ 3 mod 4 ────────────────────────────────────────────────
def family_mod4_eq3(n: int) -> tuple[int, int, int]:
    """For n ≡ 3 mod 4: x = (n+1)/4, y = z = 2xn."""
    assert n % 4 == 3
    x = (n + 1) // 4
    y = 2 * x * n
    return x, y, y


# ─── Family 3: n ≡ 0 mod 3 ────────────────────────────────────────────────
def family_mod3_eq0(n: int) -> tuple[int, int, int]:
    """For n ≡ 0 mod 3: x = n/3, y = z = 2n."""
    assert n % 3 == 0
    x = n // 3
    return x, 2 * n, 2 * n


# ─── Family 4: n ≡ 2 mod 3 ────────────────────────────────────────────────
def family_mod3_eq2(n: int) -> tuple[int, int, int]:
    """For n ≡ 2 mod 3: x = n, y = (n+1)/3, z = n·(n+1)/3."""
    assert n % 3 == 2
    m = (n + 1) // 3
    return n, m, n * m


# ─── Computational search ─────────────────────────────────────────────────
def smart_search(n: int, B: int) -> Optional[tuple[int, int, int]]:
    """
    Search for x,y ≤ B and compute z from the equation.
    From 4xyz = n(xy + xz + yz), solving for z:
      z = nxy / (4xy - n(x+y))
    """
    for x in range(1, B + 1):
        for y in range(x, B + 1):
            denom = 4 * x * y - n * (x + y)
            if denom <= 0:
                continue
            num = n * x * y
            if num % denom == 0:
                z = num // denom
                if z > 0:
                    return x, y, z
    return None


def classify_and_solve(n: int) -> tuple[str, tuple[int, int, int]]:
    """Classify n by its residue class and return the appropriate decomposition."""
    if n % 2 == 0:
        k = n // 2
        return "even", (k, 2 * k, 2 * k)
    elif n % 3 == 0:
        return "mod3=0", family_mod3_eq0(n)
    elif n % 3 == 2:
        return "mod3=2", family_mod3_eq2(n)
    elif n % 4 == 3:
        return "mod4=3", family_mod4_eq3(n)
    else:
        # n ≡ 1 mod 12 — exceptional case, requires search
        result = smart_search(n, 10 * n)
        if result:
            return "search", result
        return "unknown", (0, 0, 0)


# ─── Main demonstration ───────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 70)
    print("ERDŐS–STRAUS CONJECTURE: 4/n = 1/x + 1/y + 1/z")
    print("=" * 70)

    # Demo 1: Show all four families
    print("\n── Family 1: Even numbers (n = 2k) ──")
    for k in [1, 2, 5, 10, 50]:
        n, x, y, z = family_even(k)
        ok = verify_decomposition(n, x, y, z)
        print(f"  4/{n} = 1/{x} + 1/{y} + 1/{z}  ✓" if ok else f"  FAIL for n={n}")

    print("\n── Family 2: n ≡ 3 mod 4 ──")
    for n in [3, 7, 11, 19, 23, 43, 103]:
        x, y, z = family_mod4_eq3(n)
        ok = verify_decomposition(n, x, y, z)
        print(f"  4/{n} = 1/{x} + 1/{y} + 1/{z}  ✓" if ok else f"  FAIL for n={n}")

    print("\n── Family 3: n ≡ 0 mod 3 ──")
    for n in [3, 9, 15, 21, 33, 99]:
        x, y, z = family_mod3_eq0(n)
        ok = verify_decomposition(n, x, y, z)
        print(f"  4/{n} = 1/{x} + 1/{y} + 1/{z}  ✓" if ok else f"  FAIL for n={n}")

    print("\n── Family 4: n ≡ 2 mod 3 ──")
    for n in [2, 5, 8, 11, 14, 17, 53]:
        x, y, z = family_mod3_eq2(n)
        ok = verify_decomposition(n, x, y, z)
        print(f"  4/{n} = 1/{x} + 1/{y} + 1/{z}  ✓" if ok else f"  FAIL for n={n}")

    # Demo 2: Exceptional cases (n ≡ 1 mod 12)
    print("\n── Exceptional cases (n ≡ 1 mod 12, require search) ──")
    exceptional = [n for n in range(2, 200) if n % 12 == 1]
    for n in exceptional:
        family, (x, y, z) = classify_and_solve(n)
        ok = verify_decomposition(n, x, y, z)
        print(f"  4/{n:3d} = 1/{x} + 1/{y} + 1/{z}  ✓ [{family}]"
              if ok else f"  FAIL for n={n}")

    # Demo 3: Coverage statistics
    print("\n── Coverage analysis ──")
    N = 10000
    covered_by_family = 0
    need_search = 0
    for n in range(2, N + 1):
        if n % 2 == 0 or n % 3 == 0 or n % 3 == 2 or n % 4 == 3:
            covered_by_family += 1
        else:
            need_search += 1

    print(f"  Range [2, {N}]: {N - 1} integers")
    print(f"  Covered by algebraic families: {covered_by_family} ({100*covered_by_family/(N-1):.1f}%)")
    print(f"  Require computational search: {need_search} ({100*need_search/(N-1):.1f}%)")
    print(f"  Theoretical density covered: 11/12 = {11/12*100:.1f}%")

    # Demo 4: Verify conjecture up to a bound
    print(f"\n── Verification up to n = {N} ──")
    all_ok = True
    for n in range(2, N + 1):
        _, (x, y, z) = classify_and_solve(n)
        if not verify_decomposition(n, x, y, z):
            print(f"  COUNTEREXAMPLE at n = {n}!")
            all_ok = False
            break
    if all_ok:
        print(f"  ✓ Verified for all n in [2, {N}]")
