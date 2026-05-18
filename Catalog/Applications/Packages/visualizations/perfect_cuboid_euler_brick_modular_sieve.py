#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Perfect Cuboid and Euler Brick Analysis

Implements:
1. Modular sieve for perfect cuboid obstruction
2. Parametric Euler brick generation (Saunderson family)
3. Near-miss analysis with proximity measures
4. Surface point enumeration
"""

import math
from typing import Generator, Tuple, List, Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Modular Sieve
# ═══════════════════════════════════════════════════════════════

def quadratic_residues(m: int) -> set:
    """Compute the set of quadratic residues modulo m.

    Time: O(m), Space: O(m).

    >>> sorted(quadratic_residues(8))
    [0, 1, 4]
    """
    return {(k * k) % m for k in range(m)}


def modular_sieve(modulus: int) -> dict:
    """Run the modular sieve for perfect cuboid obstructions.

    For each parity pattern (even_count edges), determines which
    residue classes of x² + y² + z² (mod `modulus`) are achievable
    and which are quadratic residues.

    Time: O(modulus³), Space: O(modulus).

    Args:
        modulus: The modulus to sieve over.

    Returns:
        Dictionary with obstruction analysis per parity pattern.
    """
    qr = quadratic_residues(modulus)
    results = {}

    for even_count in range(4):
        # Generate all achievable residues for sum of squares
        achievable = set()
        for x in range(modulus):
            for y in range(modulus):
                for z in range(modulus):
                    parities = [x % 2 == 0, y % 2 == 0, z % 2 == 0]
                    if sum(parities) != even_count:
                        continue
                    s = (x**2 + y**2 + z**2) % modulus
                    achievable.add(s)

        valid = achievable & qr
        results[even_count] = {
            "achievable_residues": sorted(achievable),
            "quadratic_residues": sorted(qr),
            "valid_residues": sorted(valid),
            "obstructed": len(valid) == 0,
            "obstruction_ratio": 1 - len(valid) / max(len(achievable), 1),
        }

    return results


def print_sieve_results(modulus: int):
    """Print formatted modular sieve results."""
    results = modular_sieve(modulus)
    print(f"\nModular Sieve Analysis (mod {modulus})")
    print("-" * 60)
    for even_count, data in results.items():
        status = "OBSTRUCTED" if data["obstructed"] else "possible"
        print(f"  {even_count} even edges: {status}")
        if data["obstructed"]:
            print(f"    Achievable residues: {data['achievable_residues']}")
            print(f"    None are quadratic residues!")
        else:
            print(f"    Valid residues: {data['valid_residues']}")
            print(f"    Obstruction ratio: {data['obstruction_ratio']:.1%}")


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Parametric Euler Brick Generation
# ═══════════════════════════════════════════════════════════════

@dataclass
class EulerBrick:
    """An Euler brick with edges and face diagonals."""
    x: int
    y: int
    z: int
    diag_xy: int
    diag_xz: int
    diag_yz: int
    space_diag_sq: int  # x² + y² + z² (may not be a perfect square)

    @property
    def is_perfect_cuboid(self) -> bool:
        r = int(math.isqrt(self.space_diag_sq))
        return r * r == self.space_diag_sq

    @property
    def space_diagonal_gap(self) -> float:
        """Distance from space diagonal to nearest integer."""
        s = math.sqrt(self.space_diag_sq)
        return abs(s - round(s))


def saunderson_family(u: int, v: int, w: int) -> Optional[EulerBrick]:
    """Generate an Euler brick using the Saunderson parametrization (1740).

    Given a Pythagorean triple (u, v, w) with u² + v² = w², produces:
        x = u(4v² - w²)
        y = v(4u² - w²)
        z = 4uvw

    Time: O(1).

    Args:
        u, v, w: A Pythagorean triple with u² + v² = w².

    Returns:
        An EulerBrick if the parameters produce positive edges, else None.
    """
    if u**2 + v**2 != w**2:
        return None

    x = abs(u * (4 * v**2 - w**2))
    y = abs(v * (4 * u**2 - w**2))
    z = abs(4 * u * v * w)

    if x == 0 or y == 0 or z == 0:
        return None

    # Verify face diagonals
    def isqrt_checked(n):
        r = int(math.isqrt(n))
        assert r * r == n, f"{n} is not a perfect square"
        return r

    try:
        dxy = isqrt_checked(x**2 + y**2)
        dxz = isqrt_checked(x**2 + z**2)
        dyz = isqrt_checked(y**2 + z**2)
    except AssertionError:
        return None

    return EulerBrick(x, y, z, dxy, dxz, dyz, x**2 + y**2 + z**2)


def generate_pythagorean_triples(limit: int) -> Generator[Tuple[int, int, int], None, None]:
    """Generate primitive Pythagorean triples (a, b, c) with a < b < c ≤ limit.

    Uses the standard parametrization: a = m²-n², b = 2mn, c = m²+n²
    with m > n > 0, gcd(m,n)=1, m-n odd.

    Time: O(limit), Space: O(1) (generator).
    """
    for m in range(2, int(math.isqrt(limit)) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if math.gcd(m, n) != 1:
                continue
            a = m**2 - n**2
            b = 2 * m * n
            c = m**2 + n**2
            if c > limit:
                break
            yield (min(a, b), max(a, b), c)


def generate_euler_bricks(max_param: int = 100) -> List[EulerBrick]:
    """Generate Euler bricks from the Saunderson family.

    Time: O(max_param²), Space: O(output size).
    """
    bricks = []
    for u, v, w in generate_pythagorean_triples(max_param):
        brick = saunderson_family(u, v, w)
        if brick is not None:
            bricks.append(brick)
        # Also try scaled versions
        brick2 = saunderson_family(v, u, w)
        if brick2 is not None and brick2 not in bricks:
            bricks.append(brick2)
    return bricks


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Near-Miss Analysis
# ═══════════════════════════════════════════════════════════════

def near_miss_score(brick: EulerBrick) -> float:
    """Compute how close an Euler brick is to being a perfect cuboid.

    Returns the fractional part of the space diagonal.
    A score of 0 means it IS a perfect cuboid.

    Time: O(1).
    """
    return brick.space_diagonal_gap


def find_best_near_misses(bricks: List[EulerBrick], top_n: int = 10) -> List[EulerBrick]:
    """Find the Euler bricks closest to being perfect cuboids.

    Time: O(n log n) where n = len(bricks).
    """
    return sorted(bricks, key=near_miss_score)[:top_n]


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Surface Point Enumeration
# ═══════════════════════════════════════════════════════════════

def enumerate_surface_points(denom_bound: int = 20) -> List[dict]:
    """Find rational points on w² = u² + v² - 1 with u² ≥ 1, v² ≥ 1.

    Searches over rationals p/q with |p|, q ≤ denom_bound.
    For each (u, v), checks if u² + v² - 1 is a perfect square in ℚ.

    Time: O(denom_bound⁴), Space: O(output size).
    """
    from fractions import Fraction
    points = []

    for qu in range(1, denom_bound + 1):
        for pu in range(qu, qu * denom_bound + 1):
            u = Fraction(pu, qu)
            for qv in range(1, denom_bound + 1):
                for pv in range(qv, qv * denom_bound + 1):
                    v = Fraction(pv, qv)
                    w_sq = u**2 + v**2 - 1
                    if w_sq < 0:
                        continue
                    # Check if w_sq is a perfect square in ℚ
                    num = w_sq.numerator
                    den = w_sq.denominator
                    if is_perfect_square(num) and is_perfect_square(den):
                        w = Fraction(int(math.isqrt(num)), int(math.isqrt(den)))
                        # Check additional constraints: u²-1 and v²-1 are squares
                        u2m1 = u**2 - 1
                        v2m1 = v**2 - 1
                        if (u2m1.numerator >= 0 and
                            is_perfect_square(abs(u2m1.numerator)) and
                            is_perfect_square(u2m1.denominator) and
                            v2m1.numerator >= 0 and
                            is_perfect_square(abs(v2m1.numerator)) and
                            is_perfect_square(v2m1.denominator)):
                            points.append({
                                "u": str(u), "v": str(v), "w": str(w),
                                "y/x": str(Fraction(
                                    int(math.isqrt(u2m1.numerator)),
                                    int(math.isqrt(u2m1.denominator))
                                )),
                                "z/x": str(Fraction(
                                    int(math.isqrt(v2m1.numerator)),
                                    int(math.isqrt(v2m1.denominator))
                                )),
                            })

    # Deduplicate
    seen = set()
    unique = []
    for p in points:
        key = (p["u"], p["v"])
        if key not in seen:
            seen.add(key)
            unique.append(p)
    return unique


# ═══════════════════════════════════════════════════════════════
# Main Execution
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM 1: Modular Sieve")
    print("=" * 70)
    for m in [4, 8, 16]:
        print_sieve_results(m)

    print("\n" + "=" * 70)
    print("ALGORITHM 2: Saunderson Euler Brick Family")
    print("=" * 70)
    bricks = generate_euler_bricks(50)
    print(f"\n  Generated {len(bricks)} Euler bricks from Saunderson family")
    for brick in bricks[:10]:
        print(f"    ({brick.x}, {brick.y}, {brick.z}): "
              f"diags=({brick.diag_xy}, {brick.diag_xz}, {brick.diag_yz}), "
              f"gap={brick.space_diagonal_gap:.6f}")

    print("\n" + "=" * 70)
    print("ALGORITHM 3: Near-Miss Analysis")
    print("=" * 70)
    if bricks:
        best = find_best_near_misses(bricks, 5)
        print("\n  Top 5 closest Euler bricks to perfect cuboids:")
        for i, brick in enumerate(best, 1):
            sd = math.sqrt(brick.space_diag_sq)
            print(f"    {i}. ({brick.x}, {brick.y}, {brick.z}): "
                  f"space_diag ≈ {sd:.6f}, gap = {brick.space_diagonal_gap:.8f}")

    print("\n" + "=" * 70)
    print("ALGORITHM 4: Surface Point Enumeration (small search)")
    print("=" * 70)
    points = enumerate_surface_points(8)
    print(f"\n  Found {len(points)} rational surface points with square constraints")
    for p in points[:10]:
        print(f"    u={p['u']}, v={p['v']}, w={p['w']}, y/x={p['y/x']}, z/x={p['z/x']}")

    print("\n" + "=" * 70)
    print("All algorithms complete.")
    print("=" * 70)
