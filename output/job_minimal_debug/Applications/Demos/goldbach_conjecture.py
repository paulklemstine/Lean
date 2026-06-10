#!/usr/bin/env python3
"""
Applications of additive prime decomposition theory.

Shows practical uses of Goldbach-type decompositions including:
- Cryptographic key splitting
- Error detection in prime-based encodings
- Visualization of the Goldbach comet
- Hardy-Littlewood prediction comparison
"""

import math
from typing import List, Tuple, Dict


# ── Sieve infrastructure ──────────────────────────────────────────

def sieve(limit: int) -> List[bool]:
    """Sieve of Eratosthenes returning boolean array."""
    is_p = [False] * (limit + 1)
    if limit >= 2:
        is_p[2] = True
    for i in range(3, limit + 1, 2):
        is_p[i] = True
    p = 3
    while p * p <= limit:
        if is_p[p]:
            for j in range(p * p, limit + 1, 2 * p):
                is_p[j] = False
        p += 2
    return is_p


# ── Application 1: Goldbach Comet Data ─────────────────────────

def goldbach_comet_data(limit: int) -> List[Tuple[int, int]]:
    """
    Compute the Goldbach comet: pairs (n, r₂(n)/2) for even n in [4, limit],
    where r₂(n)/2 counts unordered pairs.

    The Goldbach comet is a famous visualization showing the number of ways
    each even number can be written as a sum of two primes. The resulting
    scatter plot reveals striking structure: stratification by the number
    of small prime factors of n.

    Returns:
        List of (n, count) pairs for plotting.
    """
    is_p = sieve(limit)
    primes = [p for p in range(2, limit + 1) if is_p[p]]
    data = []

    for n in range(4, limit + 1, 2):
        count = 0
        for p in primes:
            if p > n // 2:
                break
            q = n - p
            if is_p[q]:
                count += 1
        data.append((n, count))

    return data


# ── Application 2: Hardy-Littlewood Prediction ─────────────────

def twin_prime_constant() -> float:
    """
    Approximate the twin prime constant C₂ = Π_{p≥3} (1 - 1/(p-1)²).
    Uses first 1000 odd primes for approximation.
    """
    is_p = sieve(8000)
    primes = [p for p in range(3, 8000) if is_p[p]]
    C2 = 1.0
    for p in primes[:1000]:
        C2 *= 1.0 - 1.0 / ((p - 1) ** 2)
    return C2


def hardy_littlewood_prediction(n: int) -> float:
    """
    Hardy-Littlewood prediction for the number of unordered Goldbach
    representations of n:

        G(n) ~ 2 C₂ · (n / (ln n)²) · Π_{p|n, p>2} (p-1)/(p-2)

    This is the singular series prediction from the circle method.
    """
    if n < 4 or n % 2 != 0:
        return 0.0

    C2 = twin_prime_constant()
    ln_n = math.log(n)

    # Product over odd prime divisors of n
    product = 1.0
    is_p = sieve(n)
    for p in range(3, n + 1):
        if is_p[p] and n % p == 0:
            product *= (p - 1) / (p - 2)

    return 2 * C2 * n / (ln_n ** 2) * product


def compare_hl_prediction(limit: int) -> List[Dict]:
    """
    Compare actual Goldbach counts with Hardy-Littlewood predictions.

    Returns list of dicts with n, actual count, predicted count, and ratio.
    """
    comet = goldbach_comet_data(limit)
    results = []

    for n, actual in comet:
        if n >= 10:  # skip very small values
            predicted = hardy_littlewood_prediction(n)
            ratio = actual / predicted if predicted > 0 else float('inf')
            results.append({
                "n": n,
                "actual": actual,
                "predicted": round(predicted, 2),
                "ratio": round(ratio, 3)
            })

    return results


# ── Application 3: Prime Pair Splitting ─────────────────────────

def prime_pair_split(n: int) -> List[Tuple[int, int]]:
    """
    Split an even number into two prime components.

    Application: In some cryptographic protocols, a shared secret (even number)
    can be split into two prime shares. The Goldbach conjecture guarantees this
    is possible for all even n > 2. The number of possible splits provides
    a measure of the "splitting entropy" of the number.

    Returns:
        List of (p, q) with p ≤ q, both prime, p + q = n
    """
    is_p = sieve(n)
    pairs = []
    for p in range(2, n // 2 + 1):
        q = n - p
        if is_p[p] and is_p[q]:
            pairs.append((p, q))
    return pairs


def splitting_entropy(n: int) -> float:
    """
    Compute the "splitting entropy" of an even number n:
    log₂ of the number of unordered Goldbach decompositions.

    Higher entropy means more ways to split n into prime pairs,
    which increases security in prime-pair-based protocols.
    """
    pairs = prime_pair_split(n)
    if not pairs:
        return 0.0
    return math.log2(len(pairs))


# ── Application 4: Goldbach Residual Analysis ──────────────────

def goldbach_residuals(limit: int) -> Dict[str, List]:
    """
    Analyze residuals between actual Goldbach counts and H-L predictions.

    This is useful for detecting systematic biases or discovering
    refined correction terms for the asymptotic formula.
    """
    comet = goldbach_comet_data(limit)
    ns = []
    residuals = []
    relative_errors = []

    for n, actual in comet:
        if n >= 20:
            predicted = hardy_littlewood_prediction(n)
            if predicted > 0:
                res = actual - predicted
                rel_err = res / predicted
                ns.append(n)
                residuals.append(round(res, 2))
                relative_errors.append(round(rel_err, 4))

    avg_rel_err = sum(relative_errors) / len(relative_errors) if relative_errors else 0
    max_rel_err = max(abs(e) for e in relative_errors) if relative_errors else 0

    return {
        "sample_n": ns[:20],
        "sample_residuals": residuals[:20],
        "avg_relative_error": round(avg_rel_err, 4),
        "max_relative_error": round(max_rel_err, 4),
        "num_points": len(ns)
    }


# ── Main ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Goldbach Comet (first 20 values)")
    print("=" * 60)
    comet = goldbach_comet_data(50)
    for n, count in comet:
        bar = "█" * count
        print(f"  {n:4d}: {count:3d} {bar}")

    print()
    print("=" * 60)
    print("APPLICATION 2: Hardy-Littlewood Prediction Comparison")
    print("=" * 60)
    results = compare_hl_prediction(200)
    print(f"  {'n':>5s}  {'actual':>7s}  {'predicted':>9s}  {'ratio':>6s}")
    for r in results[::5]:  # every 5th
        print(f"  {r['n']:5d}  {r['actual']:7d}  {r['predicted']:9.2f}  {r['ratio']:6.3f}")

    print()
    print("=" * 60)
    print("APPLICATION 3: Splitting Entropy")
    print("=" * 60)
    for n in [100, 200, 500, 1000, 2000, 5000, 10000]:
        ent = splitting_entropy(n)
        pairs = len(prime_pair_split(n))
        print(f"  n = {n:6d}: {pairs:5d} splits, entropy = {ent:.2f} bits")

    print()
    print("=" * 60)
    print("APPLICATION 4: Residual Analysis (up to 1000)")
    print("=" * 60)
    res = goldbach_residuals(1000)
    print(f"  Points analyzed: {res['num_points']}")
    print(f"  Average relative error: {res['avg_relative_error']}")
    print(f"  Max relative error: {res['max_relative_error']}")
    print(f"  Sample residuals: {res['sample_residuals'][:10]}")


#!/usr/bin/env python3
"""
Demo: Goldbach-type additive prime decompositions.

Demonstrates the key concepts from the formal additive prime infrastructure:
- Goldbach pair enumeration
- Witness counting (representation function r₂)
- Parity forcing
- Binary-to-ternary transfer
- Weak Chen decompositions
"""

import math
from typing import List, Tuple


def sieve(limit: int) -> List[bool]:
    """Sieve of Eratosthenes."""
    is_p = [False] * (limit + 1)
    if limit >= 2:
        is_p[2] = True
    for i in range(3, limit + 1, 2):
        is_p[i] = True
    p = 3
    while p * p <= limit:
        if is_p[p]:
            for j in range(p * p, limit + 1, 2 * p):
                is_p[j] = False
        p += 2
    return is_p


def isprime(n: int) -> bool:
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(math.isqrt(n)) + 1, 2):
        if n % i == 0:
            return False
    return True


def goldbach_pairs(n: int) -> List[Tuple[int, int]]:
    """Return all ordered pairs (p, q) of primes with p + q = n."""
    pairs = []
    for p in range(2, n):
        q = n - p
        if q >= 2 and isprime(p) and isprime(q):
            pairs.append((p, q))
    return pairs


def goldbach_count(n: int) -> int:
    """Goldbach representation count r₂(n): number of ordered prime pairs summing to n."""
    return len(goldbach_pairs(n))


def is_semiprime(n: int) -> bool:
    """Check if n is a product of exactly two primes."""
    if n < 4:
        return False
    for p in range(2, int(math.isqrt(n)) + 1):
        if isprime(p) and n % p == 0:
            q = n // p
            if isprime(q):
                return True
    return False


def weak_chen_decomposition(n: int) -> List[Tuple[int, int]]:
    """Find all (p, s) where p is prime, s is prime or semiprime, and p + s = n."""
    pairs = []
    for p in range(2, n):
        if not isprime(p):
            continue
        s = n - p
        if s >= 2 and (isprime(s) or is_semiprime(s)):
            pairs.append((p, s))
    return pairs


def demo_goldbach_pairs():
    """Demonstrate Goldbach pair enumeration."""
    print("=" * 60)
    print("DEMO 1: Goldbach Pairs for Even Numbers")
    print("=" * 60)
    for n in range(4, 32, 2):
        pairs = goldbach_pairs(n)
        unordered = [(p, q) for p, q in pairs if p <= q]
        print(f"  {n:3d} = " + " = ".join(f"{p}+{q}" for p, q in unordered))
    print()


def demo_goldbach_counts():
    """Demonstrate the Goldbach representation count r₂(n)."""
    print("=" * 60)
    print("DEMO 2: Goldbach Representation Counts r₂(n)")
    print("=" * 60)
    print(f"  {'n':>5s}  {'r₂(n)':>6s}  {'unordered':>10s}")
    print(f"  {'---':>5s}  {'------':>6s}  {'----------':>10s}")
    for n in range(4, 52, 2):
        count = goldbach_count(n)
        unordered = len([1 for p, q in goldbach_pairs(n) if p <= q])
        print(f"  {n:5d}  {count:6d}  {unordered:10d}")
    print()


def demo_parity_forcing():
    """Demonstrate that even n > 4 forces both primes to be odd."""
    print("=" * 60)
    print("DEMO 3: Parity Forcing (Theorem: both primes odd for n > 4)")
    print("=" * 60)
    exceptions = []
    for n in range(6, 200, 2):
        for p, q in goldbach_pairs(n):
            if p == 2 or q == 2:
                exceptions.append((n, p, q))
    if exceptions:
        print(f"  Found {len(exceptions)} exceptions (unexpected!):")
        for n, p, q in exceptions:
            print(f"    n={n}: ({p}, {q})")
    else:
        print("  ✓ Verified: For all even n in [6, 198], all Goldbach witnesses")
        print("    have both primes odd. Consistent with the proved theorem.")
    print()


def demo_binary_to_ternary():
    """Demonstrate the binary → ternary Goldbach transfer."""
    print("=" * 60)
    print("DEMO 4: Binary Goldbach → Ternary Goldbach Transfer")
    print("=" * 60)
    print("  For odd n > 5, write n = 3 + (n-3), then apply binary Goldbach to n-3.")
    print()
    for n in range(7, 30, 2):
        m = n - 3
        pairs = goldbach_pairs(m)
        if pairs:
            p, q = pairs[0]
            print(f"  {n} = 3 + {m} = 3 + {p} + {q}  ✓")
        else:
            print(f"  {n}: FAILED (n-3 = {m} has no Goldbach decomposition)")
    print()


def demo_weak_chen():
    """Demonstrate weak Chen decompositions."""
    print("=" * 60)
    print("DEMO 5: Weak Chen Decompositions (prime + prime-or-semiprime)")
    print("=" * 60)
    for n in range(4, 30, 2):
        decomps = weak_chen_decomposition(n)
        sample = decomps[0] if decomps else None
        if sample:
            p, s = sample
            kind = "prime" if isprime(s) else "semiprime"
            print(f"  {n} = {p} + {s} ({kind}), total decompositions: {len(decomps)}")
    print()


def demo_verified_range():
    """Verify Goldbach for a range and report statistics."""
    print("=" * 60)
    print("DEMO 6: Verified Goldbach Range [4, 1000]")
    print("=" * 60)
    B = 1000
    verified = 0
    min_count = float('inf')
    min_n = 0
    total_count = 0
    for n in range(4, B + 1, 2):
        c = goldbach_count(n)
        total_count += c
        if c > 0:
            verified += 1
        if c < min_count:
            min_count = c
            min_n = n
    total_even = (B - 4) // 2 + 1
    print(f"  Even numbers in [4, {B}]: {total_even}")
    print(f"  Verified Goldbach: {verified}")
    print(f"  Minimum r₂(n): {min_count} at n = {min_n}")
    avg = total_count / total_even
    print(f"  Average r₂(n): {avg:.2f}")
    print()


if __name__ == "__main__":
    demo_goldbach_pairs()
    demo_goldbach_counts()
    demo_parity_forcing()
    demo_binary_to_ternary()
    demo_weak_chen()
    demo_verified_range()
