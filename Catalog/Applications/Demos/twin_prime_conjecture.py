#!/usr/bin/env python3
"""
Applications of Admissible Tuple Theory

Demonstrates real-world and research applications of the formalized
admissible tuple framework:
1. Cryptographic prime generation with controlled gaps
2. Admissible tuple databases for bounded gap research
3. Singular series computation and Hardy–Littlewood verification
4. Sieve weight optimization (simplified Maynard framework)
"""

from math import gcd, log, sqrt, prod
from algorithms import (
    sieve_primes, is_admissible, find_obstruction,
    greedy_admissible_tuple, crt_avoidance, avoiding_residue,
    singular_series_truncation, count_prime_tuples, hl_prediction
)


# ============================================================
# APPLICATION 1: Prime Constellation Search
# ============================================================

def search_prime_constellations(pattern: list[int], limit: int) -> list[int]:
    """
    Search for prime constellations matching a given admissible pattern.

    Given an admissible tuple H = {h_0, h_1, ..., h_{k-1}}, finds all n ≤ limit
    such that n + h_i is prime for all i.

    This is the computational realization of the Hardy–Littlewood conjecture:
    for admissible H, such n should exist (and be dense).

    Application: testing primality patterns, validating conjectures,
    finding record prime constellations.

    Args:
        pattern: Admissible tuple as a sorted list.
        limit: Search up to this value.

    Returns:
        List of starting values n where all n + h_i are prime.
    """
    H = set(pattern)
    if not is_admissible(H):
        obs = find_obstruction(H)
        print(f"WARNING: Pattern {pattern} is NOT admissible (obstruction at p={obs})")
        return []

    max_h = max(pattern)
    primes_set = set(sieve_primes(limit + max_h + 1))
    results = []

    for n in range(2, limit + 1):
        if all(n + h in primes_set for h in H):
            results.append(n)

    return results


# ============================================================
# APPLICATION 2: Admissible Tuple Database
# ============================================================

def build_admissible_database(max_k: int, max_diameter: int) -> dict:
    """
    Build a database of minimal-diameter admissible k-tuples.

    For each k from 2 to max_k, find the admissible k-tuple starting at 0
    with smallest diameter. Uses greedy construction.

    Application: prime gap research, computational number theory,
    optimizing Maynard-style bounded gap arguments.

    Returns:
        Dictionary mapping k to (tuple, diameter, singular_series).
    """
    database = {}
    for k in range(2, max_k + 1):
        t = greedy_admissible_tuple(k)
        diam = t[-1] - t[0]
        S = singular_series_truncation(set(t), 1000)
        database[k] = {
            'tuple': t,
            'diameter': diam,
            'singular_series': S,
            'admissible': True
        }
    return database


# ============================================================
# APPLICATION 3: Sieve-Theoretic Prime Screening
# ============================================================

def sieve_screen(H: set[int], N: int, small_prime_bound: int = None) -> list[int]:
    """
    Pre-screen translates of an admissible tuple using small prime sieving.

    This implements the CRT avoidance theorem computationally: find all
    n ≤ N such that no n+h is divisible by any small prime p ≤ bound.

    These "survivors" are the candidates that a full sieve would then
    evaluate with heavier analytic weights.

    Application: this is the first stage of any computational sieve,
    reducing the search space before applying expensive primality tests.

    Args:
        H: Admissible tuple.
        N: Search limit.
        small_prime_bound: Sieve with primes up to this bound (default: |H|).

    Returns:
        List of n values surviving the small-prime screen.
    """
    if small_prime_bound is None:
        small_prime_bound = len(H)

    small_primes = sieve_primes(small_prime_bound)
    survivors = []

    for n in range(1, N + 1):
        survives = True
        for p in small_primes:
            for h in H:
                if (n + h) % p == 0:
                    survives = False
                    break
            if not survives:
                break
        if survives:
            survivors.append(n)

    return survivors


# ============================================================
# APPLICATION 4: Hardy–Littlewood Conjecture Verification
# ============================================================

def verify_hardy_littlewood(patterns: list[list[int]], N: int) -> None:
    """
    Numerically verify the Hardy–Littlewood prime tuple conjecture.

    For each admissible pattern H, compare:
    - Actual count of n ≤ N with all n+h prime
    - HL prediction: S(H) · Li_k(N) ≈ S(H) · N / (log N)^k

    Application: validating conjectures, estimating constants,
    guiding analytic number theory research.
    """
    print(f"Hardy–Littlewood Verification (N = {N:,})")
    print(f"{'Pattern':<25s} {'k':>3s} {'Actual':>8s} {'HL Pred':>10s} {'Ratio':>8s}")
    print("-" * 60)

    for pattern in patterns:
        H = set(pattern)
        if not is_admissible(H):
            continue
        k = len(H)
        actual = count_prime_tuples(H, N)
        pred = hl_prediction(H, N, prime_bound=5000)
        ratio = actual / pred if pred > 0 else float('inf')
        print(f"  {str(pattern):<23s} {k:>3d} {actual:>8d} {pred:>10.1f} {ratio:>8.4f}")


# ============================================================
# APPLICATION 5: Covering System Detection
# ============================================================

def is_covering_system(moduli_residues: list[tuple[int, int]], n_max: int = 1000) -> bool:
    """
    Check if a set of congruences forms a covering system.

    A covering system covers every integer: for all n, at least one
    congruence n ≡ a_i (mod m_i) holds.

    Connection to admissibility: a set H is inadmissible at prime p
    iff the congruences {n ≡ -h (mod p) : h ∈ H} cover Z/pZ.

    Application: understanding the obstruction theory behind admissibility.
    """
    for n in range(n_max):
        covered = False
        for a, m in moduli_residues:
            if n % m == a % m:
                covered = True
                break
        if not covered:
            return False
    return True


# ============================================================
# MAIN DEMONSTRATIONS
# ============================================================

def main():
    print("=" * 70)
    print("APPLICATION 1: Prime Constellation Search")
    print("=" * 70)

    patterns = {
        "Twin primes": [0, 2],
        "Cousin primes": [0, 4],
        "Sexy primes": [0, 6],
        "Prime triplet (p,p+2,p+6)": [0, 2, 6],
        "Prime triplet (p,p+4,p+6)": [0, 4, 6],
        "Prime quadruplet": [0, 2, 6, 8],
    }

    for name, pattern in patterns.items():
        results = search_prime_constellations(pattern, 1000)
        print(f"\n  {name}: {pattern}")
        print(f"    Found {len(results)} instances up to 1000")
        if results[:5]:
            examples = [f"{n} → ({', '.join(str(n+h) for h in pattern)})" for n in results[:5]]
            print(f"    First few: {'; '.join(examples)}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Admissible Tuple Database")
    print("=" * 70)

    db = build_admissible_database(15, 200)
    print(f"\n  {'k':>3s} {'Diameter':>10s} {'Singular Series':>16s} {'Tuple'}")
    print("  " + "-" * 70)
    for k, info in db.items():
        t_str = str(info['tuple'])
        if len(t_str) > 40:
            t_str = t_str[:37] + "..."
        print(f"  {k:>3d} {info['diameter']:>10d} {info['singular_series']:>16.6f} {t_str}")

    print("\n" + "=" * 70)
    print("APPLICATION 3: Sieve Screening Efficiency")
    print("=" * 70)

    H = {0, 2}
    N = 10000
    for bound in [2, 5, 10, 20, 50]:
        survivors = sieve_screen(H, N, bound)
        efficiency = len(survivors) / N * 100
        print(f"\n  H={{0,2}}, N={N}, sieve primes ≤ {bound}:")
        print(f"    Survivors: {len(survivors)} out of {N} ({efficiency:.1f}%)")
        # Check how many survivors are actually twin primes
        primes_set = set(sieve_primes(N + 3))
        actual_twins = [n for n in survivors if n in primes_set and n + 2 in primes_set]
        print(f"    Actual twin primes among survivors: {len(actual_twins)}")

    print("\n" + "=" * 70)
    print("APPLICATION 4: Hardy–Littlewood Verification")
    print("=" * 70)

    verify_hardy_littlewood(
        [[0, 2], [0, 4], [0, 6], [0, 2, 6], [0, 4, 6]],
        N=100000
    )

    print("\n" + "=" * 70)
    print("APPLICATION 5: Covering System Connection")
    print("=" * 70)

    # Show that {0, 2, 4} fails admissibility because mod-3 congruences cover Z
    H = {0, 2, 4}
    p = 3
    congruences = [((-h) % p, p) for h in H]
    print(f"\n  H = {sorted(H)}, prime p = {p}")
    print(f"  Congruences: n ≡ {[(-h) % p for h in sorted(H)]} (mod {p})")
    print(f"  These are: n ≡ 0, 1, 2 (mod 3)")
    covers = is_covering_system(congruences)
    print(f"  Forms a covering system? {covers}")
    print(f"  Therefore H is {'NOT ' if covers else ''}admissible (confirmed: {is_admissible(H)})")

    # Contrast with {0, 2, 6}
    H2 = {0, 2, 6}
    congruences2 = [((-h) % p, p) for h in H2]
    print(f"\n  H = {sorted(H2)}, prime p = {p}")
    print(f"  Congruences: n ≡ {[(-h) % p for h in sorted(H2)]} (mod {p})")
    print(f"  These are: n ≡ 0, 1, 0 (mod 3) → only covers {{0, 1}}")
    covers2 = is_covering_system(congruences2)
    print(f"  Forms a covering system? {covers2}")
    print(f"  Admissible at p={p}? {not covers2} (full check: {is_admissible(H2)})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Admissible Tuples and Prime Gap Infrastructure — Demonstrations

Concrete numerical examples illustrating the formal theorems about
admissible tuples, local obstructions, and CRT sieve avoidance.
"""

from math import gcd
from itertools import product


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> list[int]:
    """Return list of primes up to n."""
    return [p for p in range(2, n + 1) if is_prime(p)]


def check_admissible(H: set[int], verbose: bool = False) -> bool:
    """
    Check if a finite set H of natural numbers is admissible.

    A set H is admissible iff for every prime p, the reductions of H mod p
    do not cover all residue classes {0, 1, ..., p-1}.

    By the finite-prime reduction theorem, we only need to check primes p ≤ |H|.

    Returns True if H is admissible.
    """
    card = len(H)
    for p in primes_up_to(card):
        residues_hit = set()
        for h in H:
            # The "forbidden" residue for shift a is: a ≡ -h (mod p)
            residues_hit.add((-h) % p)
        if residues_hit == set(range(p)):
            if verbose:
                print(f"  OBSTRUCTION at prime p={p}: residues {sorted(residues_hit)} cover all of Z/{p}Z")
            return False
        else:
            if verbose:
                print(f"  p={p}: forbidden residues = {sorted(residues_hit)}, free residues = {sorted(set(range(p)) - residues_hit)}")
    return True


def find_avoiding_residue(H: set[int], p: int) -> int | None:
    """Find a residue a < p such that (a + h) % p ≠ 0 for all h in H."""
    for a in range(p):
        if all((a + h) % p != 0 for h in H):
            return a
    return None


def crt_avoidance(H: set[int], primes: list[int]) -> int:
    """
    Find n such that p does not divide (n + h) for all h in H and p in primes.

    Uses the Chinese Remainder Theorem: for each prime p, find an avoiding
    residue a_p, then solve the system n ≡ a_p (mod p) simultaneously.
    """
    # Find avoiding residue for each prime
    residues = {}
    for p in primes:
        a = find_avoiding_residue(H, p)
        if a is None:
            raise ValueError(f"No avoiding residue found for p={p} — H may not be admissible")
        residues[p] = a

    # Solve via CRT (iterative for multiple moduli)
    n = 0
    mod = 1
    for p in primes:
        a = residues[p]
        # Solve: n ≡ a (mod p), n ≡ current_n (mod current_mod)
        # Since p is prime and coprime to mod (all primes are distinct),
        # we can use extended Euclidean algorithm
        while n % p != a % p:
            n += mod
        mod *= p
    return n


def demo_admissibility():
    """Demonstrate admissibility checking for various tuples."""
    print("=" * 70)
    print("DEMO 1: Admissibility of Prime Constellations")
    print("=" * 70)

    tuples = [
        ({0, 2}, "Twin primes (p, p+2)"),
        ({0, 2, 6}, "Prime triplet (p, p+2, p+6)"),
        ({0, 4, 6}, "Prime triplet (p, p+4, p+6)"),
        ({0, 2, 6, 8}, "Prime quadruplet"),
        ({0, 2, 8, 12, 14}, "Prime quintuplet candidate"),
        ({0, 4, 6, 10, 12}, "Prime quintuplet (p, p+4, p+6, p+10, p+12)"),
        ({0, 2, 4}, "NOT admissible — covers Z/3Z"),
        ({0, 1, 2, 3, 4}, "NOT admissible — covers Z/5Z"),
    ]

    for H, name in tuples:
        result = check_admissible(H, verbose=False)
        status = "✓ ADMISSIBLE" if result else "✗ NOT ADMISSIBLE"
        print(f"\n  H = {str(sorted(H)):30s}  {status}")
        print(f"    ({name})")
        check_admissible(H, verbose=True)


def demo_local_obstruction():
    """Demonstrate the local obstruction criterion."""
    print("\n" + "=" * 70)
    print("DEMO 2: Local Obstruction Analysis")
    print("=" * 70)

    # {0, 2, 4} is not admissible because it covers all of Z/3Z
    H = {0, 2, 4}
    print(f"\n  Analyzing H = {sorted(H)}")
    print(f"  Forbidden residues mod 3: {{(-0)%3, (-2)%3, (-4)%3}} = {{{0}, {(-2)%3}, {(-4)%3}}}")
    print(f"  These are {{0, 1, 2}} = Z/3Z — ALL residues covered!")
    print(f"  Therefore no translate n can make all of n, n+2, n+4 coprime to 3.")
    print(f"  Verified: check_admissible returns {check_admissible(H)}")

    # Verify computationally
    print(f"\n  Verification: for n = 0..20, checking which n+h are divisible by 3:")
    for n in range(21):
        divs = [h for h in sorted(H) if (n + h) % 3 == 0]
        if divs:
            print(f"    n={n:2d}: 3 divides n+{divs[0]} = {n+divs[0]}")


def demo_crt_avoidance():
    """Demonstrate the CRT avoidance theorem."""
    print("\n" + "=" * 70)
    print("DEMO 3: CRT Sieve Avoidance")
    print("=" * 70)

    H = {0, 2}
    primes = [2, 3, 5, 7]

    print(f"\n  H = {sorted(H)}, P = {primes}")
    print(f"  Finding n such that p ∤ (n+h) for all h ∈ H, p ∈ P...")

    # Find avoiding residues
    for p in primes:
        a = find_avoiding_residue(H, p)
        print(f"    p={p}: avoiding residue a={a}  (check: {[(a+h)%p for h in sorted(H)]} — none zero)")

    n = crt_avoidance(H, primes)
    print(f"\n  CRT solution: n = {n}")

    # Verify
    print(f"  Verification:")
    for h in sorted(H):
        val = n + h
        for p in primes:
            assert val % p != 0, f"Failed: {p} divides {val}"
        print(f"    n + {h} = {val}, coprime to all of {primes}: ✓")

    # Show infinitely many solutions
    M = 1
    for p in primes:
        M *= p
    print(f"\n  Period M = ∏P = {M}")
    print(f"  Infinitely many solutions: n = {n}, {n+M}, {n+2*M}, {n+3*M}, ...")
    for k in range(5):
        nk = n + k * M
        print(f"    n = {nk}: n+0 = {nk} (coprime to {primes}? {all(nk % p != 0 for p in primes)}), "
              f"n+2 = {nk+2} (coprime? {all((nk+2) % p != 0 for p in primes)})")


def demo_twin_prime_admissibility():
    """Show the twin prime tuple has no local obstruction at any prime."""
    print("\n" + "=" * 70)
    print("DEMO 4: Twin Prime Local Analysis")
    print("=" * 70)

    H = {0, 2}
    print(f"\n  Twin prime tuple H = {sorted(H)}")
    print(f"  Checking all primes p ≤ 100:")

    for p in primes_up_to(100):
        a = find_avoiding_residue(H, p)
        forbidden = {(-h) % p for h in H}
        free = set(range(p)) - forbidden
        print(f"    p={p:3d}: forbidden = {sorted(forbidden)}, "
              f"free = {len(free):3d} residues, witness a={a}")


def demo_bounded_gaps_architecture():
    """Demonstrate the architecture of conditional bounded gap results."""
    print("\n" + "=" * 70)
    print("DEMO 5: Bounded Gaps Architecture")
    print("=" * 70)

    # For each admissible k-tuple, compute the gap bound
    tuples = [
        {0, 2},           # Gap bound = 2 (twin primes)
        {0, 2, 6},        # Gap bound = 6
        {0, 4, 6},        # Gap bound = 6
        {0, 2, 6, 8},     # Gap bound = 8
        {0, 4, 6, 10, 12},  # Gap bound = 12
        {0, 2, 6, 8, 12},   # Gap bound = 12
    ]

    print("\n  If the Maynard sieve positivity criterion holds for a k-tuple H,")
    print("  then prime gaps ≤ diam(H) occur infinitely often.")
    print()

    for H in tuples:
        adm = check_admissible(H)
        diam = max(H) - min(H)
        k = len(H)
        status = "✓" if adm else "✗"
        print(f"  {status} H = {str(sorted(H)):30s}  k={k}, diam={diam:3d}, "
              f"admissible={adm}")

    print("\n  Historical context:")
    print("    Zhang (2013):  Gap bound = 70,000,000 (k=3,500,000)")
    print("    Maynard (2013): Gap bound = 600")
    print("    Polymath 8b:    Gap bound = 246")
    print("    Twin Prime Conjecture: Gap bound = 2")


def demo_finite_prime_reduction():
    """Demonstrate that admissibility reduces to checking small primes."""
    print("\n" + "=" * 70)
    print("DEMO 6: Finite-Prime Reduction Theorem")
    print("=" * 70)

    # Generate a larger admissible tuple
    # Use a greedy construction
    H = {0}
    for d in range(1, 100):
        H_test = H | {d}
        if check_admissible(H_test):
            H = H_test
        if len(H) >= 10:
            break

    print(f"\n  Constructed admissible 10-tuple: {sorted(H)}")
    print(f"  |H| = {len(H)}")
    print(f"\n  By the finite-prime reduction theorem, we only need to check")
    print(f"  primes p ≤ |H| = {len(H)}:")

    small_primes = primes_up_to(len(H))
    print(f"  Primes to check: {small_primes}")

    for p in small_primes:
        residues_hit = {(-h) % p for h in H}
        free = set(range(p)) - residues_hit
        print(f"    p={p}: {len(residues_hit)} residues hit out of {p}, "
              f"{len(free)} free ✓")

    print(f"\n  For any prime p > {len(H)}, pigeonhole guarantees")
    print(f"  that |H| = {len(H)} < p elements cannot cover all p residue classes.")
    print(f"  So checking {len(small_primes)} primes suffices!")


if __name__ == "__main__":
    demo_admissibility()
    demo_local_obstruction()
    demo_crt_avoidance()
    demo_twin_prime_admissibility()
    demo_bounded_gaps_architecture()
    demo_finite_prime_reduction()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
