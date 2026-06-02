#!/usr/bin/env python3
"""
Algorithms for Taxicab Numbers and Sums of Cubes

Type-hinted implementations of key algorithms:
1. Three-Cube Inversion Search
2. Two-Cube Representation Finder
3. Mod-9 Admissibility Filter
4. Taxicab Number Search
"""

from typing import Optional


def is_perfect_cube(n: int) -> Optional[int]:
    """Return the cube root of n if n is a perfect cube, else None."""
    if n == 0:
        return 0
    sign = 1 if n > 0 else -1
    approx = round(abs(n) ** (1 / 3))
    for r in [approx - 1, approx, approx + 1]:
        if r >= 0 and r ** 3 == abs(n):
            return sign * r
    return None


def find_two_cube_reps(n: int) -> list[tuple[int, int]]:
    """Find all representations n = a³ + b³ with 0 < a ≤ b.

    Time complexity: O(n^{1/3})
    """
    reps: list[tuple[int, int]] = []
    a = 1
    while 2 * a ** 3 <= n:
        remainder = n - a ** 3
        root = is_perfect_cube(remainder)
        if root is not None and root >= a and root > 0:
            reps.append((a, root))
        a += 1
    return reps


def three_cube_inversion_search(
    n: int, c_max: int = 100
) -> list[tuple[int, int, int]]:
    """Find nontrivial three-cube representations of n using the inversion principle.

    For each c in [1, c_max], compute overshoot = c³ - n.
    If overshoot = a³ + b³ with a, b > 0, then n = (-a)³ + (-b)³ + c³.

    Also checks negative c: if (-c)³ - n = -(c³ + n), we look for
    c³ + n = a³ + b³.

    Time complexity: O(c_max · n^{1/3})
    """
    results: list[tuple[int, int, int]] = []

    for c in range(1, c_max + 1):
        # Positive c: overshoot = c³ - n
        overshoot = c ** 3 - n
        if overshoot > 0:
            for a, b in find_two_cube_reps(overshoot):
                results.append((-a, -b, c))

        # Negative c: need (-c)³ + y³ + z³ = n, so y³ + z³ = n + c³
        target = n + c ** 3
        if target > 0:
            for a, b in find_two_cube_reps(target):
                if a > 0 and b > 0:
                    results.append((-c, a, b))

    return results


def is_mod9_admissible(n: int) -> bool:
    """Check if n is admissible for sum-of-three-cubes (not ≡ 4, 5 mod 9)."""
    return n % 9 not in {4, 5}


def find_taxicab_numbers(limit: int) -> list[tuple[int, list[tuple[int, int]]]]:
    """Find all taxicab numbers up to limit.

    A taxicab number has at least 2 distinct representations as a³ + b³.

    Time complexity: O(limit^{4/3})
    """
    results: list[tuple[int, list[tuple[int, int]]]] = []
    for n in range(2, limit + 1):
        reps = find_two_cube_reps(n)
        if len(reps) >= 2:
            results.append((n, reps))
    return results


def cube_factorization(a: int, b: int) -> tuple[int, int]:
    """Compute the algebraic factorization a³ + b³ = (a+b)(a²-ab+b²).

    Returns (a+b, a²-ab+b²).
    """
    return (a + b, a ** 2 - a * b + b ** 2)


def brute_force_three_cubes(
    n: int, bound: int = 100
) -> list[tuple[int, int, int]]:
    """Brute-force search for x³ + y³ + z³ = n with all nonzero, |x|,|y|,|z| ≤ bound.

    Returns ordered triples (x ≤ y ≤ z).
    """
    results: list[tuple[int, int, int]] = []
    for x in range(-bound, bound + 1):
        if x == 0:
            continue
        for y in range(x, bound + 1):
            if y == 0:
                continue
            rem = n - x ** 3 - y ** 3
            if rem == 0:
                continue
            root = is_perfect_cube(rem)
            if root is not None and root >= y and root != 0:
                results.append((x, y, root))
    return results


def taxicab_analysis(n: int) -> dict:
    """Complete analysis of a number's cube decomposition properties."""
    two_reps = find_two_cube_reps(n)
    three_reps = brute_force_three_cubes(n, bound=200)
    inversion_reps = three_cube_inversion_search(n, c_max=200)

    factors = []
    for a, b in two_reps:
        s, q = cube_factorization(a, b)
        factors.append({"a": a, "b": b, "sum": s, "norm": q, "product": s * q})

    return {
        "n": n,
        "mod9": n % 9,
        "admissible": is_mod9_admissible(n),
        "two_cube_reps": two_reps,
        "three_cube_reps_brute": three_reps,
        "three_cube_reps_inversion": inversion_reps,
        "algebraic_factors": factors,
        "is_taxicab": len(two_reps) >= 2,
    }


if __name__ == "__main__":
    # Demo: analyze 1729
    analysis = taxicab_analysis(1729)
    print(f"Analysis of {analysis['n']}:")
    print(f"  mod 9 = {analysis['mod9']} ({'admissible' if analysis['admissible'] else 'obstructed'})")
    print(f"  Two-cube reps: {analysis['two_cube_reps']}")
    print(f"  Three-cube reps (brute): {analysis['three_cube_reps_brute']}")
    print(f"  Three-cube reps (inversion): {analysis['three_cube_reps_inversion']}")
    print(f"  Algebraic factors: {analysis['algebraic_factors']}")
    print(f"  Is taxicab: {analysis['is_taxicab']}")

    # Find all taxicab numbers up to 100000
    print("\nTaxicab numbers up to 100000:")
    for n, reps in find_taxicab_numbers(100000):
        print(f"  {n}: {reps}")
