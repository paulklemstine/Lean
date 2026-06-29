#!/usr/bin/env python3
"""
Perfect Cuboid Modular Sieve — Applications

Practical applications of the modular sieve for perfect cuboid search,
including search space pruning, targeted enumeration, and the rational
surface reduction.
"""

from math import gcd, isqrt
from itertools import product
from fractions import Fraction


# ============================================================================
# Application 1: Certified Search Pruning
# ============================================================================

def precompute_sieve_table(M: int) -> set[tuple[int, int, int]]:
    """
    Precompute the set of admissible residue classes mod M.

    This table can be used to prune a brute-force search for perfect
    cuboids: any triple (x,y,z) whose residues mod M are NOT in this
    table can be immediately skipped.

    Time: O(M^4) precomputation, O(1) lookup per candidate
    """
    qr = {(t * t) % M for t in range(M)}
    admissible = set()
    for x, y, z in product(range(M), repeat=3):
        s1 = (x * x + y * y) % M
        s2 = (x * x + z * z) % M
        s3 = (y * y + z * z) % M
        s4 = (x * x + y * y + z * z) % M
        if s1 in qr and s2 in qr and s3 in qr and s4 in qr:
            admissible.add((x, y, z))
    return admissible


def pruned_search(N: int, M: int = 105) -> list[dict]:
    """
    Search for perfect cuboids up to N using sieve-pruned enumeration.

    Instead of checking all O(N^3) triples, we precompute the admissible
    residue classes mod M and skip any triple that fails the modular test.
    This reduces work by a factor of ~81× for M=105.

    Args:
        N: Upper bound for edge lengths
        M: Sieve modulus (default 105)

    Returns:
        List of Euler bricks found (perfect cuboids would also appear)
    """
    print(f"  Precomputing sieve table mod {M}...")
    table = precompute_sieve_table(M)
    print(f"  Admissible classes: {len(table)}/{M**3} "
          f"({len(table)/M**3:.2%})")

    results = []
    checked = 0
    skipped = 0

    for x in range(1, N + 1):
        for y in range(x, N + 1):
            for z in range(y, N + 1):
                # Sieve check
                if (x % M, y % M, z % M) not in table:
                    skipped += 1
                    continue

                checked += 1

                # Full verification
                d1_sq = x * x + y * y
                d2_sq = x * x + z * z
                d3_sq = y * y + z * z
                space_sq = d1_sq + z * z

                d1 = isqrt(d1_sq)
                if d1 * d1 != d1_sq:
                    continue
                d2 = isqrt(d2_sq)
                if d2 * d2 != d2_sq:
                    continue
                d3 = isqrt(d3_sq)
                if d3 * d3 != d3_sq:
                    continue

                sp = isqrt(space_sq)
                is_perfect = sp * sp == space_sq

                result = {
                    "edges": (x, y, z),
                    "face_diags": (d1, d2, d3),
                    "is_euler_brick": True,
                    "is_perfect_cuboid": is_perfect,
                    "primitive": gcd(x, gcd(y, z)) == 1,
                }
                results.append(result)

    total_possible = sum(1 for x in range(1, N+1) for y in range(x, N+1)
                         for z in range(y, N+1))
    print(f"  Total triples ≤ {N}: {total_possible:,}")
    print(f"  Sieve-passed: {checked:,} ({checked/total_possible:.2%})")
    print(f"  Sieve-skipped: {skipped:,} ({skipped/total_possible:.2%})")
    print(f"  Euler bricks found: {len(results)}")

    return results


# ============================================================================
# Application 2: Rational Surface Analysis
# ============================================================================

def rational_surface_point(x: int, y: int, z: int,
                            a: int, b: int, d: int) -> dict:
    """
    Given a perfect cuboid candidate with face diagonals a, b and space
    diagonal d, compute the corresponding point on the rational surface
    w² = u² + v² - 1 with the constraint u² - 1 = (y/x)², v² - 1 = (z/x)².

    Args:
        x, y, z: Edge lengths
        a: sqrt(x² + y²)
        b: sqrt(x² + z²)
        d: sqrt(x² + y² + z²)

    Returns:
        Dictionary with rational surface coordinates
    """
    if x == 0:
        return {"error": "x must be nonzero for normalization"}

    u = Fraction(a, x)
    v = Fraction(b, x)
    w = Fraction(d, x)

    # Verify surface equation
    surface_eq = w ** 2 - u ** 2 - v ** 2 + 1
    u_constraint = u ** 2 - 1 - Fraction(y, x) ** 2
    v_constraint = v ** 2 - 1 - Fraction(z, x) ** 2

    return {
        "u": u, "v": v, "w": w,
        "y_over_x": Fraction(y, x),
        "z_over_x": Fraction(z, x),
        "surface_equation_satisfied": surface_eq == 0,
        "u_constraint_satisfied": u_constraint == 0,
        "v_constraint_satisfied": v_constraint == 0,
    }


def euler_brick_surface_points():
    """
    Compute rational surface points for known Euler bricks.

    These points satisfy the face-diagonal constraints but not
    the space diagonal (since they're not perfect cuboids).
    """
    bricks = [
        (44, 117, 240, 125, 244, 267),
        (85, 132, 720, 157, 725, 732),
    ]

    print("\n  Euler Brick → Rational Surface Points")
    print("  " + "-" * 50)
    for x, y, z, a, b, c in bricks:
        u = Fraction(a, x)
        v = Fraction(b, x)
        print(f"\n  Brick ({x}, {y}, {z}):")
        print(f"    u = a/x = {a}/{x} = {float(u):.6f}")
        print(f"    v = b/x = {b}/{x} = {float(v):.6f}")
        print(f"    u² - 1 = {u**2 - 1} = ({y}/{x})² = {Fraction(y,x)**2}")
        print(f"    v² - 1 = {v**2 - 1} = ({z}/{x})² = {Fraction(z,x)**2}")
        w_sq = u ** 2 + v ** 2 - 1
        print(f"    w² = u² + v² - 1 = {w_sq} = {float(w_sq):.6f}")
        # Check if w² is a perfect square (it won't be for Euler bricks)
        num = w_sq.numerator
        den = w_sq.denominator
        sn = isqrt(num)
        sd = isqrt(den)
        is_sq = sn * sn == num and sd * sd == den
        print(f"    w² is a perfect square in ℚ: {is_sq}")
        if is_sq:
            print(f"    w = {sn}/{sd}")


# ============================================================================
# Application 3: Multi-Modulus Sieve Cascade
# ============================================================================

def cascade_sieve(N: int, moduli: list[int] | None = None) -> dict:
    """
    Apply a cascade of modular sieves at multiple moduli.

    Each modulus independently filters candidates. A triple must pass
    ALL sieves to remain viable. The combined effect can be much stronger
    than any single modulus.

    Args:
        N: Number of random triples to test
        moduli: List of moduli (default: [3, 5, 7, 8, 105])
    """
    import random
    random.seed(42)

    if moduli is None:
        moduli = [3, 5, 7, 8, 105]

    tables = {}
    for M in moduli:
        tables[M] = precompute_sieve_table(M)

    results = {"total": N}
    survivors = N

    # Generate random triples and test
    triples = [(random.randint(1, 10**6),
                random.randint(1, 10**6),
                random.randint(1, 10**6))
               for _ in range(N)]

    for M in moduli:
        table = tables[M]
        passed = sum(1 for x, y, z in triples
                     if (x % M, y % M, z % M) in table)
        results[f"mod_{M}_survivors"] = passed
        results[f"mod_{M}_rate"] = passed / N

    # Combined
    combined = 0
    for x, y, z in triples:
        if all((x % M, y % M, z % M) in tables[M] for M in moduli):
            combined += 1
    results["combined_survivors"] = combined
    results["combined_rate"] = combined / N

    return results


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Perfect Cuboid Sieve — Applications")
    print("=" * 60)

    # Application 1: Pruned search
    print("\n--- Application 1: Pruned Search ---")
    bricks = pruned_search(300, M=105)
    for b in bricks:
        tag = "PERFECT CUBOID!" if b["is_perfect_cuboid"] else "Euler brick"
        prim = " (primitive)" if b["primitive"] else ""
        print(f"  {b['edges']}: {tag}{prim}, diags={b['face_diags']}")

    # Application 2: Rational surface
    print("\n--- Application 2: Rational Surface Points ---")
    euler_brick_surface_points()

    # Application 3: Cascade sieve statistics
    print("\n--- Application 3: Cascade Sieve (10000 random triples) ---")
    cascade = cascade_sieve(10000, [3, 7, 8, 105])
    for key, val in cascade.items():
        if key.endswith("_rate"):
            label = key.replace("_rate", "").replace("mod_", "Mod ")
            print(f"  {label}: {val:.4%} pass rate")
    print(f"  Combined: {cascade['combined_rate']:.4%} pass rate")
    print(f"  ({cascade['combined_survivors']}/{cascade['total']} survived)")


#!/usr/bin/env python3
"""
Perfect Cuboid Modular Sieve — Demonstrations

Concrete numerical demonstrations of the modular residue sieve for the
perfect cuboid problem. Shows how quadratic residue conditions modulo
small primes and their products dramatically reduce the search space.
"""

from itertools import product


def quadratic_residues(M: int) -> set[int]:
    """Compute the set of quadratic residues modulo M."""
    return {(t * t) % M for t in range(M)}


def is_square_mod(M: int, a: int, qr: set[int] | None = None) -> bool:
    """Check if a is a quadratic residue modulo M."""
    if qr is None:
        qr = quadratic_residues(M)
    return (a % M) in qr


def check_square_conditions(M: int, x: int, y: int, z: int,
                             qr: set[int] | None = None) -> bool:
    """Check all four face/space diagonal square conditions mod M."""
    if qr is None:
        qr = quadratic_residues(M)
    s1 = (x * x + y * y) % M
    s2 = (x * x + z * z) % M
    s3 = (y * y + z * z) % M
    s4 = (x * x + y * y + z * z) % M
    return s1 in qr and s2 in qr and s3 in qr and s4 in qr


def check_face_diagonals(M: int, x: int, y: int, z: int,
                          qr: set[int] | None = None) -> bool:
    """Check face diagonal conditions only (no space diagonal)."""
    if qr is None:
        qr = quadratic_residues(M)
    s1 = (x * x + y * y) % M
    s2 = (x * x + z * z) % M
    s3 = (y * y + z * z) % M
    return s1 in qr and s2 in qr and s3 in qr


def is_two_even_one_odd(x: int, y: int, z: int) -> bool:
    """Check if exactly two of x, y, z are even and one is odd."""
    parities = (x % 2, y % 2, z % 2)
    return parities in [(0, 0, 1), (0, 1, 0), (1, 0, 0)]


def run_sieve(M: int, verbose: bool = True) -> dict:
    """Run the complete modular sieve at modulus M."""
    qr = quadratic_residues(M)

    total = M ** 3
    parity_count = 0
    face_count = 0
    square_count = 0
    good_count = 0  # parity + all squares

    for x, y, z in product(range(M), repeat=3):
        parity_ok = is_two_even_one_odd(x, y, z)
        face_ok = check_face_diagonals(M, x, y, z, qr)
        square_ok = check_square_conditions(M, x, y, z, qr)

        if parity_ok:
            parity_count += 1
        if face_ok:
            face_count += 1
        if square_ok:
            square_count += 1
        if parity_ok and square_ok:
            good_count += 1

    result = {
        "M": M,
        "total": total,
        "parity_admissible": parity_count,
        "face_survivors": face_count,
        "square_survivors": square_count,
        "good_triples": good_count,
        "density_square": square_count / total,
        "density_good": good_count / total,
    }

    if verbose:
        print(f"\n{'='*60}")
        print(f"  Modular Sieve at M = {M}")
        print(f"{'='*60}")
        print(f"  Total residue classes:        {total:>10,}")
        print(f"  Parity-admissible:            {parity_count:>10,}")
        print(f"  Face-diagonal survivors:      {face_count:>10,}")
        print(f"  All-square survivors:         {square_count:>10,}")
        print(f"  Good triples (parity+square): {good_count:>10,}")
        print(f"  Square density:               {square_count/total:>10.4%}")
        print(f"  Good density:                 {good_count/total:>10.4%}")
        print(f"  Search reduction factor:      {total//max(square_count,1):>10}×")
        print(f"{'='*60}")

    return result


def demo_euler_brick_verification():
    """Demonstrate that known Euler bricks pass the face-diagonal sieve."""
    print("\n" + "=" * 60)
    print("  Known Euler Bricks — Sieve Verification")
    print("=" * 60)

    bricks = [
        (44, 117, 240, "Smallest known"),
        (240, 252, 275, "Second classic"),
        (85, 132, 720, "Third classic"),
    ]

    for x, y, z, name in bricks:
        # Verify face diagonals
        import math
        d1 = math.isqrt(x*x + y*y)
        d2 = math.isqrt(x*x + z*z)
        d3 = math.isqrt(y*y + z*z)
        space = x*x + y*y + z*z
        space_sqrt = math.isqrt(space)
        is_perfect = space_sqrt * space_sqrt == space

        print(f"\n  {name}: ({x}, {y}, {z})")
        print(f"    Face diagonals: {d1}, {d2}, {d3}")
        print(f"    Space diagonal²: {space}", end="")
        print(f" {'= ' + str(space_sqrt) + '² ✓' if is_perfect else ' (not a perfect square)'}")

        # Check which moduli the brick passes
        for M in [3, 5, 7, 15, 21, 35, 105]:
            passes = check_square_conditions(M, x, y, z)
            face_passes = check_face_diagonals(M, x, y, z)
            status = "✓ all" if passes else ("✓ face only" if face_passes else "✗ blocked")
            print(f"    Mod {M:3d}: {status}")


def demo_space_diagonal_obstruction():
    """Show how the space diagonal provides additional obstruction."""
    print("\n" + "=" * 60)
    print("  Space Diagonal Obstruction Analysis")
    print("=" * 60)

    for M in [3, 5, 7, 15, 21, 35, 105]:
        qr = quadratic_residues(M)
        face_only = 0
        all_four = 0
        for x, y, z in product(range(M), repeat=3):
            if check_face_diagonals(M, x, y, z, qr):
                face_only += 1
                if check_square_conditions(M, x, y, z, qr):
                    all_four += 1

        killed = face_only - all_four
        pct = killed / max(face_only, 1) * 100
        print(f"  Mod {M:3d}: face survivors = {face_only:>6}, "
              f"all-four = {all_four:>6}, "
              f"space diag kills {killed:>5} ({pct:.1f}%)")


def demo_density_progression():
    """Show how density decreases as we combine more primes."""
    print("\n" + "=" * 60)
    print("  Density Progression: Combining Primes")
    print("=" * 60)
    print(f"  {'Modulus':>10} {'Survivors':>12} {'Total':>12} {'Density':>10} {'Factor':>8}")
    print(f"  {'-'*10} {'-'*12} {'-'*12} {'-'*10} {'-'*8}")

    for M in [3, 5, 7, 15, 21, 35, 105]:
        qr = quadratic_residues(M)
        survivors = sum(
            1 for x, y, z in product(range(M), repeat=3)
            if check_square_conditions(M, x, y, z, qr)
        )
        total = M ** 3
        density = survivors / total
        factor = total // max(survivors, 1)
        print(f"  {M:>10} {survivors:>12,} {total:>12,} {density:>10.4%} {factor:>7}×")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Perfect Cuboid Modular Sieve — Demonstration Suite    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # 1. Run sieves at each prime and composite modulus
    for M in [3, 5, 7, 105]:
        run_sieve(M)

    # 2. Verify Euler bricks
    demo_euler_brick_verification()

    # 3. Space diagonal obstruction
    demo_space_diagonal_obstruction()

    # 4. Density progression
    demo_density_progression()

    print("\n" + "=" * 60)
    print("  Summary: The mod-105 sieve eliminates > 98.7% of")
    print("  all residue classes as potential perfect cuboid homes.")
    print("=" * 60)
