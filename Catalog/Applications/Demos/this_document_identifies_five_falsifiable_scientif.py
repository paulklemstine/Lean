#!/usr/bin/env python3
"""
Applications of additive prime decomposition theory.

Demonstrates real-world applications of the theorems and algorithms,
including signal processing analogies, cryptographic connections,
and data analysis tools.
"""

from typing import List, Tuple, Dict
from math import isqrt, log, pi, cos, sin
import json


def is_prime(n: int) -> bool:
    """Check primality."""
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


def sieve(limit: int) -> List[bool]:
    """Sieve of Eratosthenes."""
    s = [True] * (limit + 1)
    s[0] = s[1] = False
    for i in range(2, isqrt(limit) + 1):
        if s[i]:
            for j in range(i*i, limit+1, i):
                s[j] = False
    return s


# ───────────────────────────────────────────────────────────────
# Application 1: Prime Autocorrelation Analysis
# ───────────────────────────────────────────────────────────────

def prime_autocorrelation(limit: int) -> List[int]:
    """Compute the autocorrelation of the prime indicator function.

    The autocorrelation R(n) = sum_k 1_P(k) * 1_P(k+n) measures
    how correlated the prime indicator is with a shifted copy of itself.
    By the convolution identity, R(n) is closely related to r_2(n).

    Applications:
    - Detecting hidden periodicity in prime distribution
    - Quantifying "prime clustering" at various scales
    - Analogous to radar signal processing

    Args:
        limit: Upper bound for computation.

    Returns:
        List where index n is the autocorrelation R(n).
    """
    s = sieve(2 * limit)
    ind = [1 if s[k] else 0 for k in range(2 * limit + 1)]
    result = []
    for lag in range(limit + 1):
        corr = sum(ind[k] * ind[k + lag] for k in range(limit + 1))
        result.append(corr)
    return result


def goldbach_spectrum(limit: int) -> List[float]:
    """Compute a proxy for the Fourier transform of the Goldbach count.

    The "Goldbach spectrum" S(f) = sum_n r_2(n) * cos(2*pi*f*n/limit)
    reveals frequency components in the Goldbach representation function.
    Peaks in the spectrum correspond to periodic structure in how
    Goldbach counts vary.

    Args:
        limit: Number of even integers to analyze.

    Returns:
        List of spectral amplitudes at frequency indices.
    """
    s = sieve(2 * limit)
    # Compute Goldbach counts for even numbers
    counts = []
    for n in range(4, 2 * limit + 1, 2):
        c = sum(1 for k in range(2, n-1) if s[k] and s[n-k])
        counts.append(c)

    # Compute discrete cosine transform (real part of DFT)
    N = len(counts)
    spectrum = []
    for f in range(N // 2):
        amp = sum(counts[n] * cos(2 * pi * f * n / N) for n in range(N))
        spectrum.append(abs(amp) / N)
    return spectrum


# ───────────────────────────────────────────────────────────────
# Application 2: Semiprime Decomposition for Cryptography
# ───────────────────────────────────────────────────────────────

def classify_additive_decomposition(n: int) -> Dict[str, object]:
    """Classify the additive decomposition structure of an even number.

    Returns a comprehensive analysis including:
    - Goldbach pairs (prime + prime)
    - Chen pairs (prime + semiprime)
    - Total "coverage" by additive decomposition types

    This has applications in cryptographic key analysis: understanding
    how a number relates to semiprimes (products of two primes, like RSA
    moduli) through additive structure.

    Args:
        n: Even number to analyze.

    Returns:
        Classification dictionary.
    """
    s = sieve(n + 1)

    def is_semi(m: int) -> bool:
        if m < 4:
            return False
        for p in range(2, isqrt(m) + 1):
            if s[p] and m % p == 0 and m // p < len(s) and s[m // p]:
                return True
        return False

    goldbach_pairs = []
    chen_pairs = []
    for p in range(2, n - 1):
        if not s[p]:
            continue
        q = n - p
        if q >= 2:
            if s[q]:
                goldbach_pairs.append((p, q))
            elif is_semi(q):
                chen_pairs.append((p, q))

    return {
        'n': n,
        'goldbach_count': len(goldbach_pairs),
        'chen_count': len(chen_pairs),
        'total_decompositions': len(goldbach_pairs) + len(chen_pairs),
        'goldbach_pairs': goldbach_pairs[:5],  # first 5
        'chen_pairs': chen_pairs[:5],  # first 5
        'has_goldbach': len(goldbach_pairs) > 0,
        'has_chen': len(chen_pairs) > 0,
        'goldbach_density': len(goldbach_pairs) / max(n // 2 - 1, 1),
    }


# ───────────────────────────────────────────────────────────────
# Application 3: Witness Transport Analysis
# ───────────────────────────────────────────────────────────────

def witness_transport_analysis(limit: int, max_gap: int = 10) -> Dict[str, object]:
    """Analyze whether Goldbach witnesses can be "transported" between
    consecutive even numbers with small perturbations.

    For each consecutive pair (n, n+2), check if there exist witnesses
    (p, n-p) for n and (p', n+2-p') for n+2 with |p - p'| <= max_gap.

    This models the "stability" of Goldbach decompositions under small
    perturbations, analogous to stability analysis in dynamical systems.

    Args:
        limit: Upper bound for analysis.
        max_gap: Maximum allowed perturbation.

    Returns:
        Analysis results including transport success rate.
    """
    s = sieve(limit + max_gap + 10)

    def witnesses(n):
        return [p for p in range(2, n-1) if s[p] and s[n-p]]

    transportable = 0
    total = 0
    gaps_needed = []

    for n in range(8, limit - 1, 2):
        w1 = set(witnesses(n))
        w2 = set(witnesses(n + 2))
        if not w1 or not w2:
            continue
        total += 1

        # Find minimum gap
        min_gap = float('inf')
        for p1 in w1:
            for p2 in w2:
                gap = abs(p1 - p2)
                if gap < min_gap:
                    min_gap = gap
        gaps_needed.append(min_gap)
        if min_gap <= max_gap:
            transportable += 1

    return {
        'limit': limit,
        'max_gap': max_gap,
        'total_pairs': total,
        'transportable': transportable,
        'transport_rate': transportable / total if total > 0 else 0,
        'avg_min_gap': sum(gaps_needed) / len(gaps_needed) if gaps_needed else 0,
        'max_min_gap': max(gaps_needed) if gaps_needed else 0,
    }


# ───────────────────────────────────────────────────────────────
# Application 4: Average Goldbach Count Growth
# ───────────────────────────────────────────────────────────────

def average_goldbach_growth(limit: int) -> List[Tuple[int, float]]:
    """Compute the running average of Goldbach counts.

    For each B, compute:
        avg_r2(B) = (1/|{even n in [4,B]}|) * sum_{even n <= B} r_2(n)

    The Hardy-Littlewood conjecture predicts this grows approximately
    as C * B / (log B)^2 for a specific constant C.

    Args:
        limit: Upper bound.

    Returns:
        List of (B, average_r2) pairs for even B.
    """
    s = sieve(limit + 1)
    total = 0
    count = 0
    result = []

    for n in range(4, limit + 1, 2):
        r2 = sum(1 for k in range(2, n-1) if s[k] and s[n-k])
        total += r2
        count += 1
        if n % 10 == 0:  # sample every 10
            result.append((n, total / count))

    return result


# ───────────────────────────────────────────────────────────────
# Application 5: Parity Constraint Satisfaction
# ───────────────────────────────────────────────────────────────

def parity_constraint_reduction(n: int) -> Dict[str, object]:
    """Demonstrate how parity constraints reduce the ternary search space.

    The ternary parity rigidity theorems tell us which configurations of
    2s are admissible. This function quantifies the reduction in search
    space achieved by applying these constraints.

    Args:
        n: Target number for ternary decomposition.

    Returns:
        Analysis of search space reduction.
    """
    s = sieve(n + 1)
    primes = [p for p in range(2, n) if s[p]]

    # Count all ternary decompositions
    total = 0
    # Count by parity type
    by_type: Dict[int, int] = {0: 0, 1: 0, 2: 0, 3: 0}

    for i, a in enumerate(primes):
        if a > n - 4:
            break
        for j, b in enumerate(primes):
            c = n - a - b
            if c < 2 or c > n:
                continue
            if s[c]:
                total += 1
                twos = (1 if a == 2 else 0) + (1 if b == 2 else 0) + (1 if c == 2 else 0)
                by_type[twos] += 1

    # Determine which types are admissible
    if n % 2 == 1:
        admissible = {0, 2}
    else:
        admissible = {1, 3}

    admissible_count = sum(by_type[t] for t in admissible)
    inadmissible_count = sum(by_type[t] for t in range(4) if t not in admissible)

    return {
        'n': n,
        'parity': 'odd' if n % 2 == 1 else 'even',
        'total_triples': total,
        'by_type': dict(by_type),
        'admissible_types': sorted(admissible),
        'admissible_count': admissible_count,
        'inadmissible_count': inadmissible_count,
        'note': f'All {inadmissible_count} inadmissible triples are verified to not exist'
              if inadmissible_count == 0 else 'ERROR: found inadmissible triples!'
    }


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Prime Autocorrelation")
    print("=" * 60)
    autocorr = prime_autocorrelation(200)
    print(f"  R(0) = {autocorr[0]} (number of primes up to 200 squared)")
    print(f"  R(2) = {autocorr[2]} (twin prime proxy)")
    print(f"  R(4) = {autocorr[4]}")
    print(f"  R(6) = {autocorr[6]}")
    print()

    print("=" * 60)
    print("APPLICATION 2: Additive Decomposition Classification")
    print("=" * 60)
    for n in [20, 50, 100, 200]:
        result = classify_additive_decomposition(n)
        print(f"  n = {n}: {result['goldbach_count']} Goldbach, "
              f"{result['chen_count']} Chen, density = {result['goldbach_density']:.3f}")
    print()

    print("=" * 60)
    print("APPLICATION 3: Witness Transport")
    print("=" * 60)
    for gap in [2, 4, 6, 10]:
        result = witness_transport_analysis(500, max_gap=gap)
        print(f"  Gap ≤ {gap:>2}: transport rate = {result['transport_rate']:.3f} "
              f"({result['transportable']}/{result['total_pairs']})")
    print()

    print("=" * 60)
    print("APPLICATION 4: Average Goldbach Growth")
    print("=" * 60)
    growth = average_goldbach_growth(1000)
    for B, avg in growth[::10]:  # every 10th point
        print(f"  B = {B:>5}: avg r_2 = {avg:.2f}")
    print()

    print("=" * 60)
    print("APPLICATION 5: Parity Constraint Reduction")
    print("=" * 60)
    for n in [15, 20, 51, 100]:
        result = parity_constraint_reduction(n)
        print(f"  n = {n} ({result['parity']}): "
              f"total = {result['total_triples']}, "
              f"by #twos = {result['by_type']}, "
              f"admissible = {result['admissible_types']}")
    print()

    print("All applications completed.")


#!/usr/bin/env python3
"""
Demonstrations of additive prime decomposition theory.

This script provides concrete numerical examples of the theorems proved
in the formal development, including:
- Goldbach witness enumeration
- Ternary parity rigidity verification
- Goldbach count as self-convolution
- Semiprime classification
- Weak Chen decomposition search
"""

from typing import List, Tuple
from math import isqrt


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


def is_semiprime(n: int) -> bool:
    """Check if n is a product of exactly two primes."""
    if n < 4:
        return False
    for p in range(2, isqrt(n) + 1):
        if is_prime(p) and n % p == 0 and is_prime(n // p):
            return True
    return False


def goldbach_witnesses(n: int) -> List[Tuple[int, int]]:
    """Return all ordered pairs (p, q) of primes with p + q = n."""
    return [(p, n - p) for p in range(2, n - 1) if is_prime(p) and is_prime(n - p)]


def goldbach_count(n: int) -> int:
    """Count ordered Goldbach representations (via direct enumeration)."""
    return len(goldbach_witnesses(n))


def goldbach_count_convolution(n: int) -> int:
    """Compute Goldbach count via self-convolution of prime indicator.

    This implements the proved identity:
        r_2(n) = sum_{k=0}^{n} 1_P(k) * 1_P(n-k)
    """
    indicator = [1 if is_prime(k) else 0 for k in range(n + 1)]
    return sum(indicator[k] * indicator[n - k] for k in range(n + 1))


def ternary_decompositions(n: int) -> List[Tuple[int, int, int]]:
    """Return all ordered triples (a, b, c) of primes with a + b + c = n."""
    result = []
    for a in range(2, n - 3):
        if not is_prime(a):
            continue
        for b in range(2, n - a - 1):
            c = n - a - b
            if c >= 2 and is_prime(b) and is_prime(c):
                result.append((a, b, c))
    return result


def count_twos(triple: Tuple[int, int, int]) -> int:
    """Count how many elements of the triple equal 2."""
    return sum(1 for x in triple if x == 2)


def weak_chen_witnesses(n: int) -> List[Tuple[int, int, str]]:
    """Return weak Chen decompositions: (p, s, type) where type is 'prime' or 'semiprime'."""
    result = []
    for p in range(2, n - 1):
        if not is_prime(p):
            continue
        s = n - p
        if is_prime(s):
            result.append((p, s, "prime"))
        elif is_semiprime(s):
            result.append((p, s, "semiprime"))
    return result


def demo_goldbach_witnesses():
    """Demonstrate Goldbach witness enumeration."""
    print("=" * 60)
    print("DEMO 1: Goldbach Witness Enumeration")
    print("=" * 60)
    print()
    for n in [4, 6, 8, 10, 20, 50, 100]:
        witnesses = goldbach_witnesses(n)
        print(f"  n = {n:>3}: r_2(n) = {len(witnesses):>2}, witnesses = {witnesses}")
    print()
    print("  Note: 4 and 6 have exactly 1 ordered representation.")
    print("  All even n >= 8 shown have >= 2 representations.")
    print()


def demo_convolution_identity():
    """Verify the convolution identity r_2(n) = (1_P * 1_P)(n)."""
    print("=" * 60)
    print("DEMO 2: Convolution Identity Verification")
    print("=" * 60)
    print()
    print("  Theorem: r_2(n) = sum_{k=0}^{n} 1_P(k) * 1_P(n-k)")
    print()
    print(f"  {'n':>4} | {'Direct':>8} | {'Convolution':>12} | {'Match':>5}")
    print(f"  {'-'*4}-+-{'-'*8}-+-{'-'*12}-+-{'-'*5}")
    all_match = True
    for n in range(2, 51):
        if n % 2 != 0:
            continue
        direct = goldbach_count(n)
        conv = goldbach_count_convolution(n)
        match = "✓" if direct == conv else "✗"
        if direct != conv:
            all_match = False
        print(f"  {n:>4} | {direct:>8} | {conv:>12} | {match:>5}")
    print()
    print(f"  All values match: {'YES' if all_match else 'NO'}")
    print()


def demo_ternary_parity():
    """Demonstrate ternary parity rigidity."""
    print("=" * 60)
    print("DEMO 3: Ternary Parity Rigidity")
    print("=" * 60)
    print()
    print("  Theorem: For odd n, #twos in (a,b,c) must be 0 or 2.")
    print("  Theorem: For even n, #twos in (a,b,c) must be 1 or 3.")
    print()

    # Test odd numbers
    print("  ODD targets:")
    for n in [7, 9, 11, 15, 21, 25]:
        triples = ternary_decompositions(n)
        two_counts = set(count_twos(t) for t in triples)
        print(f"    n = {n:>3}: #triples = {len(triples):>3}, "
              f"observed #twos values = {sorted(two_counts)}")
        # Verify no triple has exactly 1 or 3 twos
        for t in triples:
            ct = count_twos(t)
            assert ct in (0, 2), f"Violation! n={n}, triple={t}, #twos={ct}"
    print()

    # Test even numbers
    print("  EVEN targets:")
    for n in [6, 8, 10, 12, 20, 30]:
        triples = ternary_decompositions(n)
        two_counts = set(count_twos(t) for t in triples)
        print(f"    n = {n:>3}: #triples = {len(triples):>3}, "
              f"observed #twos values = {sorted(two_counts)}")
        for t in triples:
            ct = count_twos(t)
            assert ct in (1, 3), f"Violation! n={n}, triple={t}, #twos={ct}"
    print()
    print("  All parity constraints verified!")
    print()


def demo_multiplicity_lower_bound():
    """Verify r_2(n) >= 2 for even n in [8, 200]."""
    print("=" * 60)
    print("DEMO 4: Goldbach Multiplicity Lower Bound")
    print("=" * 60)
    print()
    print("  Conjecture: r_2(n) >= 2 for all even n >= 8")
    print()
    min_count = float('inf')
    min_n = None
    violations = []
    for n in range(8, 201, 2):
        c = goldbach_count(n)
        if c < 2:
            violations.append(n)
        if c < min_count:
            min_count = c
            min_n = n
    print(f"  Checked even n in [8, 200]")
    print(f"  Minimum r_2(n) = {min_count} at n = {min_n}")
    print(f"  Violations (r_2 < 2): {violations if violations else 'NONE'}")
    print()

    # Show growth of average
    print("  Average Goldbach count by range:")
    for B in [20, 50, 100, 200]:
        counts = [goldbach_count(n) for n in range(8, B + 1, 2)]
        avg = sum(counts) / len(counts)
        print(f"    [8, {B:>3}]: avg r_2 = {avg:.2f}")
    print()


def demo_weak_chen():
    """Demonstrate weak Chen decompositions."""
    print("=" * 60)
    print("DEMO 5: Weak Chen Decompositions")
    print("=" * 60)
    print()
    print("  Theorem: Every even n in [4, 100] has a weak Chen decomposition")
    print("  (n = p + s, where p is prime, s is prime or semiprime)")
    print()
    for n in [4, 6, 8, 10, 20, 36, 50, 98]:
        witnesses = weak_chen_witnesses(n)
        prime_witnesses = [(p, s) for p, s, t in witnesses if t == "prime"]
        semi_witnesses = [(p, s) for p, s, t in witnesses if t == "semiprime"]
        print(f"  n = {n:>3}: {len(prime_witnesses)} prime-pairs, "
              f"{len(semi_witnesses)} semiprime-pairs")
        if semi_witnesses:
            p, s = semi_witnesses[0]
            # Find factorization
            for a in range(2, isqrt(s) + 1):
                if is_prime(a) and s % a == 0 and is_prime(s // a):
                    print(f"          Example: {n} = {p} + {s} "
                          f"(where {s} = {a} × {s//a})")
                    break
    print()

    # Verify all even n in [4, 100]
    all_have = True
    for n in range(4, 101, 2):
        if not weak_chen_witnesses(n):
            all_have = False
            print(f"  VIOLATION: n = {n} has no weak Chen decomposition!")
    print(f"  All even n in [4, 100] verified: {'YES' if all_have else 'NO'}")
    print()


def demo_semiprime_classification():
    """Classify semiprimes up to 50."""
    print("=" * 60)
    print("DEMO 6: Semiprime Classification")
    print("=" * 60)
    print()
    semiprimes = [n for n in range(1, 51) if is_semiprime(n)]
    print(f"  Semiprimes up to 50: {semiprimes}")
    print()
    print("  Factorizations:")
    for n in semiprimes[:10]:
        for a in range(2, isqrt(n) + 1):
            if is_prime(a) and n % a == 0 and is_prime(n // a):
                print(f"    {n:>3} = {a} × {n//a}")
                break
    print()


if __name__ == "__main__":
    print()
    print("ADDITIVE PRIME DECOMPOSITION THEORY — DEMONSTRATIONS")
    print("=" * 60)
    print()

    demo_goldbach_witnesses()
    demo_convolution_identity()
    demo_ternary_parity()
    demo_multiplicity_lower_bound()
    demo_weak_chen()
    demo_semiprime_classification()

    print("All demonstrations completed successfully.")
