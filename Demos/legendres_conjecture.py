#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Legendre conjecture framework.

Demonstrates practical uses of prime-gap analysis near square intervals:
  1. Cryptographic key generation with square-proximity guarantees
  2. Hash table sizing with prime dimensions near squares
  3. Prime certificate search with bounded radius
  4. Statistical testing of prime distribution models
"""

import math
import random
import time
from typing import List, Tuple, Optional


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test (deterministic for n < 3.3×10²⁴)."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    # Write n-1 = 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    # Deterministic witnesses for n < 3.3e24
    witnesses = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for a in witnesses:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime_after_square(n: int) -> Tuple[int, int]:
    """Find the smallest prime strictly greater than n².
    
    Returns (prime, gap) where gap = prime - n².
    
    Application: Cryptographic protocols that need primes near specific
    algebraic structures benefit from knowing how far to search.
    """
    target = n * n
    k = target + 1
    while not is_prime(k):
        k += 1
    return k, k - target


def prime_near_square_for_hash_table(target_size: int) -> Tuple[int, int]:
    """Find a prime hash table size near a perfect square.
    
    Hash tables with prime dimensions have better collision properties.
    Finding a prime near n² guarantees good modular arithmetic properties.
    
    Args:
        target_size: Desired approximate table size.
    
    Returns:
        (prime_size, n) where prime_size is in (n², (n+1)²).
    """
    n = int(math.isqrt(target_size))
    # Search in the Legendre interval
    for k in range(n * n + 1, (n + 1) * (n + 1)):
        if is_prime(k):
            return k, n
    # Fallback: search upward
    k = (n + 1) * (n + 1) + 1
    while not is_prime(k):
        k += 1
    return k, n + 1


def bounded_prime_search(n: int, max_gap: Optional[int] = None) -> Tuple[Optional[int], int]:
    """Search for a prime in (n², (n+1)²) with bounded search radius.
    
    This implements the "certified witness search" concept: given n,
    find a prime certificate in the Legendre interval. The search
    radius is bounded by 2n+1 (the interval length).
    
    Args:
        n: The base integer.
        max_gap: Maximum search distance (default: 2n+1).
    
    Returns:
        (prime_or_None, steps_taken)
    """
    if max_gap is None:
        max_gap = 2 * n + 1
    
    lo = n * n + 1
    hi = min(n * n + max_gap, (n + 1) * (n + 1))
    
    steps = 0
    for k in range(lo, hi):
        steps += 1
        if is_prime(k):
            return k, steps
    
    return None, steps


def randomized_prime_search(n: int, max_trials: int = 100) -> Tuple[Optional[int], int]:
    """Randomized search for a prime in (n², (n+1)²).
    
    Under the Cramér model, each candidate has probability ~1/log(n²) = 1/(2 log n)
    of being prime. So on average, we need ~2 log n trials.
    
    Args:
        n: The base integer.
        max_trials: Maximum number of random samples.
    
    Returns:
        (prime_or_None, trials_used)
    """
    lo = n * n + 1
    hi = (n + 1) * (n + 1) - 1
    
    for trial in range(1, max_trials + 1):
        k = random.randint(lo, hi)
        if is_prime(k):
            return k, trial
    
    return None, max_trials


def prime_density_heatmap(max_n: int) -> List[Tuple[int, float]]:
    """Compute the prime density (fraction of primes) in each square interval.
    
    Application: Visualizing the distribution of primes reveals structure
    that pure randomness would not predict.
    
    Args:
        max_n: Compute for n = 1, ..., max_n.
    
    Returns:
        List of (n, density) pairs.
    """
    results = []
    for n in range(1, max_n + 1):
        interval_size = 2 * n  # = (n+1)² - n² - 1 (number of candidates)
        if interval_size == 0:
            results.append((n, 0.0))
            continue
        prime_count = sum(1 for k in range(n*n + 1, (n+1)*(n+1)) if is_prime(k))
        density = prime_count / interval_size
        results.append((n, density))
    return results


def cramer_model_simulation(n: int, num_simulations: int = 10000) -> dict:
    """Monte Carlo simulation of the Cramér random model for interval (n², (n+1)²).
    
    Each integer k in the interval independently "is prime" with probability 1/log(k).
    We simulate many realizations and compare with the actual prime count.
    
    Args:
        n: The base integer.
        num_simulations: Number of Monte Carlo trials.
    
    Returns:
        Dictionary with simulation statistics.
    """
    lo = n * n + 1
    hi = (n + 1) * (n + 1)
    
    # Actual prime count
    actual = sum(1 for k in range(lo, hi) if is_prime(k))
    
    # Expected count
    probs = [1.0 / math.log(k) if k >= 2 else 0.0 for k in range(lo, hi)]
    expected = sum(probs)
    
    # Simulate
    counts = []
    zero_count = 0
    for _ in range(num_simulations):
        c = sum(1 for p in probs if random.random() < p)
        counts.append(c)
        if c == 0:
            zero_count += 1
    
    avg = sum(counts) / len(counts)
    variance = sum((c - avg)**2 for c in counts) / len(counts)
    
    return {
        "n": n,
        "actual_primes": actual,
        "expected": expected,
        "simulated_mean": avg,
        "simulated_variance": variance,
        "prob_zero_primes": zero_count / num_simulations,
        "interval_length": hi - lo,
    }


def demo_crypto_application():
    """Demonstrate prime search near squares for cryptography."""
    print("=" * 60)
    print("APPLICATION 1: Prime Generation Near Squares")
    print("=" * 60)
    print("\nFinding primes just above n² (useful for RSA-like schemes):\n")
    
    for bits in [8, 16, 32, 64]:
        n = 2 ** (bits // 2)
        prime, gap = next_prime_after_square(n)
        print(f"  n = 2^{bits//2} = {n}")
        print(f"  n² = {n*n}")
        print(f"  Next prime: {prime} (gap = {gap})")
        print(f"  Legendre bound: gap < 2n+1 = {2*n+1}")
        print()


def demo_hash_table():
    """Demonstrate hash table sizing using Legendre intervals."""
    print("=" * 60)
    print("APPLICATION 2: Hash Table Sizing")
    print("=" * 60)
    print("\nFinding prime table sizes near target capacities:\n")
    
    for target in [100, 1000, 10000, 100000, 1000000]:
        prime_size, n = prime_near_square_for_hash_table(target)
        print(f"  Target: {target:>10}, Prime size: {prime_size:>10} (n={n}, n²={n*n})")


def demo_search_complexity():
    """Benchmark search time for primes in Legendre intervals."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Search Complexity Analysis")
    print("=" * 60)
    print("\nAverage search steps for prime in (n², (n+1)²):\n")
    
    print(f"{'n':>10} {'det_steps':>12} {'rand_steps':>12} {'2*log(n)':>10}")
    print("-" * 50)
    
    for n in [10, 100, 1000, 10000]:
        # Deterministic search
        _, det_steps = bounded_prime_search(n)
        
        # Average randomized search (10 trials)
        rand_steps_total = 0
        for _ in range(10):
            _, rs = randomized_prime_search(n, max_trials=1000)
            rand_steps_total += rs
        avg_rand = rand_steps_total / 10
        
        expected_steps = 2 * math.log(n) if n > 1 else 1
        print(f"{n:>10} {det_steps:>12} {avg_rand:>12.1f} {expected_steps:>10.1f}")


def demo_cramer_simulation():
    """Run Cramér model simulations."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Cramér Model Monte Carlo Simulation")
    print("=" * 60)
    
    for n in [10, 50, 100, 500]:
        result = cramer_model_simulation(n, num_simulations=10000)
        print(f"\n  n = {result['n']}, interval ({n*n}, {(n+1)**2})")
        print(f"    Actual primes:     {result['actual_primes']}")
        print(f"    Expected (Cramér): {result['expected']:.2f}")
        print(f"    Simulated mean:    {result['simulated_mean']:.2f}")
        print(f"    Simulated var:     {result['simulated_variance']:.2f}")
        print(f"    P(zero primes):    {result['prob_zero_primes']:.6f}")


if __name__ == "__main__":
    demo_crypto_application()
    demo_hash_table()
    demo_search_complexity()
    demo_cramer_simulation()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Demonstrating the formal framework around Legendre's Conjecture.

This script illustrates:
  1. Square interval prime counts for small n
  2. The gap-to-Legendre reduction in action
  3. Cramér-model expected prime counts vs. actual counts
  4. Verification of Legendre's conjecture for small n
"""

import math
from typing import List, Tuple


def is_prime(n: int) -> bool:
    """Check if n is a prime number."""
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


def square_interval(n: int) -> List[int]:
    """Return the list of integers strictly between n² and (n+1)²."""
    return list(range(n**2 + 1, (n + 1)**2))


def square_prime_count(n: int) -> int:
    """Count primes in the open interval (n², (n+1)²)."""
    return sum(1 for k in square_interval(n) if is_prime(k))


def cramer_expectation(n: int) -> float:
    """Cramér-model expected number of primes in (n², (n+1)²).
    
    E_n = Σ_{k=n²+1}^{(n+1)²-1} 1/log(k)
    """
    return sum(1.0 / math.log(k) for k in square_interval(n) if k > 1)


def cramer_lower_bound(n: int) -> float:
    """Lower bound (2n-1)/log((n+1)²) on the Cramér expectation."""
    if n < 2:
        return 0.0
    return (2 * n - 1) / math.log((n + 1)**2)


def verify_legendre(max_n: int) -> Tuple[bool, int]:
    """Verify Legendre's conjecture for all n up to max_n.
    
    Returns (all_verified, first_failure) where first_failure is -1 if all pass.
    """
    for n in range(1, max_n + 1):
        if square_prime_count(n) == 0:
            return False, n
    return True, -1


def demo_square_intervals():
    """Show primes between consecutive squares for small n."""
    print("=" * 70)
    print("DEMO 1: Primes Between Consecutive Squares")
    print("=" * 70)
    print(f"{'n':>4} {'n²':>8} {'(n+1)²':>8} {'gap':>5} {'#primes':>8} {'primes'}")
    print("-" * 70)
    for n in range(1, 21):
        primes = [k for k in square_interval(n) if is_prime(k)]
        gap = (n + 1)**2 - n**2
        primes_str = str(primes) if len(primes) <= 6 else str(primes[:5]) + "..."
        print(f"{n:>4} {n**2:>8} {(n+1)**2:>8} {gap:>5} {len(primes):>8} {primes_str}")


def demo_gap_reduction():
    """Demonstrate the gap-to-Legendre reduction theorem."""
    print("\n" + "=" * 70)
    print("DEMO 2: Gap-to-Legendre Reduction")
    print("=" * 70)
    print("\nThe reduction theorem states:")
    print("  If every m ≥ N has a prime in (m, m + 2√m + 1],")
    print("  then Legendre holds for all n with n² ≥ N.")
    print("\nKey identity: (n+1)² - n² = 2n + 1 = 2√(n²) + 1")
    print()
    
    # Check the gap hypothesis for small m
    print(f"{'m':>6} {'2√m+1':>8} {'gap prime?':>12} {'witness p'}")
    print("-" * 45)
    for m in range(1, 31):
        L = int(2 * math.isqrt(m) + 1)
        # Find smallest prime in (m, m + L]
        witness = None
        for p in range(m + 1, m + L + 1):
            if is_prime(p):
                witness = p
                break
        status = "YES" if witness else "NO"
        print(f"{m:>6} {L:>8} {status:>12} {witness if witness else '-'}")


def demo_cramer_model():
    """Compare actual prime counts with Cramér model predictions."""
    print("\n" + "=" * 70)
    print("DEMO 3: Cramér Model vs. Actual Prime Counts")
    print("=" * 70)
    print(f"{'n':>6} {'actual':>8} {'E_n':>10} {'lower':>10} {'ratio':>8}")
    print("-" * 52)
    
    for n in [2, 5, 10, 20, 50, 100, 200, 500, 1000]:
        actual = square_prime_count(n)
        expected = cramer_expectation(n)
        lower = cramer_lower_bound(n)
        ratio = actual / expected if expected > 0 else float('inf')
        print(f"{n:>6} {actual:>8} {expected:>10.2f} {lower:>10.2f} {ratio:>8.3f}")


def demo_divergence():
    """Show that the Cramér expectation diverges to infinity."""
    print("\n" + "=" * 70)
    print("DEMO 4: Divergence of Cramér Expected Count")
    print("=" * 70)
    print("The theorem proves E_n → ∞ as n → ∞")
    print()
    print(f"{'n':>8} {'E_n':>12} {'(2n-1)/log((n+1)²)':>22}")
    print("-" * 50)
    for n in [10, 100, 1000, 10000, 100000]:
        expected = cramer_expectation(n)
        lower = cramer_lower_bound(n)
        print(f"{n:>8} {expected:>12.2f} {lower:>22.2f}")


def demo_verification():
    """Verify Legendre's conjecture computationally for small n."""
    print("\n" + "=" * 70)
    print("DEMO 5: Computational Verification of Legendre's Conjecture")
    print("=" * 70)
    
    max_n = 1000
    verified, failure = verify_legendre(max_n)
    if verified:
        print(f"✓ Legendre's conjecture verified for all n = 1, ..., {max_n}")
    else:
        print(f"✗ First failure at n = {failure}")
    
    # Show minimum prime count
    min_count = float('inf')
    min_n = -1
    for n in range(1, max_n + 1):
        c = square_prime_count(n)
        if c < min_count:
            min_count = c
            min_n = n
    print(f"  Minimum prime count in any interval: {min_count} (at n = {min_n})")
    
    # Bertrand comparison
    print(f"\nBertrand's postulate gives: prime in (n², 2n²)")
    print(f"Legendre requires:         prime in (n², (n+1)²)")
    print(f"Ratio of interval lengths: (n+1)²-n² / n² = (2n+1)/n² → 0")
    print(f"So Legendre is much stronger than Bertrand near squares.")


if __name__ == "__main__":
    demo_square_intervals()
    demo_gap_reduction()
    demo_cramer_model()
    demo_divergence()
    demo_verification()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
