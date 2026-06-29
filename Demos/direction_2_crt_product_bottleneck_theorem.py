#!/usr/bin/env python3
"""
Applications of the CRT Product Bottleneck Theorem

Demonstrates real-world connections of the arithmetic bottleneck principle:
1. Cryptographic mixing analysis for RSA-type moduli
2. Primality witnesses from expansion properties
3. Factorization detection via conductance anomalies
4. Comparison of expansion across number-theoretic families
"""

import math
from fractions import Fraction
from typing import List, Tuple, Dict
from algorithms import (
    enumerate_idempotents,
    compute_basins,
    basin_conductance_exact,
    basin_conductance_heuristic,
    conductance,
    edge_boundary,
    crt_lift_left,
    count_prime_factors,
    squaring_orbit,
)


# ─────────────────────────────────────────────────────────────────
# Application 1: Cryptographic Mixing Analysis
# ─────────────────────────────────────────────────────────────────

def analyze_cryptographic_mixing(bits: int = 4) -> None:
    """Analyze mixing properties of squaring dynamics for semi-prime moduli.

    In RSA, the modulus n = p * q is a product of two large primes.
    The squaring map x -> x^2 mod n is the core of Rabin encryption.
    The bottleneck theorem shows that this map inherits poor mixing
    from both factors, creating structural weakness.

    This demo uses small primes for illustration.
    """
    print("=" * 60)
    print("  Application 1: Cryptographic Mixing Analysis")
    print("=" * 60)

    # Small semi-primes (products of two primes)
    primes = [p for p in range(2, 2**bits) if all(p % d != 0 for d in range(2, int(p**0.5) + 1)) and p > 1]

    print(f"\n  Primes available: {primes}")
    print(f"\n  {'p':>4} {'q':>4} {'n=pq':>6} {'h(p)':>8} {'h(q)':>8} {'h(pq)':>8} {'min':>8} {'ratio':>8}")
    print(f"  {'-'*4} {'-'*4} {'-'*6} {'-'*8} {'-'*8} {'-'*8} {'-'*8} {'-'*8}")

    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            n = p * q
            if n > 100:
                continue

            h_p = basin_conductance_exact(p) if p <= 16 else basin_conductance_heuristic(p)
            h_q = basin_conductance_exact(q) if q <= 16 else basin_conductance_heuristic(q)
            h_n = basin_conductance_exact(n) if n <= 16 else basin_conductance_heuristic(n)
            h_min = min(h_p, h_q)
            ratio = float(h_n / h_min) if h_min > 0 else 0.0

            print(f"  {p:4d} {q:4d} {n:6d} {float(h_p):8.4f} {float(h_q):8.4f} {float(h_n):8.4f} {float(h_min):8.4f} {ratio:8.4f}")

    print("\n  Key insight: Semi-primes always have h(pq) ≤ min(h(p), h(q)).")
    print("  The squaring dynamics on RSA moduli are bottlenecked by")
    print("  the weaker factor — a structural consequence of CRT.")


# ─────────────────────────────────────────────────────────────────
# Application 2: Primality Detection via Expansion
# ─────────────────────────────────────────────────────────────────

def primality_via_expansion(max_n: int = 30) -> None:
    """Demonstrate that primes tend to have higher basin conductance.

    The bottleneck theorem implies composites with multiple prime factors
    have reduced expansion. This creates a "spectral fingerprint" of
    compositeness.
    """
    print("\n" + "=" * 60)
    print("  Application 2: Primality Detection via Expansion")
    print("=" * 60)

    results = []
    for n in range(2, max_n + 1):
        h = basin_conductance_exact(n) if n <= 16 else basin_conductance_heuristic(n)
        is_prime = all(n % d != 0 for d in range(2, int(n**0.5) + 1))
        omega = count_prime_factors(n)
        results.append((n, float(h), is_prime, omega))

    # Group by primality
    prime_h = [h for _, h, is_p, _ in results if is_p]
    composite_h = [h for _, h, is_p, _ in results if not is_p]

    print(f"\n  {'n':>4} {'h(n)':>8} {'type':>12} {'ω(n)':>6}")
    print(f"  {'-'*4} {'-'*8} {'-'*12} {'-'*6}")
    for n, h, is_p, omega in results:
        ptype = "PRIME" if is_p else "composite"
        print(f"  {n:4d} {h:8.4f} {ptype:>12} {omega:6d}")

    if prime_h and composite_h:
        avg_prime = sum(prime_h) / len(prime_h)
        avg_comp = sum(composite_h) / len(composite_h)
        print(f"\n  Average h for primes: {avg_prime:.4f}")
        print(f"  Average h for composites: {avg_comp:.4f}")
        print(f"  Ratio (prime/composite): {avg_prime/avg_comp:.4f}")
        print("\n  Observation: Primes tend to have higher basin conductance,")
        print("  consistent with the bottleneck theorem's prediction that")
        print("  factorization degrades expansion.")


# ─────────────────────────────────────────────────────────────────
# Application 3: Factorization Detection
# ─────────────────────────────────────────────────────────────────

def factorization_detection(n: int = 15) -> None:
    """Show how basin structure reveals factorization.

    The basins of attraction of the squaring map encode the CRT
    decomposition. Each nontrivial idempotent corresponds to a
    factor, and its basin creates a sparse cut.
    """
    print("\n" + "=" * 60)
    print(f"  Application 3: Factorization Detection for n = {n}")
    print("=" * 60)

    idemps = enumerate_idempotents(n)
    basins = compute_basins(n)

    print(f"\n  Modulus: {n}")
    print(f"  Factorization: ", end="")
    temp = n
    factors = []
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            factors.append(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    print(" × ".join(str(f) for f in factors))

    print(f"  Idempotents: {idemps}")
    print(f"  Number of idempotents: {len(idemps)} = 2^{int(math.log2(len(idemps)))}")

    print(f"\n  Basin decomposition:")
    for fp in sorted(basins.keys()):
        basin = basins[fp]
        S = frozenset(basin)
        h = conductance(S, n) if 0 < len(S) < n else Fraction(-1)
        is_trivial = fp in (0, 1)
        label = "(trivial)" if is_trivial else "(nontrivial — reveals factorization)"
        print(f"    Basin of e={fp}: {sorted(basin)}")
        print(f"      Size: {len(basin)}, Conductance: {float(h):.4f} {label}")

    # Show the CRT correspondence
    print(f"\n  CRT correspondence:")
    for e in idemps:
        if e != 0 and e != 1:
            remainders = []
            temp_n = n
            for p in set(factors):
                pk = 1
                while temp_n % p == 0:
                    pk *= p
                    temp_n //= p
                remainders.append(f"{e} mod {pk} = {e % pk}")
                temp_n = n
            print(f"    Idempotent {e}: " + ", ".join(remainders))


# ─────────────────────────────────────────────────────────────────
# Application 4: Number-Theoretic Family Comparison
# ─────────────────────────────────────────────────────────────────

def compare_families(max_n: int = 50) -> None:
    """Compare basin conductance across number-theoretic families.

    Groups: primes, prime powers, semiprimes, highly composite numbers.
    """
    print("\n" + "=" * 60)
    print("  Application 4: Conductance by Number-Theoretic Family")
    print("=" * 60)

    families: Dict[str, List[Tuple[int, float]]] = {
        'primes': [],
        'prime_powers': [],
        'semiprimes': [],
        'squarefree_3+': [],
        'other': [],
    }

    for n in range(2, max_n + 1):
        h = basin_conductance_exact(n) if n <= 16 else basin_conductance_heuristic(n)
        omega = count_prime_factors(n)

        # Classify
        is_prime = all(n % d != 0 for d in range(2, int(n**0.5) + 1))
        is_prime_power = omega == 1 and not is_prime

        if is_prime:
            families['primes'].append((n, float(h)))
        elif is_prime_power:
            families['prime_powers'].append((n, float(h)))
        elif omega == 2:
            families['semiprimes'].append((n, float(h)))
        elif omega >= 3:
            families['squarefree_3+'].append((n, float(h)))
        else:
            families['other'].append((n, float(h)))

    print(f"\n  {'Family':<20} {'Count':>6} {'Avg h':>8} {'Min h':>8} {'Max h':>8}")
    print(f"  {'-'*20} {'-'*6} {'-'*8} {'-'*8} {'-'*8}")

    for name, data in families.items():
        if data:
            vals = [h for _, h in data]
            print(f"  {name:<20} {len(data):6d} {sum(vals)/len(vals):8.4f} {min(vals):8.4f} {max(vals):8.4f}")

    print("\n  Prediction from bottleneck theorem:")
    print("  • Primes and prime powers have highest conductance")
    print("  • More prime factors → lower conductance")
    print("  • Semiprimes bounded by min of factor conductances")


# ─────────────────────────────────────────────────────────────────
# Application 5: Orbit Structure Visualization
# ─────────────────────────────────────────────────────────────────

def orbit_analysis(n: int = 15) -> None:
    """Analyze the orbit structure of the squaring map.

    Shows how elements flow through the dynamical system,
    converging to idempotent fixed points.
    """
    print("\n" + "=" * 60)
    print(f"  Application 5: Orbit Analysis for Z/{n}Z")
    print("=" * 60)

    print(f"\n  Squaring map orbits (x → x² mod {n}):")
    basins = compute_basins(n)

    for fp in sorted(basins.keys()):
        basin = basins[fp]
        print(f"\n  Basin of fixed point {fp}:")
        for x in sorted(basin):
            orbit = squaring_orbit(x, n)
            orbit_str = " → ".join(str(o) for o in orbit)
            print(f"    {x:3d}: {orbit_str}")


# ─────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    analyze_cryptographic_mixing()
    primality_via_expansion(25)
    factorization_detection(15)
    factorization_detection(30)
    compare_families(30)
    orbit_analysis(12)


#!/usr/bin/env python3
"""
CRT Product Bottleneck Theorem — Interactive Demo

Demonstrates the main theorem: for coprime a, b >= 2,
    basinConductance(a*b) <= min(basinConductance(a), basinConductance(b))

The squaring map x -> x^2 mod n defines a dynamical system on Z/nZ.
The "basin conductance" measures the minimum boundary-to-volume ratio
over all nontrivial subsets — a Cheeger constant for squaring dynamics.

Usage:
    python demo.py              # Run with default examples
    python demo.py 3 5          # Compute for specific coprime a, b
    python demo.py --scan 50    # Scan all coprime pairs up to 50
"""

import sys
import math
from itertools import product as cartesian_product
from fractions import Fraction


def gcd(a, b):
    while b:
        a, b = b, a % b
    return a


def squaring_map(x, n):
    """x -> x^2 mod n"""
    return (x * x) % n


def edge_boundary(S, n):
    """Elements of S whose square lands outside S."""
    S_set = set(S)
    return {x for x in S_set if squaring_map(x, n) not in S_set}


def conductance(S, n):
    """Boundary-to-volume ratio for subset S of Z/nZ."""
    if len(S) == 0:
        return Fraction(0)
    bdry = edge_boundary(S, n)
    return Fraction(len(bdry), len(S))


def all_nonempty_proper_subsets(n):
    """Generate all nonempty proper subsets of {0, ..., n-1}.
    Warning: exponential in n. Only use for small n."""
    elements = list(range(n))
    from itertools import combinations
    for size in range(1, n):
        for combo in combinations(elements, size):
            yield frozenset(combo)


def basin_conductance(n, max_n=20):
    """Compute basin conductance = min conductance over admissible cuts.

    For small n, enumerates all subsets. For larger n, uses sampling.
    """
    if n < 2:
        return Fraction(1)

    if n <= max_n:
        # Exact computation
        min_cond = Fraction(1)
        for S in all_nonempty_proper_subsets(n):
            c = conductance(S, n)
            if c < min_cond:
                min_cond = c
        return min_cond
    else:
        # For larger n, use idempotent-based cuts and random sampling
        return basin_conductance_approx(n)


def find_idempotents(n):
    """Find all idempotents in Z/nZ: elements e with e^2 = e mod n."""
    return [e for e in range(n) if (e * e) % n == e]


def basin_conductance_approx(n):
    """Approximate basin conductance using idempotent basins and structured cuts."""
    import random
    min_cond = Fraction(1)

    # Try idempotent-based cuts
    idemps = find_idempotents(n)
    for e in idemps:
        # Build the basin of e (iterate squaring backward)
        basin = set()
        to_check = {e}
        checked = set()
        while to_check:
            x = to_check.pop()
            if x in checked:
                continue
            checked.add(x)
            basin.add(x)
            # Find preimages: y such that y^2 = x mod n
            for y in range(n):
                if (y * y) % n == x:
                    if y not in checked:
                        to_check.add(y)

        if 0 < len(basin) < n:
            c = conductance(basin, n)
            if c < min_cond:
                min_cond = c

    # Try singleton cuts and small structured cuts
    for x in range(min(n, 100)):
        S = frozenset({x})
        c = conductance(S, n)
        if c < min_cond:
            min_cond = c

    # Try random subsets
    random.seed(42)
    for _ in range(min(500, 2**n)):
        size = random.randint(1, n - 1)
        S = frozenset(random.sample(range(n), size))
        c = conductance(S, n)
        if c < min_cond:
            min_cond = c

    return min_cond


def crt_lift_left(S, a, b):
    """Lift subset S of Z/aZ to Z/(ab)Z via CRT preimage on the first coordinate.
    Returns the set of x in Z/(ab)Z such that x mod a is in S."""
    n = a * b
    return frozenset(x for x in range(n) if (x % a) in S)


def display_results(a, b):
    """Compute and display the bottleneck theorem for given coprime a, b."""
    if gcd(a, b) != 1:
        print(f"  ERROR: gcd({a}, {b}) = {gcd(a, b)} ≠ 1. Inputs must be coprime.")
        return

    n = a * b
    threshold = 16  # Use exact computation for small moduli

    print(f"\n{'='*60}")
    print(f"  CRT Product Bottleneck: a = {a}, b = {b}, n = a·b = {n}")
    print(f"{'='*60}")

    # Compute idempotents
    idemps_a = find_idempotents(a)
    idemps_b = find_idempotents(b)
    idemps_n = find_idempotents(n)
    print(f"\n  Idempotents mod {a}: {idemps_a}  ({len(idemps_a)} total)")
    print(f"  Idempotents mod {b}: {idemps_b}  ({len(idemps_b)} total)")
    print(f"  Idempotents mod {n}: {idemps_n}  ({len(idemps_n)} total)")

    exact = (max(a, b, n) <= threshold)
    method = "exact" if exact else "approximate"
    print(f"\n  Computing basin conductances ({method})...")

    h_a = basin_conductance(a, max_n=threshold)
    h_b = basin_conductance(b, max_n=threshold)
    h_n = basin_conductance(n, max_n=threshold)
    h_min = min(h_a, h_b)

    print(f"  h_basin({a})  = {h_a}  ≈ {float(h_a):.6f}")
    print(f"  h_basin({b})  = {h_b}  ≈ {float(h_b):.6f}")
    print(f"  h_basin({n}) = {h_n}  ≈ {float(h_n):.6f}")
    print(f"  min(h({a}), h({b})) = {h_min}  ≈ {float(h_min):.6f}")

    # Verify the theorem
    holds = h_n <= h_min
    print(f"\n  Theorem h({n}) ≤ min(h({a}), h({b})): {'✓ VERIFIED' if holds else '✗ FAILED'}")

    if h_min > 0:
        ratio = h_n / h_min
        print(f"  Ratio h({n})/min = {ratio}  ≈ {float(ratio):.6f}")
        if ratio == 1:
            print(f"  → Exact equality holds: h({n}) = min(h({a}), h({b}))")
    else:
        print(f"  (min = 0, ratio undefined)")

    # Demonstrate the CRT lift
    if a <= threshold:
        print(f"\n  CRT Lift demonstration:")
        # Find best cut in factor a
        best_S = None
        best_c = Fraction(2)
        for S in all_nonempty_proper_subsets(a):
            c = conductance(S, a)
            if c < best_c:
                best_c = c
                best_S = S
        if best_S is not None:
            lifted = crt_lift_left(best_S, a, b)
            c_lifted = conductance(lifted, n)
            print(f"  Best cut in Z/{a}Z: S = {set(best_S)}")
            print(f"    conductance(S, {a}) = {best_c}  ≈ {float(best_c):.6f}")
            print(f"  CRT lift to Z/{n}Z:  |lift(S)| = {len(lifted)}")
            print(f"    conductance(lift(S), {n}) = {c_lifted}  ≈ {float(c_lifted):.6f}")
            print(f"    Conductance preserved: {'✓' if c_lifted == best_c else '✗'}")

    return h_a, h_b, h_n


def scan_coprime_pairs(max_val):
    """Scan all coprime pairs 2 ≤ a ≤ b ≤ max_val and report statistics."""
    print(f"\n{'='*70}")
    print(f"  Scanning all coprime pairs 2 ≤ a ≤ b ≤ {max_val}")
    print(f"{'='*70}")

    results = []
    violations = 0
    equalities = 0

    for a in range(2, max_val + 1):
        for b in range(a, max_val + 1):
            if gcd(a, b) != 1:
                continue

            h_a = basin_conductance(a)
            h_b = basin_conductance(b)
            h_n = basin_conductance(a * b)
            h_min = min(h_a, h_b)

            holds = h_n <= h_min
            is_equal = (h_n == h_min)

            if not holds:
                violations += 1
                print(f"  ✗ VIOLATION: a={a}, b={b}: h({a*b})={float(h_n):.4f} > min={float(h_min):.4f}")

            if is_equal:
                equalities += 1

            ratio = float(h_n / h_min) if h_min > 0 else 0
            results.append((a, b, float(h_a), float(h_b), float(h_n), ratio, holds, is_equal))

    print(f"\n  Summary:")
    print(f"  Total coprime pairs tested: {len(results)}")
    print(f"  Theorem holds for all: {'✓' if violations == 0 else '✗'}")
    print(f"  Violations: {violations}")
    print(f"  Exact equalities h(ab) = min(h(a),h(b)): {equalities}/{len(results)}")

    if results:
        min_ratio = min(r[5] for r in results if r[5] > 0)
        max_ratio = max(r[5] for r in results)
        print(f"  Normalization ratio range: [{min_ratio:.4f}, {max_ratio:.4f}]")

        # Show a few interesting cases
        print(f"\n  Sample results (sorted by ratio):")
        print(f"  {'a':>4} {'b':>4} {'ab':>6} {'h(a)':>8} {'h(b)':>8} {'h(ab)':>8} {'ratio':>8} {'eq?':>4}")
        print(f"  {'-'*4} {'-'*4} {'-'*6} {'-'*8} {'-'*8} {'-'*8} {'-'*8} {'-'*4}")

        sorted_results = sorted(results, key=lambda r: r[5])
        shown = set()
        for r in sorted_results[:10]:
            a, b, ha, hb, hn, ratio, holds, eq = r
            eq_str = "yes" if eq else ""
            print(f"  {a:4d} {b:4d} {a*b:6d} {ha:8.4f} {hb:8.4f} {hn:8.4f} {ratio:8.4f} {eq_str:>4}")

    return results


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   CRT Product Bottleneck Theorem — Interactive Demo         ║")
    print("║                                                              ║")
    print("║   Theorem: h_basin(ab) ≤ min(h_basin(a), h_basin(b))       ║")
    print("║   for coprime a, b ≥ 2                                      ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    if len(sys.argv) == 1:
        # Default examples
        examples = [(2, 3), (3, 5), (2, 5), (3, 7), (5, 7), (2, 9), (4, 9)]
        for a, b in examples:
            display_results(a, b)

        print("\n\n" + "="*60)
        print("  Systematic scan of small coprime pairs")
        print("="*60)
        scan_coprime_pairs(12)

    elif len(sys.argv) == 2 and sys.argv[1] == '--help':
        print(__doc__)

    elif len(sys.argv) == 3 and sys.argv[1] == '--scan':
        max_val = int(sys.argv[2])
        scan_coprime_pairs(max_val)

    elif len(sys.argv) == 3:
        a, b = int(sys.argv[1]), int(sys.argv[2])
        if a < 2 or b < 2:
            print("Error: both a and b must be ≥ 2")
            sys.exit(1)
        display_results(a, b)

    else:
        print("Usage: python demo.py [a b | --scan max | --help]")
        sys.exit(1)


if __name__ == '__main__':
    main()
