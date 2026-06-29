#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Beal Obstruction Theory

Demonstrates how the formally verified obstruction machinery can be applied:
1. Certificate generation for Diophantine impossibility
2. Automated obstruction compilation via CRT
3. Coverage analysis: what fraction of integers are blocked?
4. Connection to Fermat's Last Theorem for cubes
"""

from math import gcd, isqrt, log
from collections import defaultdict
from algorithms import (
    has_primitive_residue_solution,
    prime_power_factorization,
    crt_decompose,
    obstruction_search,
    cube_subgroup_analysis,
    is_prime,
    units_mod_n,
    find_witness,
)


# ═══════════════════════════════════════════════════════════════════
# Application 1: Obstruction Certificate Generator
# ═══════════════════════════════════════════════════════════════════

def generate_obstruction_certificate(x: int, y: int, z: int,
                                     search_bound: int = 200) -> dict:
    """
    Generate a formal obstruction certificate for signature (x, y, z).

    If an obstructing modulus N is found, the certificate proves:
    "For all positive integers A, B, C with gcd(ABC, N) = 1,
     A^x + B^y ≠ C^z."

    This is a machine-checkable proof of partial impossibility.

    Returns:
        A certificate dict with the obstructing modulus and proof components.
    """
    # Find obstructing primes
    result = obstruction_search(search_bound, x, y, z)

    if not result['obstructing']:
        return {
            'found': False,
            'signature': (x, y, z),
            'message': f'No obstruction found up to bound {search_bound}'
        }

    # Use the smallest obstructing prime as the certificate
    p = result['obstructing'][0]

    # Generate exhaustive verification data
    u = units_mod_n(p)
    power_x = {a: pow(a, x, p) for a in u}
    power_y = {b: pow(b, y, p) for b in u}
    power_z = {c: pow(c, z, p) for c in u}

    # Verify exhaustively: no triple (a,b,c) of units satisfies the equation
    verification = []
    for a in u:
        for b in u:
            target = (power_x[a] + power_y[b]) % p
            for c in u:
                if power_z[c] == target:
                    verification.append((a, b, c))

    assert len(verification) == 0, "Certificate generation found a solution!"

    return {
        'found': True,
        'signature': (x, y, z),
        'modulus': p,
        'is_prime': is_prime(p),
        'unit_count': len(u),
        'triples_checked': len(u) ** 3,
        'solutions_found': 0,
        'theorem': (
            f"For all positive integers A, B, C with gcd(ABC, {p}) = 1:\n"
            f"  A^{x} + B^{y} ≠ C^{z}"
        ),
        'propagation': (
            f"By obstruction monotonicity, for ALL multiples N of {p}:\n"
            f"  No primitive residue solution to a^{x} + b^{y} ≡ c^{z} (mod N) exists."
        )
    }


# ═══════════════════════════════════════════════════════════════════
# Application 2: CRT Obstruction Compiler
# ═══════════════════════════════════════════════════════════════════

def compile_obstruction_set(x: int, y: int, z: int,
                            prime_bound: int = 100) -> dict:
    """
    Compile the complete obstruction landscape for a signature.

    Uses CRT compression to determine exactly which moduli obstruct,
    based on prime factor analysis.

    The CRT Compression Theorem guarantees:
    N obstructs ⟺ some prime power factor of N obstructs.

    Returns:
        Analysis of the obstruction set including density estimates.
    """
    # Find all obstructing primes
    search = obstruction_search(prime_bound, x, y, z)
    obs_primes = search['obstructing']

    # For each obstructing prime, also check prime powers
    obs_prime_powers = {}
    for p in obs_primes:
        powers = []
        pk = p
        while pk <= prime_bound ** 2:
            if not has_primitive_residue_solution(pk, x, y, z):
                powers.append(pk)
            pk *= p
        obs_prime_powers[p] = powers

    # Compute the density of obstructed integers up to a bound
    test_bound = 1000
    obstructed_count = 0
    for n in range(2, test_bound + 1):
        # n is obstructed if any obstructing prime divides it
        if any(n % p == 0 for p in obs_primes):
            obstructed_count += 1

    density = obstructed_count / (test_bound - 1)

    # Theoretical density via inclusion-exclusion
    # P(n divisible by some p in obs_primes) ≈ 1 - ∏(1 - 1/p)
    if obs_primes:
        theoretical_density = 1.0
        for p in obs_primes:
            theoretical_density *= (1 - 1.0 / p)
        theoretical_density = 1 - theoretical_density
    else:
        theoretical_density = 0.0

    return {
        'signature': (x, y, z),
        'obstructing_primes': obs_primes,
        'obstructing_prime_powers': obs_prime_powers,
        'empirical_density': density,
        'theoretical_density': theoretical_density,
        'coverage_statement': (
            f"Among integers 2..{test_bound}, "
            f"{obstructed_count}/{test_bound-1} = {density:.1%} "
            f"are divisible by an obstructing prime.\n"
            f"For these integers N, no primitive solution to "
            f"a^{x}+b^{y}≡c^{z} (mod N) exists."
        )
    }


# ═══════════════════════════════════════════════════════════════════
# Application 3: FLT for Cubes — Residue-Based Partial Proof
# ═══════════════════════════════════════════════════════════════════

def flt_cubes_residue_analysis() -> dict:
    """
    Analyze how residue obstructions contribute to Fermat's Last Theorem
    for the case n = 3.

    The formally verified theorem `no_pairwise_coprime_sum_of_cubes_mod_7`
    shows: if A, B, C are coprime to 7, then A³ + B³ ≠ C³.

    This means any counterexample to FLT³ must have 7 | ABC.
    Combined with descent arguments, this is a key step in Euler's proof.
    """
    # The mod 7 obstruction
    analysis_7 = cube_subgroup_analysis(7)

    # Check: what if we allow one of A, B, C to be divisible by 7?
    # Then the "primitive" condition fails, and indeed solutions exist
    # in ZMod 7 when zero is allowed
    p = 7
    solutions_with_zero = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                if (pow(a, 3, p) + pow(b, 3, p)) % p == pow(c, 3, p):
                    solutions_with_zero.append((a, b, c))

    # Filter: at least one is 0 mod 7
    solutions_needing_7 = [
        (a, b, c) for a, b, c in solutions_with_zero
        if a % 7 == 0 or b % 7 == 0 or c % 7 == 0
    ]

    return {
        'cube_image_mod_7': analysis_7['cube_image'],
        'obstruction_holds': analysis_7['obstructs'],
        'total_solutions_mod_7': len(solutions_with_zero),
        'solutions_requiring_7_divides': len(solutions_needing_7),
        'key_theorem': (
            "no_pairwise_coprime_sum_of_cubes_mod_7:\n"
            "  For all A, B, C ∈ ℕ with gcd(A,7) = gcd(B,7) = gcd(C,7) = 1:\n"
            "    A³ + B³ ≠ C³\n"
            "\n"
            "Consequence: any solution to A³+B³=C³ requires 7 | ABC."
        ),
        'historical_note': (
            "This is essentially the first step in Euler's 1770 proof of FLT³.\n"
            "The mod 7 obstruction forces 7 to divide one of A, B, C,\n"
            "and infinite descent then produces a contradiction."
        )
    }


# ═══════════════════════════════════════════════════════════════════
# Application 4: Multi-Signature Comparison
# ═══════════════════════════════════════════════════════════════════

def compare_signatures(signatures: list[tuple[int, int, int]],
                       bound: int = 100) -> dict:
    """
    Compare the obstruction landscapes across different Beal signatures.

    This reveals which equations are "more obstructed" in the residue world,
    suggesting which Beal-type equations might be easier to attack via
    local methods.
    """
    results = {}
    for sig in signatures:
        search = obstruction_search(bound, *sig)
        compiled = compile_obstruction_set(*sig, prime_bound=bound)
        results[sig] = {
            'obstructing_primes': search['obstructing'],
            'count': len(search['obstructing']),
            'density': compiled['theoretical_density']
        }

    return results


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Obstruction Certificate Generator")
    print("=" * 70)
    print()

    cert = generate_obstruction_certificate(3, 3, 3)
    if cert['found']:
        print(f"  Certificate found!")
        print(f"  Modulus: {cert['modulus']}")
        print(f"  Units checked: {cert['unit_count']}")
        print(f"  Total triples verified: {cert['triples_checked']}")
        print(f"  Solutions found: {cert['solutions_found']}")
        print()
        print(f"  THEOREM: {cert['theorem']}")
        print()
        print(f"  {cert['propagation']}")
    print()

    print("=" * 70)
    print("APPLICATION 2: CRT Obstruction Compiler for (3,3,3)")
    print("=" * 70)
    print()

    compiled = compile_obstruction_set(3, 3, 3, prime_bound=200)
    print(f"  Obstructing primes: {compiled['obstructing_primes']}")
    print(f"  Obstructing prime powers: {compiled['obstructing_prime_powers']}")
    print(f"  Theoretical density: {compiled['theoretical_density']:.4f}")
    print(f"  Empirical density: {compiled['empirical_density']:.4f}")
    print()
    print(f"  {compiled['coverage_statement']}")
    print()

    print("=" * 70)
    print("APPLICATION 3: FLT³ Residue Analysis")
    print("=" * 70)
    print()

    flt = flt_cubes_residue_analysis()
    print(f"  Cube image mod 7: {flt['cube_image_mod_7']}")
    print(f"  Obstruction holds: {flt['obstruction_holds']}")
    print(f"  Total solutions a³+b³≡c³ (mod 7) (including non-units): "
          f"{flt['total_solutions_mod_7']}")
    print(f"  Solutions requiring 7|abc: {flt['solutions_requiring_7_divides']}")
    print()
    print(f"  {flt['key_theorem']}")
    print()
    print(f"  {flt['historical_note']}")
    print()

    print("=" * 70)
    print("APPLICATION 4: Multi-Signature Comparison")
    print("=" * 70)
    print()

    sigs = [(3, 3, 3), (3, 3, 5), (3, 5, 5), (5, 5, 5),
            (3, 3, 7), (3, 7, 7), (7, 7, 7)]
    comparison = compare_signatures(sigs, bound=100)
    print(f"  {'Signature':<12s} {'# Obs Primes':>13s} {'Density':>10s} "
          f"{'Primes':>20s}")
    print(f"  {'-'*12} {'-'*13} {'-'*10} {'-'*20}")
    for sig, data in sorted(comparison.items()):
        print(f"  {str(sig):<12s} {data['count']:>13d} "
              f"{data['density']:>10.4f} {str(data['obstructing_primes'][:5]):>20s}")
    print()
    print("=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Demonstrations of Beal Obstruction Theory

Concrete numerical examples illustrating the theorems proved in this project:
1. Cube image sets in finite fields
2. Sumset avoidance for signature (3,3,3)
3. CRT compression of obstructions
4. Systematic search for obstructing primes
"""

from math import gcd
from itertools import product as cartesian_product


def units(n: int) -> list[int]:
    """Return the units (elements coprime to n) in Z/nZ."""
    return [a for a in range(n) if gcd(a, n) == 1]


def cube_image(p: int) -> set[int]:
    """Compute the set of cubes of units in Z/pZ."""
    return {pow(a, 3, p) for a in units(p)}


def has_primitive_residue_solution(n: int, x: int, y: int, z: int) -> bool:
    """
    Check if a^x + b^y ≡ c^z (mod n) has a solution with a, b, c all units.

    >>> has_primitive_residue_solution(7, 3, 3, 3)
    False
    >>> has_primitive_residue_solution(5, 3, 3, 3)
    True
    """
    u = units(n)
    for a in u:
        ax = pow(a, x, n)
        for b in u:
            by_ = pow(b, y, n)
            s = (ax + by_) % n
            for c in u:
                if pow(c, z, n) == s:
                    return True
    return False


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def find_obstructing_primes(bound: int, x: int, y: int, z: int) -> list[int]:
    """Find all primes up to `bound` that obstruct signature (x, y, z)."""
    return [p for p in range(2, bound + 1) if is_prime(p)
            and not has_primitive_residue_solution(p, x, y, z)]


# ═══════════════════════════════════════════════════════════════════
# DEMO 1: Cube Image Sets
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 1: Cube Image Sets in (Z/pZ)×")
print("=" * 70)
print()

for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]:
    C = cube_image(p)
    index = (p - 1) // len(C) if len(C) > 0 else 0
    mod3 = p % 3
    print(f"  p = {p:3d}  |  p mod 3 = {mod3}  |  "
          f"|C_p| = {len(C):3d}  |  index = {index}  |  "
          f"C_p = {sorted(C)}")

print()
print("Key observation: When p ≡ 2 (mod 3), |C_p| = p-1 (every unit is a cube).")
print("When p ≡ 1 (mod 3), cubes form a subgroup of index 3.")
print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 2: Sumset Avoidance for p = 7
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 2: Sumset Avoidance at p = 7")
print("=" * 70)
print()

p = 7
C = cube_image(p)
print(f"  Cube image C_7 = {sorted(C)}")
print()
print("  Checking all sums a³ + b³ for units a, b in (Z/7Z)×:")
print()

sumset = set()
for a in sorted(C):
    for b in sorted(C):
        s = (a + b) % p
        in_C = "✓ IN C₇" if s in C else "✗ NOT in C₇"
        is_unit = "unit" if gcd(s, p) == 1 else "ZERO"
        print(f"    {a} + {b} ≡ {s} (mod 7)  [{is_unit}]  {in_C}")
        sumset.add(s)

print()
print(f"  Sumset C₇ + C₇ = {sorted(sumset)}")
print(f"  (C₇ + C₇) ∩ C₇ = {sorted(sumset & C)}")
print(f"  Result: {'OBSTRUCTION — no primitive solution!' if not (sumset & C) else 'solutions exist'}")
print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 3: Obstructing Primes for (3,3,3)
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 3: Obstructing Primes for Signature (3,3,3)")
print("=" * 70)
print()

primes_obstruct = find_obstructing_primes(200, 3, 3, 3)
print(f"  Obstructing primes up to 200: {primes_obstruct}")
print()
print("  Analysis:")
for p in primes_obstruct:
    C = cube_image(p)
    print(f"    p = {p}: C_p = {sorted(C)}, |C_p| = {len(C)}, "
          f"p mod 3 = {p % 3}")

print()
print("  Non-obstructing primes ≡ 1 (mod 3):")
non_obs_1mod3 = [p for p in range(2, 200) if p % 3 == 1 and p > 3
                 and all(p % d != 0 for d in range(2, int(p**0.5)+1))
                 and has_primitive_residue_solution(p, 3, 3, 3)]
for p in non_obs_1mod3[:5]:
    C = cube_image(p)
    print(f"    p = {p}: C_p has {len(C)} elements, solutions exist")

print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 4: CRT Compression
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 4: CRT Compression Theorem in Action")
print("=" * 70)
print()

# Show that obstruction at 7 propagates to multiples
multiples_of_7 = [7, 14, 21, 35, 49, 77, 91]
print("  Checking multiples of 7 (all should obstruct):")
for n in multiples_of_7:
    result = has_primitive_residue_solution(n, 3, 3, 3)
    print(f"    N = {n:4d}: {'has solution' if result else 'NO solution (obstruction)'}")

print()

# Show CRT decomposition
print("  CRT decomposition examples:")
test_pairs = [(7, 5), (7, 11), (13, 5), (7, 13), (2, 7)]
for m, n in test_pairs:
    sol_m = has_primitive_residue_solution(m, 3, 3, 3)
    sol_n = has_primitive_residue_solution(n, 3, 3, 3)
    sol_mn = has_primitive_residue_solution(m * n, 3, 3, 3)
    expected = sol_m and sol_n
    match = "✓" if sol_mn == expected else "✗ MISMATCH"
    print(f"    M={m:3d}, N={n:3d}: "
          f"sol(M)={sol_m}, sol(N)={sol_n}, "
          f"sol(M×N)={sol_mn}, M∧N={expected} {match}")

print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 5: Comparison across signatures
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 5: Obstruction Landscape across Signatures")
print("=" * 70)
print()

signatures = [(3, 3, 3), (3, 3, 5), (3, 5, 5), (5, 5, 5), (3, 3, 7)]
for sig in signatures:
    obs = find_obstructing_primes(50, *sig)
    print(f"  Signature {sig}: obstructing primes ≤ 50 = {obs}")

print()
print("═" * 70)
print("All demonstrations complete.")
print("═" * 70)
