#!/usr/bin/env python3
"""
Applications of Orbit-Order Duality

Real-world applications demonstrating how the orbit-order duality
theorem connects squaring dynamics to number theory and cryptography.
"""

import math
import random
from typing import Dict, List, Tuple


def multiplicative_order(a: int, n: int) -> int:
    """Compute ord_n(a)."""
    if n <= 1:
        return 1
    a = a % n
    if math.gcd(a, n) != 1:
        return 0
    k, power = 1, a
    while power != 1:
        power = (power * a) % n
        k += 1
        if k > n:
            return 0
    return k


def squaring_orbit_period(x: int, n: int) -> int:
    """Compute squaring orbit period of x mod n."""
    if math.gcd(x, n) != 1:
        return 0
    x = x % n
    current = (x * x) % n
    for k in range(1, n + 1):
        if current == x:
            return k
        current = (current * current) % n
    return 0


def is_prime(n: int) -> bool:
    """Simple primality test."""
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


# ─── Application 1: RSA Key Analysis ─────────────────────────────────────

def rsa_orbit_analysis(p: int, q: int) -> Dict:
    """Analyze the orbit structure of RSA modulus n = pq.

    Shows how the squaring orbit periods leak information about
    the factorization of n via the orbit-order duality.

    Args:
        p, q: Prime factors of the RSA modulus

    Returns:
        Analysis dictionary with orbit statistics.
    """
    n = p * q
    phi_n = (p - 1) * (q - 1)

    # Compute all orbit periods
    period_counts: Dict[int, int] = {}
    units_with_odd_order = 0

    for x in range(1, n):
        if math.gcd(x, n) != 1:
            continue
        d = multiplicative_order(x, n)
        if d % 2 == 1:
            units_with_odd_order += 1
            per = squaring_orbit_period(x, n)
            period_counts[per] = period_counts.get(per, 0) + 1

    # Periods that could leak factors
    factoring_periods = []
    for per in period_counts:
        val = pow(2, per) - 1
        g = math.gcd(val, n)
        if 1 < g < n:
            factoring_periods.append((per, g, period_counts[per]))

    return {
        "n": n,
        "p": p,
        "q": q,
        "phi_n": phi_n,
        "total_units": phi_n,
        "units_odd_order": units_with_odd_order,
        "distinct_periods": len(period_counts),
        "period_distribution": dict(sorted(period_counts.items())),
        "factoring_periods": factoring_periods,
        "vulnerability_ratio": len(factoring_periods) / max(len(period_counts), 1),
    }


# ─── Application 2: Pseudorandom Generator Quality ──────────────────────

def squaring_prng_analysis(n: int, seed: int, length: int = 100) -> Dict:
    """Analyze the quality of x ↦ x² mod n as a PRNG.

    The Blum-Blum-Shub generator uses this map. The orbit-order duality
    tells us exactly how periodic the output will be.

    Args:
        n: Modulus (should be a Blum integer for BBS)
        seed: Initial value
        length: Number of values to generate

    Returns:
        Analysis of the generated sequence.
    """
    sequence = []
    x = seed % n
    for _ in range(length):
        x = (x * x) % n
        sequence.append(x)

    # Detect actual period
    seen = {}
    period = 0
    preperiod = 0
    for i, val in enumerate(sequence):
        if val in seen:
            preperiod = seen[val]
            period = i - seen[val]
            break
        seen[val] = i

    # Predicted period via duality (if seed is a unit)
    predicted_period = 0
    if math.gcd(seed, n) == 1:
        d = multiplicative_order(seed, n)
        if d > 0 and d % 2 == 1:
            predicted_period = multiplicative_order(2, d)

    return {
        "n": n,
        "seed": seed,
        "actual_period": period,
        "predicted_period": predicted_period,
        "preperiod": preperiod,
        "match": period == predicted_period if predicted_period > 0 else None,
        "sequence_prefix": sequence[:20],
    }


# ─── Application 3: Discrete Logarithm Connections ──────────────────────

def orbit_dlog_connection(p: int) -> Dict:
    """Show the connection between orbit periods and discrete logarithms.

    For prime p, the orbit period of g^a under squaring is ord_{p-1}(2)
    when gcd(a, p-1) divides the odd part of p-1. This creates a
    connection between orbit-based attacks and Pohlig-Hellman.

    Args:
        p: A prime number

    Returns:
        Analysis of orbit-DLP connections.
    """
    if not is_prime(p):
        return {"error": "p is not prime"}

    # Find a generator
    g = 2
    while multiplicative_order(g, p) != p - 1:
        g += 1
        if g >= p:
            return {"error": "no generator found"}

    # For each power g^a, compute orbit period
    orbit_data = []
    for a in range(1, p):
        x = pow(g, a, p)
        d = multiplicative_order(x, p)  # = (p-1) / gcd(a, p-1)
        per = squaring_orbit_period(x, p)
        orbit_data.append({
            "a": a,
            "x": x,
            "order": d,
            "period": per,
            "ord_d_2": multiplicative_order(2, d) if d % 2 == 1 else 0,
        })

    return {
        "p": p,
        "generator": g,
        "orbit_data": orbit_data[:20],  # first 20 entries
        "total_units": p - 1,
    }


# ─── Application 4: Functional Graph Fingerprinting ─────────────────────

def functional_graph_fingerprint(n: int) -> Dict:
    """Compute the functional graph fingerprint of the squaring map on (Z/nZ)*.

    The fingerprint is the multiset of cycle lengths, which by the
    orbit-order duality equals the multiset of ord_d(2) values.
    Different factorizations of n produce different fingerprints.

    Args:
        n: Modulus

    Returns:
        Functional graph fingerprint.
    """
    cycle_lengths: Dict[int, int] = {}
    visited = set()

    for x in range(1, n):
        if math.gcd(x, n) != 1 or x in visited:
            continue

        # Trace the orbit
        orbit = []
        current = x
        orbit_set = set()
        while current not in orbit_set and current not in visited:
            orbit_set.add(current)
            orbit.append(current)
            current = (current * current) % n

        if current in orbit_set:
            # Found a new cycle
            cycle_start = orbit.index(current)
            cycle_len = len(orbit) - cycle_start
            cycle_lengths[cycle_len] = cycle_lengths.get(cycle_len, 0) + 1

        visited.update(orbit_set)

    return {
        "n": n,
        "cycle_lengths": dict(sorted(cycle_lengths.items())),
        "num_cycles": sum(cycle_lengths.values()),
        "max_cycle": max(cycle_lengths.keys()) if cycle_lengths else 0,
    }


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║       Applications of Orbit-Order Duality                      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    # Application 1: RSA analysis
    print("═══ Application 1: RSA Key Analysis ═══")
    for p, q in [(7, 11), (11, 13), (23, 29)]:
        result = rsa_orbit_analysis(p, q)
        print(f"\nn = {p} × {q} = {result['n']}:")
        print(f"  φ(n) = {result['phi_n']}")
        print(f"  Units with odd order: {result['units_odd_order']}")
        print(f"  Distinct orbit periods: {result['distinct_periods']}")
        print(f"  Period distribution: {result['period_distribution']}")
        if result['factoring_periods']:
            print(f"  FACTORING PERIODS (leak a factor):")
            for per, factor, count in result['factoring_periods']:
                print(f"    Period {per}: gcd(2^{per}-1, {result['n']}) = {factor} ({count} units)")
        print(f"  Vulnerability ratio: {result['vulnerability_ratio']:.2%}")

    # Application 2: PRNG analysis
    print("\n\n═══ Application 2: BBS PRNG Quality Analysis ═══")
    for n in [77, 143, 323]:
        for seed in [3, 5, 7]:
            result = squaring_prng_analysis(n, seed, 200)
            if result['actual_period'] > 0:
                print(f"  n={n}, seed={seed}: period={result['actual_period']}, "
                      f"predicted={result['predicted_period']}, match={result['match']}")

    # Application 3: Functional graph fingerprints
    print("\n\n═══ Application 3: Functional Graph Fingerprints ═══")
    print("(Different factorizations → different fingerprints)")
    for n in [15, 21, 35, 77, 143]:
        fp = functional_graph_fingerprint(n)
        print(f"  n = {n}: cycles = {fp['cycle_lengths']}, total = {fp['num_cycles']}")

    # Comparison: primes vs composites
    print("\n  Primes:")
    for p in [7, 11, 13, 17, 19, 23]:
        fp = functional_graph_fingerprint(p)
        print(f"    p = {p}: cycles = {fp['cycle_lengths']}")


#!/usr/bin/env python3
"""
Orbit-Order Duality: Demonstrations and Visualizations

Demonstrates the orbit-order duality theorem for the squaring map
f(x) = x^2 mod n on (Z/nZ)*. Shows that squaring orbit periods
encode factorization information about n.

Usage:
    python demo.py
"""

import math
import random
from collections import Counter
from typing import Dict, List, Tuple

# ─── Core Functions ───────────────────────────────────────────────────────

def multiplicative_order(a: int, n: int) -> int:
    """Compute the multiplicative order of a modulo n (smallest k>0 with a^k ≡ 1 mod n).
    Returns 0 if gcd(a,n) != 1."""
    if math.gcd(a, n) != 1:
        return 0
    if n == 1:
        return 1
    k = 1
    power = a % n
    while power != 1:
        power = (power * a) % n
        k += 1
        if k > n:
            return 0  # shouldn't happen
    return k


def squaring_orbit_period(x: int, n: int) -> int:
    """Compute the period of x under iterated squaring mod n.
    Returns the smallest k > 0 such that x^(2^k) ≡ x (mod n),
    or 0 if no such k exists within n steps."""
    if math.gcd(x, n) != 1:
        return 0
    val = x % n
    current = (val * val) % n
    for k in range(1, n + 1):
        if current == val:
            return k
        current = (current * current) % n
    return 0


def orbit_period_via_duality(x: int, n: int) -> int:
    """Compute squaring orbit period using the orbit-order duality theorem:
    per_f(x) = ord_{ord_n(x)}(2)."""
    d = multiplicative_order(x, n)
    if d == 0 or d % 2 == 0:
        return 0  # only works for odd order
    return multiplicative_order(2, d)


def euler_totient(n: int) -> int:
    """Euler's totient function φ(n)."""
    count = 0
    for i in range(1, n):
        if math.gcd(i, n) == 1:
            count += 1
    return max(count, 1)


def get_units(n: int) -> List[int]:
    """Get all units in (Z/nZ)*."""
    return [x for x in range(1, n) if math.gcd(x, n) == 1]


def is_prime(n: int) -> bool:
    """Simple primality test."""
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


# ─── Demo 1: Verify Orbit-Order Duality ──────────────────────────────────

def demo_verify_duality():
    """Verify the orbit-order duality theorem on concrete examples."""
    print("=" * 70)
    print("DEMO 1: Verifying Orbit-Order Duality Theorem")
    print("=" * 70)
    print()
    print("For x ∈ (Z/nZ)* with odd order d = ord_n(x):")
    print("  squaring period of x = ord_d(2)")
    print()

    test_cases = [7, 11, 13, 15, 21, 35, 77, 105]
    for n in test_cases:
        units = get_units(n)
        print(f"n = {n} (φ(n) = {len(units)}):")
        verified = 0
        total = 0
        for x in units:
            d = multiplicative_order(x, n)
            if d % 2 == 1:  # odd order
                direct = squaring_orbit_period(x, n)
                via_duality = orbit_period_via_duality(x, n)
                total += 1
                if direct == via_duality:
                    verified += 1
                else:
                    print(f"  MISMATCH: x={x}, d={d}, direct={direct}, duality={via_duality}")
        print(f"  Verified {verified}/{total} units with odd order ✓")
    print()


# ─── Demo 2: Orbit Period Distributions ──────────────────────────────────

def demo_orbit_distributions():
    """Show orbit period distributions for primes vs composites."""
    print("=" * 70)
    print("DEMO 2: Orbit Period Distributions (Primes vs Composites)")
    print("=" * 70)
    print()

    # Primes
    primes = [p for p in range(3, 100) if is_prime(p)]
    print("PRIMES:")
    print(f"{'p':>5} {'φ(p)':>5} {'avg period':>12} {'max period':>12} {'# periods':>10}")
    print("-" * 50)
    for p in primes[:15]:
        units = get_units(p)
        periods = []
        for x in units:
            per = squaring_orbit_period(x, p)
            if per > 0:
                periods.append(per)
        if periods:
            avg = sum(periods) / len(periods)
            print(f"{p:>5} {p-1:>5} {avg:>12.2f} {max(periods):>12} {len(set(periods)):>10}")

    print()
    # Composites (semiprimes)
    composites = []
    for p in range(3, 50):
        if not is_prime(p):
            continue
        for q in range(p + 2, 50):
            if is_prime(q):
                composites.append(p * q)
                if len(composites) >= 15:
                    break
        if len(composites) >= 15:
            break

    print("SEMIPRIMES (n = p*q):")
    print(f"{'n':>5} {'φ(n)':>5} {'avg period':>12} {'max period':>12} {'# periods':>10}")
    print("-" * 50)
    for n in composites[:15]:
        units = get_units(n)
        periods = []
        for x in units:
            per = squaring_orbit_period(x, n)
            if per > 0:
                periods.append(per)
        if periods:
            avg = sum(periods) / len(periods)
            print(f"{n:>5} {len(units):>5} {avg:>12.2f} {max(periods):>12} {len(set(periods)):>10}")
    print()


# ─── Demo 3: GCD Factoring Attack ────────────────────────────────────────

def demo_gcd_factoring():
    """Demonstrate GCD factoring using orbit periods."""
    print("=" * 70)
    print("DEMO 3: GCD Factoring via Orbit Periods")
    print("=" * 70)
    print()
    print("For composite n, compute orbit period k of random x,")
    print("then check if gcd(x^(2^k) - 1, n) gives a nontrivial factor.")
    print()

    # Test on semiprimes
    semiprimes = []
    primes_list = [p for p in range(101, 500) if is_prime(p)]
    for i in range(min(20, len(primes_list))):
        for j in range(i + 1, min(20, len(primes_list))):
            semiprimes.append((primes_list[i], primes_list[j]))
            if len(semiprimes) >= 30:
                break
        if len(semiprimes) >= 30:
            break

    successes = 0
    total = 0
    print(f"{'n':>12} {'p':>5} {'q':>5} {'x':>6} {'period':>7} {'gcd':>8} {'factor?':>8}")
    print("-" * 60)

    for p, q in semiprimes[:20]:
        n = p * q
        total += 1
        found = False
        # Try up to 10 random units
        for _ in range(10):
            x = random.randint(2, n - 1)
            if math.gcd(x, n) != 1:
                # Already found a factor!
                found = True
                break
            d = multiplicative_order(x, n)
            if d % 2 == 0:
                continue
            k = multiplicative_order(2, d)
            if k == 0:
                continue
            # Compute gcd(x^(2^k) - 1, n)
            val = pow(x, pow(2, k, n * n) - 1, n)
            g = math.gcd(val, n)
            if 1 < g < n:
                print(f"{n:>12} {p:>5} {q:>5} {x:>6} {k:>7} {g:>8} {'YES':>8}")
                found = True
                break
        if found:
            successes += 1
        else:
            print(f"{n:>12} {p:>5} {q:>5} {'--':>6} {'--':>7} {'--':>8} {'NO':>8}")

    print()
    print(f"Success rate: {successes}/{total} = {successes/max(total,1)*100:.1f}%")
    print()


# ─── Demo 4: Orbit Period vs Order Statistics ────────────────────────────

def demo_period_statistics():
    """Compare average orbit periods for primes vs composites."""
    print("=" * 70)
    print("DEMO 4: Statistical Separation of Primes and Composites")
    print("=" * 70)
    print()

    results = []
    for n in range(3, 200):
        units = get_units(n)
        if len(units) < 2:
            continue
        periods = []
        for x in units:
            per = squaring_orbit_period(x, n)
            if per > 0:
                periods.append(per)
        if periods:
            avg = sum(periods) / len(periods)
            max_per = max(periods)
            n_distinct = len(set(periods))
            results.append((n, is_prime(n), avg, max_per, n_distinct, len(units)))

    # Summary statistics
    prime_avgs = [r[2] / math.log(r[0]) for r in results if r[1]]
    composite_avgs = [r[2] / math.log(r[0]) for r in results if not r[1]]

    print(f"Normalized average orbit period (avg_period / log(n)):")
    print(f"  Primes:     mean = {sum(prime_avgs)/len(prime_avgs):.4f}, "
          f"std = {(sum((x - sum(prime_avgs)/len(prime_avgs))**2 for x in prime_avgs)/len(prime_avgs))**0.5:.4f}")
    print(f"  Composites: mean = {sum(composite_avgs)/len(composite_avgs):.4f}, "
          f"std = {(sum((x - sum(composite_avgs)/len(composite_avgs))**2 for x in composite_avgs)/len(composite_avgs))**0.5:.4f}")
    print()

    # Show distinct period counts
    prime_distinct = [r[4] for r in results if r[1]]
    composite_distinct = [r[4] for r in results if not r[1]]
    print(f"Number of distinct orbit periods:")
    print(f"  Primes:     mean = {sum(prime_distinct)/len(prime_distinct):.2f}")
    print(f"  Composites: mean = {sum(composite_distinct)/len(composite_distinct):.2f}")
    print()


# ─── Demo 5: CRT Decomposition ───────────────────────────────────────────

def demo_crt_decomposition():
    """Show how orbit periods decompose via CRT for composites n = p*q."""
    print("=" * 70)
    print("DEMO 5: CRT Decomposition of Orbit Periods")
    print("=" * 70)
    print()
    print("For n = p*q, per_f(x) = lcm(ord_{ord_p(x_p)}(2), ord_{ord_q(x_q)}(2))")
    print("where x_p = x mod p, x_q = x mod q")
    print()

    test_cases = [(3, 5), (5, 7), (7, 11), (11, 13), (3, 11), (5, 13)]
    for p, q in test_cases:
        n = p * q
        print(f"n = {p} × {q} = {n}:")
        verified = 0
        total = 0
        for x in range(2, n):
            if math.gcd(x, n) != 1:
                continue
            xp, xq = x % p, x % q
            dp = multiplicative_order(xp, p)
            dq = multiplicative_order(xq, q)
            if dp % 2 == 0 or dq % 2 == 0:
                continue

            direct = squaring_orbit_period(x, n)
            ordp = multiplicative_order(2, dp) if dp > 0 else 0
            ordq = multiplicative_order(2, dq) if dq > 0 else 0
            if ordp == 0 or ordq == 0:
                continue

            crt_pred = math.lcm(ordp, ordq)
            total += 1
            if direct == crt_pred:
                verified += 1
            else:
                print(f"  x={x}: direct={direct}, lcm(ord_{dp}(2)={ordp}, ord_{dq}(2)={ordq})={crt_pred}")
        print(f"  Verified {verified}/{total} units ✓")
    print()


# ─── Demo 6: Orbit Period Table ──────────────────────────────────────────

def demo_orbit_table():
    """Display orbit period tables for small n."""
    print("=" * 70)
    print("DEMO 6: Orbit Period Tables")
    print("=" * 70)
    print()

    for n in [7, 11, 15, 21]:
        print(f"n = {n}:")
        print(f"{'x':>4} {'ord_n(x)':>9} {'period':>7} {'ord_d(2)':>9} {'match':>6}")
        print("-" * 40)
        for x in range(1, n):
            if math.gcd(x, n) != 1:
                continue
            d = multiplicative_order(x, n)
            per = squaring_orbit_period(x, n)
            if d > 0 and d % 2 == 1:
                ord2 = multiplicative_order(2, d)
                match = "✓" if per == ord2 else "✗"
                print(f"{x:>4} {d:>9} {per:>7} {ord2:>9} {match:>6}")
            else:
                print(f"{x:>4} {d:>9} {per:>7} {'N/A':>9} {'':>6}")
        print()


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     ORBIT-ORDER DUALITY: Squaring Map Period-Finding Demos          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_verify_duality()
    demo_orbit_table()
    demo_orbit_distributions()
    demo_crt_decomposition()
    demo_period_statistics()
    demo_gcd_factoring()
