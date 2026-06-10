#!/usr/bin/env python3
"""
algorithms.py — Perfect Cuboid Search Algorithms

Type-hinted implementations of algorithms for searching for
Euler bricks, near-miss perfect cuboids, and testing modular constraints.
"""

import math
from typing import Iterator, Optional


def is_perfect_square(n: int) -> bool:
    """O(1) perfect square test using integer square root."""
    if n < 0:
        return False
    r = int(math.isqrt(n))
    return r * r == n


def pythagorean_triples(bound: int) -> Iterator[tuple[int, int, int]]:
    """
    Generate all primitive Pythagorean triples (a, b, c) with a < b < c ≤ bound.
    Uses the parametrization: a = m²-n², b = 2mn, c = m²+n²
    where m > n > 0, gcd(m,n) = 1, m-n odd.
    """
    for m in range(2, int(math.isqrt(bound)) + 1):
        for n in range(1, m):
            if math.gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            a = m * m - n * n
            b = 2 * m * n
            c = m * m + n * n
            if c > bound:
                break
            if a > b:
                a, b = b, a
            yield (a, b, c)


def euler_brick_search(bound: int) -> list[tuple[int, int, int]]:
    """
    Search for Euler bricks with edges ≤ bound.

    Algorithm: For each pair (x, y) with x²+y² a perfect square,
    check all z > y where x²+z² and y²+z² are also perfect squares.

    Complexity: O(bound² · √bound) with early pruning.
    """
    bricks: list[tuple[int, int, int]] = []
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            s_xy = x * x + y * y
            if not is_perfect_square(s_xy):
                continue
            for z in range(y, bound + 1):
                s_xz = x * x + z * z
                s_yz = y * y + z * z
                if is_perfect_square(s_xz) and is_perfect_square(s_yz):
                    bricks.append((x, y, z))
    return bricks


def near_miss_search(
    bound: int,
    max_defect: int = 100
) -> list[tuple[int, int, int, int, float]]:
    """
    Search for near-miss perfect cuboids: Euler bricks where
    the space diagonal is close to an integer.

    Returns: List of (x, y, z, defect, relative_error) sorted by defect.
    """
    results: list[tuple[int, int, int, int, float]] = []
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            if not is_perfect_square(x*x + y*y):
                continue
            for z in range(y, bound + 1):
                if not (is_perfect_square(x*x + z*z) and
                        is_perfect_square(y*y + z*z)):
                    continue
                s = x*x + y*y + z*z
                r = int(math.isqrt(s))
                defect = s - r * r
                if defect <= max_defect:
                    rel_err = defect / s if s > 0 else 0.0
                    results.append((x, y, z, defect, rel_err))
    results.sort(key=lambda t: t[3])
    return results


def saunderson_family(max_param: int = 20) -> list[tuple[int, int, int]]:
    """
    Generate Euler bricks from the Saunderson (1740) parametrization.

    Given a Pythagorean triple (u, v, w) with u²+v²=w²,
    the edges (u|4v²-w²|, v|4u²-w²|, 4uvw) form an Euler brick.

    Args:
        max_param: Maximum value for the generating parameter m.

    Returns:
        List of Euler brick triples.
    """
    bricks: list[tuple[int, int, int]] = []
    seen: set[tuple[int, int, int]] = set()

    for m in range(2, max_param + 1):
        for n in range(1, m):
            if math.gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            u = m*m - n*n
            v = 2*m*n
            w = m*m + n*n

            x = abs(u * (4*v*v - w*w))
            y = abs(v * (4*u*u - w*w))
            z = abs(4 * u * v * w)

            if x == 0 or y == 0 or z == 0:
                continue

            triple = tuple(sorted([x, y, z]))
            if triple not in seen:
                seen.add(triple)
                bricks.append(triple)

    return bricks


def modular_sieve(bound: int) -> dict[str, int]:
    """
    Apply modular arithmetic constraints to estimate the density
    of potential perfect cuboids.

    Checks:
    1. At least two edges even (proved in Lean)
    2. One edge divisible by 3
    3. One edge divisible by 5
    4. Space diagonal sum ≢ 2,3 mod 4

    Returns: Dictionary with constraint violation counts.
    """
    stats: dict[str, int] = {
        "total_tested": 0,
        "pass_parity": 0,
        "pass_mod3": 0,
        "pass_mod4": 0,
        "pass_all": 0,
    }

    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            for z in range(y, bound + 1):
                stats["total_tested"] += 1
                s = x*x + y*y + z*z

                # Parity: at least two even
                evens = sum(1 for e in [x, y, z] if e % 2 == 0)
                if evens < 2:
                    continue
                stats["pass_parity"] += 1

                # Mod 4: s must be 0 or 1 mod 4
                if s % 4 in (2, 3):
                    continue
                stats["pass_mod4"] += 1

                # Mod 3: at least one divisible by 3
                if not any(e % 3 == 0 for e in [x, y, z]):
                    continue
                stats["pass_mod3"] += 1

                stats["pass_all"] += 1

    return stats


def verify_diagonal_identity(
    x: int, y: int, z: int
) -> Optional[dict[str, int]]:
    """
    For an Euler brick (x,y,z), verify the diagonal identities:
    - a² + b² + c² = 2(x² + y² + z²)
    - d² = a² + z² (if d exists)

    Returns diagnostic dict or None if not an Euler brick.
    """
    if not (is_perfect_square(x*x+y*y) and is_perfect_square(x*x+z*z) and
            is_perfect_square(y*y+z*z)):
        return None

    a = int(math.isqrt(x*x + y*y))
    b = int(math.isqrt(x*x + z*z))
    c = int(math.isqrt(y*y + z*z))

    return {
        "x": x, "y": y, "z": z,
        "a": a, "b": b, "c": c,
        "a2_b2_c2": a*a + b*b + c*c,
        "2_x2_y2_z2": 2 * (x*x + y*y + z*z),
        "identity_holds": a*a + b*b + c*c == 2*(x*x + y*y + z*z),
        "space_diag_sq": x*x + y*y + z*z,
        "space_diag_is_square": is_perfect_square(x*x + y*y + z*z),
    }


if __name__ == "__main__":
    print("Saunderson family (first 10):")
    for brick in saunderson_family(10)[:10]:
        info = verify_diagonal_identity(*brick)
        print(f"  {brick} -> identity: {info['identity_holds']}, "
              f"defect: {info['space_diag_sq'] - int(math.isqrt(info['space_diag_sq']))**2}")

    print("\nModular sieve stats (bound=20):")
    stats = modular_sieve(20)
    for k, v in stats.items():
        print(f"  {k}: {v}")
