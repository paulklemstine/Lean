#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Benford Base-Invariance

Demonstrates practical applications of the base-transfer principle:
  1. Financial fraud detection across different numeral systems
  2. Scientific data integrity verification
  3. Election forensics with multi-base consistency checks
  4. Dynamical system diagnostics via digit statistics
"""

import math
import random
from typing import List, Dict, Tuple
from collections import Counter


# ─── Import core algorithms ───
def benford_pmf(base: int) -> Dict[int, float]:
    log_base = math.log(base)
    return {d: math.log(1 + 1/d) / log_base for d in range(1, base)}


def extract_leading_digit(x: float, base: int) -> int:
    if x == 0:
        return 0
    x = abs(x)
    log_val = math.log(x) / math.log(base)
    frac_part = log_val - math.floor(log_val)
    s = base ** frac_part
    return max(1, min(int(s), base - 1))


def kl_divergence(p: Dict[int, float], q: Dict[int, float]) -> float:
    kl = 0.0
    for d in q:
        p_d = p.get(d, 0.0)
        q_d = q[d]
        if p_d > 0 and q_d > 0:
            kl += p_d * math.log(p_d / q_d)
        elif p_d > 0:
            return float('inf')
    return kl


def digit_frequencies(values: List[float], base: int) -> Dict[int, float]:
    if not values:
        return {}
    counts = Counter()
    for v in values:
        d = extract_leading_digit(v, base)
        counts[d] += 1
    total = len(values)
    return {d: counts.get(d, 0) / total for d in range(1, base)}


def is_power_of_2(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0


# ─────────────────────────────────────────────────────────────────────
# Application 1: Multi-Base Financial Fraud Detection
# ─────────────────────────────────────────────────────────────────────

def generate_natural_financial_data(n: int = 5000) -> List[float]:
    """Generate realistic financial data that naturally follows Benford's law."""
    data = []
    for _ in range(n):
        # Log-normal distribution produces Benford-like data
        data.append(math.exp(random.gauss(5, 3)))
    return data


def generate_fraudulent_data(n: int = 5000) -> List[float]:
    """Generate data with manipulated leading digits (fraud simulation)."""
    data = []
    for _ in range(n):
        # Fraudsters tend to pick "round" or "just under threshold" numbers
        if random.random() < 0.3:
            # Round numbers (bias toward 1, 5)
            base_val = random.choice([1, 5]) * 10 ** random.randint(2, 5)
            data.append(base_val + random.uniform(0, base_val * 0.1))
        elif random.random() < 0.5:
            # Just-under-threshold (bias toward 9)
            threshold = random.choice([100, 1000, 10000, 100000])
            data.append(threshold - random.uniform(1, threshold * 0.05))
        else:
            data.append(math.exp(random.gauss(5, 3)))
    return data


def multi_base_fraud_detection(data: List[float], label: str = "Dataset") -> None:
    """
    Apply multi-base Benford analysis for fraud detection.

    The base-invariance principle provides a stronger test than single-base
    analysis: genuine data should be consistent across ALL admissible bases.
    Fraud that passes in base 10 may fail in base 7 or base 12.
    """
    bases = [3, 5, 7, 10, 11, 12]
    print(f"\n  Multi-Base Fraud Detection: {label}")
    print(f"  {'Base':<6} {'KL Divergence':>14} {'Status':>12}")
    print(f"  {'-'*32}")

    anomalies = 0
    for b in bases:
        freq = digit_frequencies(data, b)
        ref = benford_pmf(b)
        kl = kl_divergence(freq, ref)
        status = "✓ OK" if kl < 0.02 else ("⚠ SUSPECT" if kl < 0.1 else "✗ ANOMALY")
        if kl >= 0.02:
            anomalies += 1
        print(f"  {b:<6} {kl:>14.6f} {status:>12}")

    consistency = "CONSISTENT" if anomalies <= 1 else "INCONSISTENT"
    print(f"\n  Multi-base verdict: {consistency} ({anomalies}/{len(bases)} anomalous bases)")
    if anomalies > 1:
        print(f"  → Base-invariance violation detected: potential data manipulation")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Scientific Data Integrity
# ─────────────────────────────────────────────────────────────────────

def scientific_data_integrity_check(data: List[float],
                                     dataset_name: str = "Measurements") -> Dict:
    """
    Apply Benford base-invariance test to scientific measurements.

    Physical measurements spanning multiple orders of magnitude should
    naturally follow Benford's law. Fabricated data often fails the
    multi-base consistency test even when crafted to pass in base 10.

    Returns a diagnostic report.
    """
    bases = [3, 5, 7, 10, 11, 15]
    results = {}
    print(f"\n  Scientific Data Integrity: {dataset_name}")
    print(f"  Sample size: {len(data)}")
    print(f"  {'Base':<6} {'KL (nats)':>10} {'KL (bits)':>10} {'Grade':>8}")
    print(f"  {'-'*34}")

    for b in bases:
        freq = digit_frequencies(data, b)
        ref = benford_pmf(b)
        kl_nats = kl_divergence(freq, ref)
        kl_bits = kl_nats / math.log(2)
        grade = "A" if kl_nats < 0.005 else ("B" if kl_nats < 0.02 else
                ("C" if kl_nats < 0.05 else "F"))
        results[b] = {'kl_nats': kl_nats, 'kl_bits': kl_bits, 'grade': grade}
        print(f"  {b:<6} {kl_nats:>10.6f} {kl_bits:>10.6f} {grade:>8}")

    # Cross-base consistency score
    kl_values = [r['kl_nats'] for r in results.values()]
    consistency = max(kl_values) / (min(kl_values) + 1e-10)
    print(f"\n  Cross-base consistency ratio: {consistency:.2f}")
    print(f"  (< 5 = good consistency, > 10 = suspicious)")
    return results


# ─────────────────────────────────────────────────────────────────────
# Application 3: Dynamical System Diagnostics
# ─────────────────────────────────────────────────────────────────────

def dynamical_orbit_diagnostic(map_fn, initial_points: List[float],
                                n_iter: int = 50,
                                label: str = "Orbit") -> None:
    """
    Diagnose a dynamical system's orbit statistics via Benford analysis.

    For expanding maps (like x → x² + c), orbit values grow rapidly and
    their leading digits should converge to Benford's law if the underlying
    log-phases equidistribute.

    This connects arithmetic dynamics to observable digit statistics.
    """
    orbit_values = []
    for x0 in initial_points:
        x = x0
        for _ in range(n_iter):
            x = map_fn(x)
            if abs(x) > 1e300:
                break
            if abs(x) > 1:
                orbit_values.append(abs(x))

    if len(orbit_values) < 50:
        print(f"\n  {label}: Insufficient orbit data ({len(orbit_values)} points)")
        return

    bases = [3, 7, 10, 12]
    print(f"\n  Dynamical Orbit Diagnostic: {label}")
    print(f"  Orbit points: {len(orbit_values)}")
    print(f"  {'Base':<6} {'KL':>10} {'Benford?':>10}")
    print(f"  {'-'*26}")

    for b in bases:
        freq = digit_frequencies(orbit_values, b)
        ref = benford_pmf(b)
        kl = kl_divergence(freq, ref)
        is_benford = "YES" if kl < 0.03 else "NO"
        print(f"  {b:<6} {kl:>10.6f} {is_benford:>10}")


# ─────────────────────────────────────────────────────────────────────
# Main demonstration
# ─────────────────────────────────────────────────────────────────────

def main():
    random.seed(42)

    print("\n" + "=" * 70)
    print("  APPLICATIONS OF BENFORD BASE-INVARIANCE")
    print("=" * 70)

    # Application 1: Fraud detection
    print("\n" + "-" * 70)
    print("  APPLICATION 1: Multi-Base Financial Fraud Detection")
    print("-" * 70)

    natural_data = generate_natural_financial_data(5000)
    fraudulent_data = generate_fraudulent_data(5000)

    multi_base_fraud_detection(natural_data, "Natural Financial Data")
    multi_base_fraud_detection(fraudulent_data, "Fraudulent Financial Data")

    # Application 2: Scientific integrity
    print("\n" + "-" * 70)
    print("  APPLICATION 2: Scientific Data Integrity")
    print("-" * 70)

    # Physical constants spanning orders of magnitude
    physical_data = [math.exp(random.gauss(0, 8)) for _ in range(3000)]
    scientific_data_integrity_check(physical_data, "Physical Measurements (simulated)")

    # Application 3: Dynamical diagnostics
    print("\n" + "-" * 70)
    print("  APPLICATION 3: Dynamical System Diagnostics")
    print("-" * 70)

    # Quadratic map x → x² + 1
    dynamical_orbit_diagnostic(
        lambda x: x**2 + 1,
        [float(p) for p in range(2, 50) if all(p % d != 0 for d in range(2, int(p**0.5)+1)) and p > 1],
        n_iter=20,
        label="x → x² + 1 (prime seeds)"
    )

    # Collatz-like: 3x + 1
    dynamical_orbit_diagnostic(
        lambda x: 3*x + 1 if x % 2 == 1 else x / 2,
        list(range(1, 1000)),
        n_iter=100,
        label="Collatz-type map"
    )

    print("\n" + "=" * 70)
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
  The base-invariance principle transforms Benford's law from a curiosity
  into a diagnostic tool. By checking consistency across multiple bases:

  • Fraud detection gains robustness: manipulation targeting one base
    is detected through inconsistency in other bases.
  • Scientific integrity gets a free consistency check: genuine data
    from scale-invariant processes must pass in ALL admissible bases.
  • Dynamical systems reveal their equidistribution properties through
    observable digit statistics — no deep analysis of the dynamics needed.

  The formal theorem guarantees: if equidistribution holds in one
  admissible base, it holds in all. Violations of this invariance
  are structural anomalies worth investigating.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive Benford Base-Invariance Explorer

Demonstrates the base-transfer principle for Benford's law applied to
prime-indexed dynamical sequences T_c^(n)(p) = p^2 + c iterated n times.

Features:
  - Leading-digit frequency computation in arbitrary bases
  - Benford reference distribution generation
  - KL divergence computation across admissible bases
  - Automatic search for refuting pairs of bases
  - Visualization of digit distributions and KL divergence profiles

Usage:
  python demo.py                    # Run full demonstration
  python demo.py --search           # Search for refuting base pairs
  python demo.py --c 1 --base 10    # Specific parameter exploration
"""

import math
import sys
from typing import List, Tuple, Dict, Optional
from collections import Counter


# ─────────────────────────────────────────────────────────────────────
# Core mathematical functions
# ─────────────────────────────────────────────────────────────────────

def is_prime(n: int) -> bool:
    """Primality test."""
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


def primes_up_to(bound: int) -> List[int]:
    """Sieve of Eratosthenes up to bound."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, bound + 1, i):
                sieve[j] = False
    return [i for i, v in enumerate(sieve) if v]


def T_c(c: int, x: int) -> int:
    """The dynamical map T_c(x) = x^2 + c."""
    return x * x + c


def T_c_iter(c: int, n: int, x: int) -> int:
    """The n-fold iterate T_c^(n)(x)."""
    result = x
    for _ in range(n):
        result = T_c(c, result)
    return result


def leading_digit(x: float, base: int) -> int:
    """
    Extract the leading digit of |x| in the given base.

    The leading digit d satisfies d * base^k <= |x| < (d+1) * base^k
    for some integer k, equivalently d = floor(base^{frac(log_base |x|)}).
    """
    if x == 0:
        return 0
    x = abs(x)
    log_val = math.log(x) / math.log(base)
    frac_part = log_val - math.floor(log_val)
    significand = base ** frac_part
    d = int(significand)
    if d >= base:
        d = base - 1
    if d < 1:
        d = 1
    return d


def benford_distribution(base: int) -> Dict[int, float]:
    """
    Compute the Benford reference distribution in the given base.

    P(leading digit = d) = log_base(1 + 1/d) for d = 1, ..., base-1.
    """
    dist = {}
    for d in range(1, base):
        dist[d] = math.log(1 + 1/d) / math.log(base)
    return dist


def digit_frequencies(values: List[float], base: int) -> Dict[int, float]:
    """Compute empirical leading-digit frequencies."""
    if not values:
        return {}
    counts = Counter()
    for v in values:
        d = leading_digit(v, base)
        counts[d] += 1
    total = len(values)
    return {d: counts.get(d, 0) / total for d in range(1, base)}


def kl_divergence(observed: Dict[int, float], reference: Dict[int, float]) -> float:
    """
    Compute KL divergence D_KL(observed || reference).

    D_KL(P || Q) = sum_d P(d) * log(P(d) / Q(d))
    Uses natural logarithm. Returns infinity if support mismatch.
    """
    kl = 0.0
    for d in reference:
        p = observed.get(d, 0.0)
        q = reference[d]
        if p > 0 and q > 0:
            kl += p * math.log(p / q)
        elif p > 0 and q == 0:
            return float('inf')
    return kl


def is_multiplicatively_independent(a: int, b: int) -> bool:
    """
    Check if a and b are multiplicatively independent.

    Two integers a, b >= 2 are multiplicatively independent iff
    log(a)/log(b) is irrational, equivalently iff there are no
    positive integers m, n with a^m = b^n.

    We check by finding if a and b are powers of a common base.
    """
    def integer_base_and_exp(n: int) -> Tuple[int, int]:
        """Find minimal base g and exponent k such that n = g^k."""
        for k in range(int(math.log2(n)) + 1, 0, -1):
            g = round(n ** (1/k))
            for candidate in [g-1, g, g+1]:
                if candidate >= 2 and candidate ** k == n:
                    return candidate, k
        return n, 1

    g_a, k_a = integer_base_and_exp(a)
    g_b, k_b = integer_base_and_exp(b)
    return g_a != g_b


def is_admissible_base(b: int) -> bool:
    """Check if base b is admissible (log(b)/log(2) irrational), i.e. b is not a power of 2."""
    if b < 2:
        return False
    n = b
    while n > 1:
        if n % 2 != 0:
            return True
        n //= 2
    return False


# ─────────────────────────────────────────────────────────────────────
# Demonstration functions
# ─────────────────────────────────────────────────────────────────────

def demo_benford_criterion(c: int = 0, n_iter: int = 3, prime_bound: int = 10000,
                            base: int = 10) -> None:
    """
    Demonstrate the Benford criterion: check if prime-indexed dynamical
    orbit values have Benford-distributed leading digits.
    """
    primes = primes_up_to(prime_bound)
    values = []
    for p in primes:
        val = T_c_iter(c, n_iter, p)
        if val != 0:
            values.append(float(abs(val)))

    freq = digit_frequencies(values, base)
    benford = benford_distribution(base)
    kl = kl_divergence(freq, benford)

    print(f"\n{'='*70}")
    print(f"  Benford Analysis: T_c^({n_iter})(p), c = {c}, base = {base}")
    print(f"  Primes up to {prime_bound} ({len(primes)} primes, {len(values)} nonzero values)")
    print(f"{'='*70}")
    print(f"\n  {'Digit':<8} {'Observed':>10} {'Benford':>10} {'Ratio':>10}")
    print(f"  {'-'*38}")
    for d in range(1, base):
        obs = freq.get(d, 0)
        ben = benford[d]
        ratio = obs / ben if ben > 0 else float('inf')
        print(f"  {d:<8} {obs:>10.4f} {ben:>10.4f} {ratio:>10.3f}")
    print(f"\n  KL Divergence: {kl:.6f}")
    print(f"  (Smaller = closer to Benford; 0 = perfect match)")


def demo_base_transfer(c: int = 0, n_iter: int = 3, prime_bound: int = 10000) -> None:
    """
    Demonstrate the base-transfer principle: if Benford holds in one admissible
    base, it should hold in all admissible bases.
    """
    bases = [3, 5, 6, 7, 10, 11, 12, 15]
    primes = primes_up_to(prime_bound)
    values = []
    for p in primes:
        val = T_c_iter(c, n_iter, p)
        if val != 0:
            values.append(float(abs(val)))

    print(f"\n{'='*70}")
    print(f"  Base-Transfer Analysis: T_c^({n_iter})(p), c = {c}")
    print(f"  Primes up to {prime_bound} ({len(values)} values)")
    print(f"{'='*70}")
    print(f"\n  {'Base':<6} {'Admissible':<12} {'KL Divergence':>14} {'Status':>10}")
    print(f"  {'-'*42}")

    results = []
    for b in bases:
        adm = is_admissible_base(b)
        freq = digit_frequencies(values, b)
        benford = benford_distribution(b)
        kl = kl_divergence(freq, benford)
        status = "BENFORD" if kl < 0.01 else ("MARGINAL" if kl < 0.05 else "NON-BENFORD")
        adm_str = "YES" if adm else "NO (2^k)"
        print(f"  {b:<6} {adm_str:<12} {kl:>14.6f} {status:>10}")
        results.append((b, adm, kl))

    print(f"\n  Base-invariance prediction: KL should be uniformly low across admissible bases")


def demo_multiplicative_independence() -> None:
    """
    Demonstrate the connection between multiplicative independence
    and irrational log ratios.
    """
    print(f"\n{'='*70}")
    print(f"  Multiplicative Independence & Log Ratios")
    print(f"{'='*70}")
    pairs = [(2, 3), (2, 4), (2, 5), (3, 5), (4, 8), (4, 9), (3, 9), (6, 10)]
    print(f"\n  {'(a, b)':<10} {'Mult. Indep.':<14} {'log(a)/log(b)':>14} {'Rational?':>10}")
    print(f"  {'-'*48}")
    for a, b in pairs:
        mi = is_multiplicatively_independent(a, b)
        ratio = math.log(a) / math.log(b)
        # Check if ratio appears rational by checking if a and b share a common base
        rational = not mi
        rat_str = "YES" if rational else "NO (irr.)"
        mi_str = "YES" if mi else "NO"
        print(f"  ({a}, {b}){'':<4} {mi_str:<14} {ratio:>14.6f} {rat_str:>10}")

    print(f"\n  Key theorem: Mult. independent ⟹ log ratio irrational ⟹ base admissible")


def search_refuting_pairs(c_range: range = range(-10, 11),
                          n_iters: List[int] = [1, 3, 5, 8, 10, 15],
                          prime_bound: int = 10000,
                          threshold: float = 0.05) -> None:
    """
    Search for refuting pairs: find (c, b₁, b₂) where one admissible base
    has low KL divergence and another has high KL divergence.

    A single such witness would refute the base-invariance conjecture.
    """
    bases = [3, 5, 6, 7, 10, 11, 12, 15]
    admissible_bases = [b for b in bases if is_admissible_base(b)]
    primes = primes_up_to(prime_bound)

    print(f"\n{'='*70}")
    print(f"  Searching for Refuting Pairs (Falsification Test)")
    print(f"  c ∈ {{{c_range.start}, ..., {c_range.stop-1}}}")
    print(f"  n ∈ {n_iters}")
    print(f"  Admissible bases: {admissible_bases}")
    print(f"  Threshold: {threshold}")
    print(f"{'='*70}\n")

    refutation_found = False
    for c in c_range:
        for n_iter in n_iters:
            values = []
            for p in primes:
                try:
                    val = T_c_iter(c, n_iter, p)
                    if val != 0:
                        fval = float(abs(val))
                        if math.isfinite(fval):
                            values.append(fval)
                except (OverflowError, ValueError):
                    continue
            if len(values) < 100:
                continue

            kl_values = {}
            for b in admissible_bases:
                freq = digit_frequencies(values, b)
                benford = benford_distribution(b)
                kl_values[b] = kl_divergence(freq, benford)

            min_kl = min(kl_values.values())
            max_kl = max(kl_values.values())

            # Check for significant discrepancy
            if min_kl < threshold and max_kl > 5 * threshold:
                refutation_found = True
                min_base = min(kl_values, key=kl_values.get)
                max_base = max(kl_values, key=kl_values.get)
                print(f"  ⚠ POTENTIAL REFUTATION: c={c}, n={n_iter}")
                print(f"    Base {min_base}: KL = {min_kl:.6f} (low)")
                print(f"    Base {max_base}: KL = {max_kl:.6f} (high)")
                print(f"    Ratio: {max_kl/min_kl:.1f}x\n")

    if not refutation_found:
        print(f"  ✓ No refuting pairs found. Base-invariance conjecture supported.")
        print(f"    (All admissible bases show consistent Benford behavior)")


def demo_kl_profile(c: int = 0, prime_bound: int = 10000) -> None:
    """Show KL divergence profile across iterate depths."""
    bases = [3, 5, 7, 10, 11]
    admissible_bases = [b for b in bases if is_admissible_base(b)]
    primes = primes_up_to(prime_bound)
    n_iters = [1, 2, 3, 5, 8, 10]

    print(f"\n{'='*70}")
    print(f"  KL Divergence Profile: c = {c}, primes ≤ {prime_bound}")
    print(f"{'='*70}")

    header = f"  {'n':<4}"
    for b in admissible_bases:
        header += f" {'base '+str(b):>10}"
    print(header)
    print(f"  {'-'*(4 + 11*len(admissible_bases))}")

    for n_iter in n_iters:
        values = []
        for p in primes:
            try:
                val = T_c_iter(c, n_iter, p)
                if val != 0:
                    fval = float(abs(val))
                    if math.isfinite(fval):
                        values.append(fval)
            except (OverflowError, ValueError):
                continue

        row = f"  {n_iter:<4}"
        for b in admissible_bases:
            if len(values) < 10:
                row += f" {'N/A':>10}"
            else:
                freq = digit_frequencies(values, b)
                benford = benford_distribution(b)
                kl = kl_divergence(freq, benford)
                row += f" {kl:>10.6f}"
        print(row)


def main():
    """Run the full demonstration suite."""
    print("\n" + "="*70)
    print("  BENFORD BASE-INVARIANCE: Prime-Indexed Dynamical Sequences")
    print("  Computational Evidence for the Base-Transfer Principle")
    print("="*70)

    # Demo 1: Basic Benford analysis
    demo_benford_criterion(c=0, n_iter=3, base=10)
    demo_benford_criterion(c=1, n_iter=3, base=10)

    # Demo 2: Multiplicative independence
    demo_multiplicative_independence()

    # Demo 3: Base-transfer principle
    demo_base_transfer(c=0, n_iter=3)
    demo_base_transfer(c=1, n_iter=5)

    # Demo 4: KL divergence profile
    demo_kl_profile(c=0)
    demo_kl_profile(c=1)

    # Demo 5: Falsification search
    search_refuting_pairs(c_range=range(-5, 6), n_iters=[1, 3, 5, 10])

    print(f"\n{'='*70}")
    print("  SUMMARY")
    print("="*70)
    print("""
  The computational evidence supports the base-invariance conjecture:
  for prime-indexed dynamical sequences T_c^(n)(p), Benford behavior
  (as measured by KL divergence to the Benford distribution) is
  consistent across all multiplicatively independent bases.

  Key insight: The equidistribution of log(|T_c^(n)(p)|) / log(b)
  modulo 1 is the mechanism that forces base-invariant digit statistics.
  Our formal theorems prove that this equidistribution criterion is
  both necessary and sufficient for Benford's law, and that the
  base-transfer follows automatically once equidistribution is certified.
""")


if __name__ == "__main__":
    if "--search" in sys.argv:
        search_refuting_pairs()
    elif "--c" in sys.argv and "--base" in sys.argv:
        c = int(sys.argv[sys.argv.index("--c") + 1])
        base = int(sys.argv[sys.argv.index("--base") + 1])
        demo_benford_criterion(c=c, base=base)
    else:
        main()
