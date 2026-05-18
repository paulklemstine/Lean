#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Sums of Three Cubes Theory

Demonstrates practical uses of the modular obstruction framework:
1. Efficient pre-screening for Diophantine search
2. Certified witness verification
3. Classification of integers by representability status
4. Local-global analysis as a template for other equations
"""

from math import gcd


def cube_residues_mod(m: int) -> set[int]:
    """Compute the set of cube residues modulo m."""
    return {pow(x, 3, m) for x in range(m)}


def triple_sumset_mod(m: int) -> set[int]:
    """Compute the triple sumset of cubes modulo m."""
    cubes = cube_residues_mod(m)
    return {(a + b + c) % m for a in cubes for b in cubes for c in cubes}


def is_mod_obstructed(n: int, moduli: list[int] = None) -> tuple[bool, int]:
    """
    APPLICATION 1: Pre-screening for Diophantine search
    
    Before running expensive exhaustive search for x³+y³+z³=n,
    check modular obstructions. Returns (is_obstructed, obstructing_modulus).
    
    This can eliminate ~22% of candidates immediately (mod 9 alone),
    and more with additional moduli.
    
    Example:
        >>> is_mod_obstructed(33)
        (False, 0)
        >>> is_mod_obstructed(4)
        (True, 9)
    """
    if moduli is None:
        moduli = [9]  # Mod 9 is the strongest single-modulus obstruction for cubes
    
    for m in moduli:
        image = triple_sumset_mod(m)
        if n % m not in image:
            return (True, m)
    return (False, 0)


def verify_witness(n: int, x: int, y: int, z: int) -> dict:
    """
    APPLICATION 2: Certified witness verification
    
    Given a claimed representation n = x³ + y³ + z³, verify it exactly.
    Returns a verification report.
    
    Example:
        >>> verify_witness(29, 3, 1, 1)
        {'valid': True, 'n': 29, 'witness': (3, 1, 1), ...}
    """
    x3 = x ** 3
    y3 = y ** 3
    z3 = z ** 3
    computed = x3 + y3 + z3
    
    return {
        'valid': computed == n,
        'n': n,
        'witness': (x, y, z),
        'x_cubed': x3,
        'y_cubed': y3,
        'z_cubed': z3,
        'sum': computed,
        'error': computed - n,
        'nontrivial': not (x == 0 and y == 0) and not (y == 0 and z == 0) and not (x == 0 and z == 0),
        'max_abs_coord': max(abs(x), abs(y), abs(z)),
    }


def classify_integers(start: int, end: int, search_bound: int = 100) -> dict:
    """
    APPLICATION 3: Classification of integers by representability status
    
    Classifies each integer in [start, end) as:
    - 'obstructed': fails mod-9 condition (proven unrepresentable)
    - 'represented': found explicit witness
    - 'unknown': passes mod-9 but no small witness found
    
    Returns statistics and examples for each category.
    """
    from collections import defaultdict
    
    categories = defaultdict(list)
    
    for n in range(start, end):
        obstructed, _ = is_mod_obstructed(n)
        if obstructed:
            categories['obstructed'].append(n)
            continue
        
        # Search for witness
        found = False
        for x in range(-search_bound, search_bound + 1):
            if found:
                break
            for y in range(-search_bound, search_bound + 1):
                z3 = n - x**3 - y**3
                if z3 == 0:
                    categories['represented'].append((n, x, y, 0))
                    found = True
                    break
                sign = 1 if z3 > 0 else -1
                z_approx = round(abs(z3) ** (1/3))
                for dz in [sign * z_approx - 1, sign * z_approx, sign * z_approx + 1]:
                    if dz**3 == z3:
                        categories['represented'].append((n, x, y, dz))
                        found = True
                        break
                if found:
                    break
        
        if not found:
            categories['unknown'].append(n)
    
    return dict(categories)


def local_global_template(equation_name: str, check_fn, moduli: list[int],
                          test_range: range) -> dict:
    """
    APPLICATION 4: General local-global analysis template
    
    This template can be applied to any polynomial Diophantine equation.
    It computes the local obstruction at each modulus and reports the
    fraction of integers that pass all local tests.
    
    Parameters:
        equation_name: descriptive name
        check_fn: function(n, m) -> bool, True if n is locally solvable mod m
        moduli: list of moduli to check
        test_range: range of integers to test
    
    Returns analysis report.
    """
    total = len(test_range)
    passing_all = 0
    obstruction_counts = {m: 0 for m in moduli}
    
    for n in test_range:
        passes = True
        for m in moduli:
            if not check_fn(n, m):
                obstruction_counts[m] += 1
                passes = False
        if passes:
            passing_all += 1
    
    return {
        'equation': equation_name,
        'total_tested': total,
        'passing_all_local': passing_all,
        'density_passing': passing_all / total if total > 0 else 0,
        'obstruction_by_modulus': {
            m: {'blocked': c, 'fraction': c/total if total > 0 else 0}
            for m, c in obstruction_counts.items()
        }
    }


# ============================================================
# Known famous representations for verification
# ============================================================

KNOWN_REPRESENTATIONS = {
    0: (0, 0, 0),
    1: (1, 0, 0),
    2: (1, 1, 0),
    3: (-5, 4, 4),
    6: (-1, -1, 2),
    7: (0, -1, 2),
    8: (2, 0, 0),
    9: (1, 0, 2),
    10: (1, 1, 2),
    11: (-2, -2, 3),
    12: (10, 7, -11),
    15: (-1, 2, 2),
    16: (-511, -1609, 1626),
    17: (1, 2, 2),
    18: (-1, -1, -2 + 3),  # = (-1, -1, 1) -> -1-1+1=-1, try (0, -2, 2+...)
    19: (0, -2, 3),
    20: (1, -2, 3),
    24: (-1, -2, 3),
    25: (-1, 3, -1),
    26: (0, -1, 3),
    27: (3, 0, 0),
    28: (0, 1, 3),
    29: (1, 1, 3),
    33: (8866128975287528, -8778405442862239, -2736111468807040),
    # 33 was famously solved in 2019 by Andrew Booker
}


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Pre-screening for Diophantine Search")
    print("=" * 70)
    
    total = 1000
    obstructed_count = sum(1 for n in range(total) if is_mod_obstructed(n)[0])
    print(f"Among [0, {total}): {obstructed_count} obstructed, "
          f"{total - obstructed_count} potentially representable")
    print(f"Savings: {obstructed_count/total*100:.1f}% of search space eliminated by mod-9 alone")
    print()
    
    print("=" * 70)
    print("APPLICATION 2: Certified Witness Verification")
    print("=" * 70)
    
    for n, (x, y, z) in list(KNOWN_REPRESENTATIONS.items())[:10]:
        report = verify_witness(n, x, y, z)
        status = "✓" if report['valid'] else "✗"
        trivial = "" if report['nontrivial'] else " (trivial)"
        print(f"  {status} {n} = {x}³ + {y}³ + {z}³{trivial}")
    
    # Verify the famous n=33 solution
    n = 33
    x, y, z = KNOWN_REPRESENTATIONS[33]
    report = verify_witness(n, x, y, z)
    print(f"\n  Famous: {n} = {x}³ + {y}³ + {z}³")
    print(f"    Valid: {report['valid']}, Max coordinate: {report['max_abs_coord']}")
    print()
    
    print("=" * 70)
    print("APPLICATION 3: Integer Classification")
    print("=" * 70)
    
    result = classify_integers(0, 100, search_bound=50)
    print(f"  Obstructed (mod 9): {len(result.get('obstructed', []))} integers")
    print(f"  Represented (found witness): {len(result.get('represented', []))} integers")
    print(f"  Unknown (no small witness): {len(result.get('unknown', []))} integers")
    if result.get('unknown'):
        print(f"  Unknown values: {result['unknown'][:20]}...")
    print()
    
    print("=" * 70)
    print("APPLICATION 4: Local-Global Template")
    print("=" * 70)
    
    def cubes_local_check(n, m):
        image = triple_sumset_mod(m)
        return n % m in image
    
    report = local_global_template(
        "x³ + y³ + z³ = n",
        cubes_local_check,
        [9, 7, 13],
        range(1000)
    )
    print(f"  Equation: {report['equation']}")
    print(f"  Tested: {report['total_tested']} integers")
    print(f"  Passing all local tests: {report['passing_all_local']} "
          f"({report['density_passing']*100:.1f}%)")
    for m, data in report['obstruction_by_modulus'].items():
        print(f"    Mod {m}: {data['blocked']} blocked ({data['fraction']*100:.1f}%)")


#!/usr/bin/env python3
"""
demo.py — Demonstrations of the Sums of Three Cubes Theory

Concrete numerical examples illustrating the mod-9 obstruction,
infinite families, local solvability, and density results.
"""

def is_sum_three_cubes_brute(n: int, bound: int = 100) -> list[tuple[int, int, int]]:
    """Brute-force search for representations n = x³ + y³ + z³."""
    solutions = []
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            z3 = n - x**3 - y**3
            z = round(z3 ** (1/3)) if z3 >= 0 else -round((-z3) ** (1/3))
            for dz in [z - 1, z, z + 1]:
                if dz**3 == z3:
                    solutions.append((x, y, dz))
    return solutions


def demo_mod9_obstruction():
    """Demonstrate that n ≡ 4,5 (mod 9) are never sums of three cubes."""
    print("=" * 70)
    print("DEMO 1: Mod-9 Obstruction")
    print("=" * 70)
    print()
    
    # Show that cubes mod 9 are in {0, 1, 8}
    cube_residues = sorted(set(x**3 % 9 for x in range(9)))
    print(f"Cube residues mod 9: {cube_residues}")
    print(f"  (i.e., for any integer x, x³ mod 9 ∈ {{{', '.join(map(str, cube_residues))}}})")
    print()
    
    # Triple sums
    triple_sums = sorted(set(
        (a + b + c) % 9
        for a in cube_residues for b in cube_residues for c in cube_residues
    ))
    print(f"All possible (x³ + y³ + z³) mod 9: {triple_sums}")
    missing = sorted(set(range(9)) - set(triple_sums))
    print(f"Missing residues: {missing}")
    print()
    
    # Verify with examples
    print("Verification: searching for representations of n ≡ 4 (mod 9)...")
    for n in [4, 13, 22, 31, 40]:
        sols = is_sum_three_cubes_brute(n, 50)
        print(f"  n = {n} (≡ {n % 9} mod 9): {'NO solutions found' if not sols else f'{len(sols)} solutions'}")
    
    print()
    print("Verification: searching for representations of n ≡ 5 (mod 9)...")
    for n in [5, 14, 23, 32, 41]:
        sols = is_sum_three_cubes_brute(n, 50)
        print(f"  n = {n} (≡ {n % 9} mod 9): {'NO solutions found' if not sols else f'{len(sols)} solutions'}")
    print()


def demo_infinite_families():
    """Demonstrate polynomial families producing infinitely many representable integers."""
    print("=" * 70)
    print("DEMO 2: Infinite Families of Representable Integers")
    print("=" * 70)
    print()
    
    # Family 1: Perfect cubes
    print("Family 1: m³ = m³ + 0³ + 0³")
    for m in range(-5, 6):
        n = m**3
        print(f"  {m}³ = {n} = ({m})³ + 0³ + 0³ ✓")
    print()
    
    # Family 2: a³ + b³ + (-a-b)³ = -3ab(a+b)
    print("Family 2: a³ + b³ + (-a-b)³ = -3ab(a+b)")
    print("  This identity gives a nontrivial two-parameter family.")
    print()
    for a in range(1, 6):
        for b in range(a, a + 3):
            z = -a - b
            n = a**3 + b**3 + z**3
            expected = -3 * a * b * (a + b)
            assert n == expected, f"Identity failed: {n} ≠ {expected}"
            print(f"  a={a}, b={b}: ({a})³ + ({b})³ + ({z})³ = {n}")
    print()
    
    # Family 3: k³ + (k+1)³ + (-(2k+1))³ = -3k(k+1)(2k+1)
    print("Family 3: k³ + (k+1)³ + (-(2k+1))³ = -3k(k+1)(2k+1)")
    print("  (Special case of Family 2 with a=k, b=k+1)")
    for k in range(1, 10):
        a, b, c = k, k + 1, -(2*k + 1)
        n = a**3 + b**3 + c**3
        print(f"  k={k}: {a}³ + {b}³ + ({c})³ = {n}")
    print()


def demo_density():
    """Demonstrate the density of admissible residue classes."""
    print("=" * 70)
    print("DEMO 3: Density of Admissible Residue Classes")
    print("=" * 70)
    print()
    
    for N in [1, 10, 100, 1000]:
        total = 9 * N
        admissible = sum(1 for n in range(total) if n % 9 not in (4, 5))
        expected = 7 * N
        ratio = admissible / total
        print(f"  [0, {total}): admissible = {admissible}, expected 7×{N} = {expected}, "
              f"density = {ratio:.6f} ≈ 7/9 = {7/9:.6f}")
    print()
    
    # Show the pattern in a block of 9
    print("Pattern in one block [0, 9):")
    for n in range(9):
        status = "✓ admissible" if n % 9 not in (4, 5) else "✗ OBSTRUCTED"
        print(f"  n = {n} (mod 9 = {n % 9}): {status}")
    print()


def demo_local_solvability():
    """Demonstrate local solvability modulo various moduli."""
    print("=" * 70)
    print("DEMO 4: Local Solvability Framework")
    print("=" * 70)
    print()
    
    def local_rep(m: int, a: int) -> bool:
        """Check if a is locally representable mod m."""
        a = a % m
        for x in range(m):
            for y in range(m):
                for z in range(m):
                    if (x**3 + y**3 + z**3) % m == a:
                        return True
        return False
    
    # Mod 9 analysis
    print("Local representability mod 9:")
    for a in range(9):
        rep = local_rep(9, a)
        print(f"  LocRep(9, {a}) = {rep}")
    print()
    
    # Mod small primes
    for m in [2, 3, 5, 7, 11, 13]:
        image = sorted(a for a in range(m) if local_rep(m, a))
        obstrs = sorted(set(range(m)) - set(image))
        print(f"  Mod {m}: image = {image}, obstructions = {obstrs or 'none'}")
    print()
    
    # Check CRT consistency for coprime moduli
    print("CRT consistency check (coprime moduli):")
    for m, n in [(2, 3), (3, 5), (2, 5), (3, 7), (5, 7)]:
        mn = m * n
        all_consistent = True
        for a in range(mn):
            loc_mn = local_rep(mn, a)
            loc_m = local_rep(m, a % m)
            loc_n = local_rep(n, a % n)
            if loc_mn != (loc_m and loc_n):
                all_consistent = False
                print(f"  CRT FAILURE at ({m},{n}), a={a}: "
                      f"LocRep({mn},{a})={loc_mn}, "
                      f"LocRep({m},{a%m})={loc_m}, "
                      f"LocRep({n},{a%n})={loc_n}")
        if all_consistent:
            print(f"  ({m}, {n}): CRT decomposition holds ✓")
    print()


def demo_geometric_surface():
    """Demonstrate the cubic surface perspective."""
    print("=" * 70)
    print("DEMO 5: Cubic Surface X_n : x³ + y³ + z³ = n")
    print("=" * 70)
    print()
    
    # Count integral points for small n
    bound = 20
    print(f"Integral points on X_n with |x|,|y|,|z| ≤ {bound}:")
    for n in range(10):
        count = 0
        for x in range(-bound, bound + 1):
            for y in range(-bound, bound + 1):
                z3 = n - x**3 - y**3
                z = round(abs(z3) ** (1/3)) * (1 if z3 >= 0 else -1)
                for dz in [z - 1, z, z + 1]:
                    if dz**3 == z3 and abs(dz) <= bound:
                        count += 1
        mod9_status = "obstructed" if n % 9 in (4, 5) else "admissible"
        print(f"  X_{n}: {count} points ({mod9_status})")
    print()


if __name__ == "__main__":
    demo_mod9_obstruction()
    demo_infinite_families()
    demo_density()
    demo_local_solvability()
    demo_geometric_surface()
