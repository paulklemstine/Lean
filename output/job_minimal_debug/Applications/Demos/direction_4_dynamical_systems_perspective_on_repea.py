#!/usr/bin/env python3
"""
Applications of the Dynamical Squaring Framework

Demonstrates real-world applications of idempotent-based factorization
and the dynamical structure of the squaring map on Z/nZ.

Applications:
1. Factorization via idempotent detection
2. RSA-style modulus analysis
3. Orbit entropy as a compositeness certificate
4. Basin structure visualization (text-based)
5. Comparison with Miller-Rabin
"""

import math
import time
import random
from typing import Dict, List, Tuple, Set, Optional
from collections import Counter


# ─── Core Functions ─────────────────────────────────────────────────────

def squaring_map(x: int, n: int) -> int:
    return pow(x, 2, n)

def find_idempotents(n: int) -> List[int]:
    return sorted([x for x in range(n) if pow(x, 2, n) == x])

def prime_factors(n: int) -> List[int]:
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return factors

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    d = 5
    while d * d <= n:
        if n % d == 0 or n % (d + 2) == 0: return False
        d += 6
    return True


# ─── Application 1: Factorization via Idempotent Detection ─────────────

def factor_via_idempotent(n: int) -> Optional[Tuple[int, int]]:
    """
    Factor n by finding a nontrivial idempotent and extracting gcd.

    If e is idempotent with e ≠ 0,1, then gcd(e, n) is a nontrivial factor.
    This works because e(e-1) ≡ 0 mod n with e and e-1 coprime,
    so n must split between e and e-1.

    This is a brute-force demonstration; in practice, one would use
    randomized methods to find idempotents.
    """
    for e in range(2, n):
        if pow(e, 2, n) == e:
            g = math.gcd(e, n)
            if 1 < g < n:
                return (g, n // g)
    return None


def demo_factorization():
    """Demonstrate factorization via idempotent detection."""
    print("\n" + "="*60)
    print("  APPLICATION 1: Factorization via Idempotent Detection")
    print("="*60)

    test_cases = [6, 10, 15, 21, 35, 77, 91, 143, 221, 323]

    print(f"\n  {'n':>5}  {'Idempotent':>12}  {'gcd(e,n)':>10}  {'Factorization':>20}")
    print(f"  {'─'*55}")

    for n in test_cases:
        result = factor_via_idempotent(n)
        idemps = find_idempotents(n)
        nontrivial = [e for e in idemps if e not in (0, 1)]
        if result:
            e = nontrivial[0]
            p, q = result
            print(f"  {n:5d}  e={e:<10d}  {math.gcd(e,n):>10d}  {p} × {q}")
        else:
            print(f"  {n:5d}  {'none':>12}  {'—':>10}  {'prime or prime power':>20}")


# ─── Application 2: RSA Modulus Analysis ────────────────────────────────

def analyze_rsa_modulus(p: int, q: int):
    """
    Analyze a small RSA-style modulus n = p*q from the dynamical perspective.

    Shows how the factorization creates a rich dynamical landscape
    with 4 idempotents and multiple basins.
    """
    n = p * q
    idemps = find_idempotents(n)

    print(f"\n  RSA Modulus: n = {p} × {q} = {n}")
    print(f"  Idempotents: {idemps}")

    # Show the "spectral idempotents" and their factorization content
    for e in idemps:
        if e not in (0, 1):
            g1 = math.gcd(e, n)
            g2 = math.gcd(e - 1, n) if e > 0 else n
            print(f"  Spectral idempotent e={e}:")
            print(f"    gcd(e, n) = gcd({e}, {n}) = {g1}")
            print(f"    gcd(e-1, n) = gcd({e-1}, {n}) = {g2}")
            print(f"    → Reveals factor {g1}!")


def demo_rsa():
    """Demonstrate RSA modulus analysis."""
    print("\n" + "="*60)
    print("  APPLICATION 2: RSA-Style Modulus Analysis")
    print("="*60)
    print("  The spectral idempotents of n=pq directly encode p and q.")

    for p, q in [(3, 5), (7, 11), (13, 17), (23, 29), (31, 37)]:
        analyze_rsa_modulus(p, q)


# ─── Application 3: Orbit Entropy as Compositeness Certificate ─────────

def orbit_entropy(n: int) -> float:
    """Compute Shannon entropy of orbit type distribution."""
    types = Counter()
    for a in range(n):
        # Compute orbit type using Floyd's algorithm
        tortoise = squaring_map(a, n)
        hare = squaring_map(squaring_map(a, n), n)
        while tortoise != hare:
            tortoise = squaring_map(tortoise, n)
            hare = squaring_map(squaring_map(hare, n), n)
        rho = 0
        tortoise = a
        while tortoise != hare:
            tortoise = squaring_map(tortoise, n)
            hare = squaring_map(hare, n)
            rho += 1
        lam = 1
        hare = squaring_map(tortoise, n)
        while tortoise != hare:
            hare = squaring_map(hare, n)
            lam += 1
        types[(rho, lam)] += 1

    total = n
    H = 0.0
    for count in types.values():
        p = count / total
        if p > 0:
            H -= p * math.log2(p)
    return H


def demo_entropy():
    """Demonstrate orbit entropy as a compositeness indicator."""
    print("\n" + "="*60)
    print("  APPLICATION 3: Orbit Entropy as Compositeness Certificate")
    print("="*60)
    print("  Higher entropy indicates richer dynamical structure (more factors).")

    # Compare entropy for primes vs composites in a range
    print(f"\n  {'n':>5}  {'Type':>10}  {'ω(n)':>5}  {'H(n)':>10}  {'Bar':>20}")
    print(f"  {'─'*55}")

    for n in range(2, 50):
        if n <= 1:
            continue
        factors = prime_factors(n)
        omega = len(factors)
        H = orbit_entropy(n)
        bar = "█" * int(H * 5)
        ptype = "prime" if is_prime(n) else "composite"
        print(f"  {n:5d}  {ptype:>10}  {omega:5d}  {H:10.4f}  {bar}")

    # Superadditivity test
    print("\n  Superadditivity Test: H(pq) vs H(p) + H(q) - log₂(2)")
    print(f"  {'p':>5}  {'q':>5}  {'H(p)':>8}  {'H(q)':>8}  {'H(pq)':>8}  {'H(p)+H(q)-1':>14}  {'Super?':>8}")
    print(f"  {'─'*60}")

    for p, q in [(3, 5), (3, 7), (5, 7), (7, 11), (11, 13)]:
        if math.gcd(p, q) != 1:
            continue
        Hp = orbit_entropy(p)
        Hq = orbit_entropy(q)
        Hpq = orbit_entropy(p * q)
        bound = Hp + Hq - 1.0
        is_super = "YES" if Hpq >= bound - 0.01 else "NO"
        print(f"  {p:5d}  {q:5d}  {Hp:8.4f}  {Hq:8.4f}  {Hpq:8.4f}  {bound:14.4f}  {is_super:>8}")


# ─── Application 4: Basin Structure Visualization ──────────────────────

def demo_basins():
    """Visualize basin structure for small n."""
    print("\n" + "="*60)
    print("  APPLICATION 4: Basin Structure Visualization")
    print("="*60)

    for n in [13, 15, 21]:
        print(f"\n  Basins of attraction for Z/{n}Z under x ↦ x² mod {n}:")
        idemps = find_idempotents(n)

        # Compute which basin each element falls into
        element_basin = {}
        for a in range(n):
            x = a
            for _ in range(n + 10):
                x = squaring_map(x, n)
            element_basin[a] = x

        # Group by basin
        basins = {}
        for a in range(n):
            b = element_basin[a]
            if b not in basins:
                basins[b] = []
            basins[b].append(a)

        symbols = "●○◆◇★☆▲△"
        for i, (attractor, elements) in enumerate(sorted(basins.items())):
            sym = symbols[i % len(symbols)]
            marker = " (trivial)" if attractor in (0, 1) else " (SPECTRAL)"
            print(f"    {sym} Basin of e={attractor}{marker}: {elements}")

        # ASCII visualization
        print(f"\n    Position map (element → basin attractor):")
        print(f"    ", end="")
        for a in range(n):
            b = element_basin[a]
            idx = sorted(basins.keys()).index(b)
            print(symbols[idx % len(symbols)], end="")
        print()
        print(f"    Elements: ", end="")
        for a in range(n):
            print(f"{a%10}", end="")
        print()


# ─── Application 5: Comparison with Miller-Rabin ───────────────────────

def miller_rabin_test(n: int, a: int) -> bool:
    """Single round of Miller-Rabin test with witness a."""
    if n < 2:
        return False
    if n == 2 or n == 3:
        return True
    if n % 2 == 0:
        return False

    # Write n-1 = 2^s * d
    s, d = 0, n - 1
    while d % 2 == 0:
        s += 1
        d //= 2

    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return True  # probably prime

    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True  # probably prime

    return False  # composite


def demo_comparison():
    """Compare idempotent detection with Miller-Rabin."""
    print("\n" + "="*60)
    print("  APPLICATION 5: Idempotent Detection vs Miller-Rabin")
    print("="*60)
    print("  Idempotent detection is DETERMINISTIC for ω(n) ≥ 2.")
    print("  Miller-Rabin is probabilistic but faster for large n.")

    print(f"\n  {'n':>5}  {'Actual':>10}  {'MR(a=2)':>10}  {'MR(a=3)':>10}  {'Idempotent':>12}  {'Factor':>8}")
    print(f"  {'─'*60}")

    test_values = [4, 6, 8, 9, 10, 15, 21, 25, 49, 77, 91, 341, 561]

    for n in test_values:
        actual = "prime" if is_prime(n) else "composite"
        mr2 = "pass" if miller_rabin_test(n, 2) else "FAIL"
        mr3 = "pass" if miller_rabin_test(n, 3) else "FAIL"

        result = factor_via_idempotent(n)
        if result:
            idemp_result = "COMPOSITE"
            factor = str(result[0])
        else:
            idemps = find_idempotents(n)
            if len(idemps) == 2:
                idemp_result = "prime/pp"
                factor = "—"
            else:
                idemp_result = "prime pwr"
                factor = "—"

        print(f"  {n:5d}  {actual:>10}  {mr2:>10}  {mr3:>10}  {idemp_result:>12}  {factor:>8}")

    # Highlight: 341 = 11 × 31 is a Fermat pseudoprime to base 2
    print(f"\n  Note: 341 is a Fermat pseudoprime to base 2 (2^340 ≡ 1 mod 341)")
    print(f"  But idempotent detection always correctly identifies composites with ω ≥ 2")

    # Highlight: 561 = 3 × 11 × 17 is a Carmichael number
    print(f"\n  Note: 561 = 3×11×17 is a Carmichael number (fools ALL Fermat bases)")
    print(f"  Idempotents of 561: {find_idempotents(561)}")
    print(f"  → {len(find_idempotents(561))} = 2³ idempotents correctly detected!")


# ─── Main ──────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of the Dynamical Squaring Framework          ║")
    print("║  Idempotents as Attractors in the Repeated Squaring Map    ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    demo_factorization()
    demo_rsa()
    demo_entropy()
    demo_basins()
    demo_comparison()

    print("\n" + "="*60)
    print("  All applications demonstrated successfully.")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Dynamical Systems Perspective on Repeated Squaring: Interactive Demo

Visualizes the functional graph G(f_n) of the squaring map x ↦ x² mod n,
colors basins of attraction of each idempotent, displays orbit type statistics,
and compares prime vs. composite inputs side by side.

Usage:
    python demo.py           # Run with default examples
    python demo.py 15        # Analyze a specific n
    python demo.py 13 15     # Compare two values side by side
"""

import sys
import math
from collections import defaultdict, Counter
from typing import Dict, List, Tuple, Set, Optional


def squaring_map(x: int, n: int) -> int:
    """The squaring map f(x) = x² mod n."""
    return (x * x) % n


def compute_orbit(a: int, n: int, max_iter: int = 1000) -> List[int]:
    """Compute the orbit of a under x ↦ x² mod n."""
    orbit = [a]
    seen = {a: 0}
    x = a
    for i in range(1, max_iter):
        x = squaring_map(x, n)
        if x in seen:
            break
        seen[x] = i
        orbit.append(x)
    return orbit


def orbit_type(a: int, n: int) -> Tuple[int, int]:
    """
    Compute the orbit type (preperiod ρ, period λ) of a under x ↦ x² mod n.

    The orbit is: a, f(a), f²(a), ..., f^ρ(a), ..., f^(ρ+λ-1)(a), f^(ρ+λ)(a) = f^ρ(a)
    """
    tortoise = squaring_map(a, n)
    hare = squaring_map(squaring_map(a, n), n)

    # Phase 1: Find a meeting point inside the cycle
    while tortoise != hare:
        tortoise = squaring_map(tortoise, n)
        hare = squaring_map(squaring_map(hare, n), n)

    # Phase 2: Find the start of the cycle (preperiod ρ)
    rho = 0
    tortoise = a
    while tortoise != hare:
        tortoise = squaring_map(tortoise, n)
        hare = squaring_map(hare, n)
        rho += 1

    # Phase 3: Find the period λ
    lam = 1
    hare = squaring_map(tortoise, n)
    while tortoise != hare:
        hare = squaring_map(hare, n)
        lam += 1

    return (rho, lam)


def find_idempotents(n: int) -> List[int]:
    """Find all idempotents e in Z/nZ: elements where e² ≡ e (mod n)."""
    return [x for x in range(n) if (x * x) % n == x]


def prime_factors(n: int) -> List[int]:
    """Return the distinct prime factors of n."""
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return factors


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    d = 5
    while d * d <= n:
        if n % d == 0 or n % (d + 2) == 0:
            return False
        d += 6
    return True


def basin_of_attraction(n: int, e: int) -> Set[int]:
    """Find the basin of attraction of idempotent e under repeated squaring."""
    basin = set()
    for a in range(n):
        x = a
        for _ in range(n + 10):  # Enough iterations to converge
            x = squaring_map(x, n)
        if x == e:
            basin.add(a)
    return basin


def orbit_type_distribution(n: int) -> Dict[Tuple[int, int], int]:
    """Compute the distribution of orbit types in Z/nZ."""
    dist = Counter()
    for a in range(n):
        ot = orbit_type(a, n)
        dist[ot] += 1
    return dict(dist)


def orbit_entropy(n: int) -> float:
    """Compute the Shannon entropy of the orbit type distribution."""
    dist = orbit_type_distribution(n)
    total = sum(dist.values())
    entropy = 0.0
    for count in dist.values():
        p = count / total
        if p > 0:
            entropy -= p * math.log2(p)
    return entropy


def functional_graph_ascii(n: int, max_display: int = 30) -> str:
    """Generate an ASCII representation of the functional graph."""
    lines = []
    if n > max_display:
        lines.append(f"  (Showing first {max_display} elements of Z/{n}Z)")
        display_range = range(max_display)
    else:
        display_range = range(n)

    for x in display_range:
        fx = squaring_map(x, n)
        arrow = f"  {x:3d} → {fx:3d}"
        # Mark idempotents
        if fx == x:
            arrow += "  ★ FIXED POINT (idempotent)"
        lines.append(arrow)

    return "\n".join(lines)


def analyze_number(n: int) -> None:
    """Perform a complete dynamical analysis of the squaring map on Z/nZ."""
    print(f"\n{'='*70}")
    print(f"  DYNAMICAL ANALYSIS OF x ↦ x² mod {n}")
    print(f"{'='*70}")

    # Basic properties
    factors = prime_factors(n)
    omega = len(factors)
    primality = "PRIME" if is_prime(n) else "COMPOSITE"

    print(f"\n  n = {n}  ({primality})")
    print(f"  Prime factorization: {' × '.join(str(f) for f in factors)}")
    print(f"  ω(n) = {omega} (distinct prime factors)")

    # Idempotents
    idemps = find_idempotents(n)
    print(f"\n  Idempotents (fixed points of squaring map):")
    print(f"  Count: {len(idemps)} (predicted: 2^{omega} = {2**omega})")
    print(f"  Elements: {idemps}")

    # Verify the theorem
    nontrivial = [e for e in idemps if e != 0 and e != 1]
    if nontrivial:
        print(f"  ✓ Nontrivial idempotents found: {nontrivial}")
        print(f"    These are the 'spectral idempotents' encoding the factorization!")
        for e in nontrivial:
            print(f"    e={e}: residues mod factors = {[e % f for f in factors]}")
    else:
        print(f"  No nontrivial idempotents (consistent with prime/prime-power)")

    # Basins of attraction
    if n <= 100:
        print(f"\n  Basins of attraction:")
        for e in idemps:
            basin = basin_of_attraction(n, e)
            print(f"    Basin of e={e}: {sorted(basin)} (size {len(basin)})")

    # Orbit types
    dist = orbit_type_distribution(n)
    print(f"\n  Orbit type distribution (ρ, λ) → count:")
    for ot in sorted(dist.keys()):
        rho, lam = ot
        print(f"    (ρ={rho}, λ={lam}): {dist[ot]} elements")
    print(f"  Number of distinct orbit types: {len(dist)}")

    # Entropy
    H = orbit_entropy(n)
    print(f"  Orbit entropy H({n}) = {H:.4f} bits")

    # Functional graph
    print(f"\n  Functional graph x → x² mod {n}:")
    print(functional_graph_ascii(n))


def compare_prime_composite(p: int, c: int) -> None:
    """Compare a prime and composite number side by side."""
    print(f"\n{'#'*70}")
    print(f"  COMPARISON: PRIME {p} vs COMPOSITE {c}")
    print(f"{'#'*70}")

    for n in [p, c]:
        analyze_number(n)

    # Summary comparison
    idemps_p = find_idempotents(p)
    idemps_c = find_idempotents(c)
    H_p = orbit_entropy(p)
    H_c = orbit_entropy(c)
    dist_p = orbit_type_distribution(p)
    dist_c = orbit_type_distribution(c)

    print(f"\n{'='*70}")
    print(f"  SUMMARY COMPARISON")
    print(f"{'='*70}")
    print(f"  {'Metric':<35} {'Prime '+str(p):<15} {'Composite '+str(c):<15}")
    print(f"  {'─'*65}")
    print(f"  {'Idempotent count':<35} {len(idemps_p):<15} {len(idemps_c):<15}")
    print(f"  {'Nontrivial idempotents':<35} {len([e for e in idemps_p if e not in (0,1)]):<15} {len([e for e in idemps_c if e not in (0,1)]):<15}")
    print(f"  {'Distinct orbit types':<35} {len(dist_p):<15} {len(dist_c):<15}")
    print(f"  {'Orbit entropy (bits)':<35} {H_p:<15.4f} {H_c:<15.4f}")
    print(f"\n  Key insight: The composite number has MORE idempotents and")
    print(f"  HIGHER orbit entropy — the extra fixed points fragment the")
    print(f"  dynamical landscape, creating a detectable signature of compositeness.")


def demo_trajectory(n: int, start: int) -> None:
    """Animate the trajectory of a point falling into its basin."""
    print(f"\n  Trajectory of {start} under x ↦ x² mod {n}:")
    print(f"  {'─'*50}")

    orbit = compute_orbit(start, n)
    rho, lam = orbit_type(start, n)
    idemps = find_idempotents(n)

    for i, x in enumerate(orbit):
        marker = ""
        if x in idemps:
            marker = " ★ (idempotent!)"
        if i == 0:
            print(f"    Step {i:3d}: {x:5d}  ← start{marker}")
        elif i < len(orbit) - 1:
            print(f"    Step {i:3d}: {x:5d}{marker}")
        else:
            print(f"    Step {i:3d}: {x:5d}  ← cycle detected{marker}")

    print(f"  Orbit type: (ρ={rho}, λ={lam})")
    print(f"  Pre-period: {rho}, Period: {lam}")

    # Find which basin we're in
    terminal = orbit[-1]
    for _ in range(n + 10):
        terminal = squaring_map(terminal, n)
    print(f"  Terminal fixed point (basin attractor): {terminal}")


def main():
    if len(sys.argv) == 1:
        # Default demo
        print("╔══════════════════════════════════════════════════════════════════════╗")
        print("║  IDEMPOTENTS AS ATTRACTORS: The Dynamical Signature of Factorization║")
        print("║  in the Repeated Squaring Map x ↦ x² mod n                         ║")
        print("╚══════════════════════════════════════════════════════════════════════╝")

        # Demo 1: Small prime vs small composite
        print("\n\n" + "="*70)
        print("  DEMO 1: Small Examples — Seeing the Pattern")
        print("="*70)
        for n in [5, 6, 7, 12, 15, 30]:
            idemps = find_idempotents(n)
            factors = prime_factors(n)
            status = "prime" if is_prime(n) else "composite"
            print(f"  n={n:3d} ({status:9s}): ω={len(factors)}, "
                  f"idempotents={idemps}, count={len(idemps)} = 2^{len(factors)}")

        # Demo 2: Detailed comparison
        print("\n\n" + "="*70)
        print("  DEMO 2: Prime vs Composite — Detailed Comparison")
        print("="*70)
        compare_prime_composite(13, 15)

        # Demo 3: Trajectory animation
        print("\n\n" + "="*70)
        print("  DEMO 3: Trajectory Animation — Falling into a Basin")
        print("="*70)
        demo_trajectory(15, 7)
        demo_trajectory(15, 2)
        demo_trajectory(13, 5)

        # Demo 4: Entropy comparison
        print("\n\n" + "="*70)
        print("  DEMO 4: Orbit Entropy — Information-Theoretic Signature")
        print("="*70)
        print(f"  {'n':>5}  {'Type':>10}  {'ω(n)':>5}  {'#Idemp':>7}  {'#OrbTypes':>10}  {'Entropy':>10}")
        print(f"  {'─'*55}")
        for n in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 30, 35, 42]:
            factors = prime_factors(n)
            idemps = find_idempotents(n)
            dist = orbit_type_distribution(n)
            H = orbit_entropy(n)
            status = "prime" if is_prime(n) else "composite"
            print(f"  {n:5d}  {status:>10}  {len(factors):5d}  {len(idemps):7d}  "
                  f"{len(dist):10d}  {H:10.4f}")

        # Demo 5: The CRT decomposition
        print("\n\n" + "="*70)
        print("  DEMO 5: CRT Orbit Decomposition — n=15=3×5")
        print("="*70)
        n, p, q = 15, 3, 5
        print(f"  Orbit types in Z/{n}Z decompose via CRT into Z/{p}Z × Z/{q}Z:")
        print(f"  {'a':>3} {'a%3':>4} {'a%5':>4} {'OT(a,15)':>12} {'OT(a%3,3)':>12} {'OT(a%5,5)':>12}")
        print(f"  {'─'*50}")
        for a in range(n):
            ot_n = orbit_type(a, n)
            ot_p = orbit_type(a % p, p)
            ot_q = orbit_type(a % q, q)
            expected = (max(ot_p[0], ot_q[0]), math.lcm(ot_p[1], ot_q[1]))
            match = "✓" if ot_n == expected else "✗"
            print(f"  {a:3d} {a%p:4d} {a%q:4d} {str(ot_n):>12} {str(ot_p):>12} {str(ot_q):>12}  {match}")
        print(f"\n  ✓ = orbit type equals (max(ρ₁,ρ₂), lcm(λ₁,λ₂)) as predicted by CRT")

    elif len(sys.argv) == 2:
        n = int(sys.argv[1])
        analyze_number(n)
    elif len(sys.argv) == 3:
        n1, n2 = int(sys.argv[1]), int(sys.argv[2])
        compare_prime_composite(n1, n2)
    else:
        print("Usage: python demo.py [n] [n2]")


if __name__ == "__main__":
    main()
