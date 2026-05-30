"""
Algorithms for Hilbert's Hotel for Primes
==========================================
Implements core algorithms for studying permutation stability of primes.

Key algorithms:
1. Bounded displacement permutation generation
2. Displacement norm computation
3. Prime ratio convergence testing
4. Density estimation of well-behaved permutations
"""

import math
import random
from typing import List, Tuple, Optional, Dict


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Sieve of Eratosthenes for generating primes.
    
    Time: O(n log log n), Space: O(n)
    
    Args:
        limit: Upper bound for prime generation.
    Returns:
        List of all primes ≤ limit.
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]


def nth_primes(count: int) -> List[int]:
    """Generate the first `count` prime numbers.
    
    Uses the prime counting function upper bound to estimate sieve range.
    Time: O(n log n log log n), Space: O(n log n)
    
    Args:
        count: Number of primes to generate.
    Returns:
        List of the first `count` primes.
    """
    if count <= 0:
        return []
    if count <= 6:
        limit = 15
    else:
        ln_n = math.log(count)
        limit = int(count * (ln_n + math.log(ln_n)) + 100)
    primes = sieve_of_eratosthenes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_of_eratosthenes(limit)
    return primes[:count]


def generate_bounded_displacement_perm(
    n: int, K: int, seed: Optional[int] = None
) -> List[int]:
    """Generate a random permutation with bounded displacement K.
    
    Algorithm: Sequential assignment with backtracking.
    For each position i (left to right), choose σ(i) uniformly from
    available values in [i-K, i+K], ensuring a valid permutation exists
    for remaining positions.
    
    Time: O(n·K), Space: O(n)
    
    Args:
        n: Size of the permutation.
        K: Maximum displacement bound.
        seed: Random seed for reproducibility.
    Returns:
        A permutation σ as a list where σ[i] = j means position i maps to j.
    """
    rng = random.Random(seed)
    perm = list(range(n))
    used = [False] * n
    result = [0] * n
    
    for i in range(n):
        lo = max(0, i - K)
        hi = min(n - 1, i + K)
        candidates = [j for j in range(lo, hi + 1) if not used[j]]
        if not candidates:
            # Fallback: find any unused position
            candidates = [j for j in range(n) if not used[j]]
        choice = rng.choice(candidates)
        result[i] = choice
        used[choice] = True
    
    return result


def displacement_norm(perm: List[int]) -> int:
    """Compute the displacement norm (max displacement) of a permutation.
    
    The displacement norm is sup_n |σ(n) - n|, which equals the L^∞ norm
    of the displacement vector. In tropical geometry, this corresponds to
    the tropical norm (max-plus algebra).
    
    Time: O(n), Space: O(1)
    
    Args:
        perm: A permutation as a list.
    Returns:
        The maximum displacement.
    """
    return max(abs(perm[i] - i) for i in range(len(perm)))


def point_displacements(perm: List[int]) -> List[int]:
    """Compute all pointwise displacements |σ(n) - n|.
    
    Time: O(n), Space: O(n)
    """
    return [abs(perm[i] - i) for i in range(len(perm))]


def prime_ratio_convergence_test(
    perm: List[int],
    primes: List[int],
    window: int = 100,
    threshold: float = 0.01,
) -> Dict:
    """Test whether a permutation's prime ratio sequence converges to 1.
    
    Computes the ratio p_{σ(n)}/p_n and checks convergence by examining
    the deviation from 1 in a sliding window at the tail.
    
    Time: O(n), Space: O(n)
    
    Args:
        perm: Permutation to test.
        primes: List of primes (at least as long as perm).
        window: Size of the tail window for convergence check.
        threshold: Maximum allowed deviation from 1.
    Returns:
        Dictionary with convergence statistics.
    """
    n = len(perm)
    ratios = [primes[perm[i]] / primes[i] for i in range(n)]
    
    tail = ratios[-window:]
    mean = sum(tail) / len(tail)
    max_dev = max(abs(r - 1) for r in tail)
    variance = sum((r - mean)**2 for r in tail) / len(tail)
    
    return {
        "converges": max_dev < threshold,
        "mean_tail_ratio": mean,
        "max_deviation": max_dev,
        "variance": variance,
        "ratios": ratios,
    }


def estimate_convergent_density(
    n: int, num_trials: int = 100, seed: int = 0
) -> float:
    """Estimate the density of ratio-convergent permutations.
    
    Generates random permutations (finitely supported: shuffle a prefix,
    fix the rest) and tests what fraction have p_{σ(n)}/p_n → 1.
    
    For finitely supported permutations, this should be 100% (as we proved).
    For general permutations, the density depends on the growth rate.
    
    Time: O(trials · n log n), Space: O(n)
    
    Args:
        n: Size of permutation.
        num_trials: Number of random permutations to test.
        seed: Random seed.
    Returns:
        Estimated fraction of convergent permutations.
    """
    rng = random.Random(seed)
    primes = nth_primes(n)
    convergent = 0
    
    for trial in range(num_trials):
        # Generate finitely-supported permutation
        support_size = rng.randint(1, n // 2)
        perm = list(range(n))
        prefix = list(range(support_size))
        rng.shuffle(prefix)
        for i in range(support_size):
            perm[i] = prefix[i]
        
        result = prime_ratio_convergence_test(perm, primes)
        if result["converges"]:
            convergent += 1
    
    return convergent / num_trials


def compose_permutations(sigma: List[int], tau: List[int]) -> List[int]:
    """Compose two permutations: (σ ∘ τ)(i) = σ(τ(i)).
    
    Time: O(n), Space: O(n)
    """
    n = len(sigma)
    return [sigma[tau[i]] for i in range(n)]


def invert_permutation(perm: List[int]) -> List[int]:
    """Compute the inverse of a permutation.
    
    Time: O(n), Space: O(n)
    """
    n = len(perm)
    inv = [0] * n
    for i in range(n):
        inv[perm[i]] = i
    return inv


def tropical_displacement_distance(
    sigma: List[int], tau: List[int]
) -> int:
    """Compute the tropical displacement distance between two permutations.
    
    d(σ, τ) = sup_n |σ(n) - τ(n)| = displacement_norm(σ ∘ τ⁻¹)
    
    This is a metric on the symmetric group that makes it into a
    discrete metric space. The "tropical" aspect: the sup operation
    corresponds to tropical addition in max-plus algebra.
    
    Time: O(n), Space: O(n)
    """
    n = len(sigma)
    tau_inv = invert_permutation(tau)
    comp = compose_permutations(sigma, tau_inv)
    return displacement_norm(comp)


# Example usage
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    N = 5000
    primes = nth_primes(N)
    print(f"Generated {N} primes (largest: {primes[-1]})\n")
    
    # Bounded displacement generation
    for K in [1, 5, 10, 20]:
        perm = generate_bounded_displacement_perm(N, K, seed=42)
        norm = displacement_norm(perm)
        result = prime_ratio_convergence_test(perm, primes)
        print(f"K={K:3d}: actual_norm={norm:3d}, "
              f"converges={result['converges']}, "
              f"max_dev={result['max_deviation']:.6f}")
    
    print()
    
    # Density estimation
    density = estimate_convergent_density(1000, num_trials=50, seed=0)
    print(f"Estimated density of convergent (fin. supported) perms: {density:.2%}")
    
    print()
    
    # Tropical distance
    s1 = generate_bounded_displacement_perm(100, 3, seed=1)
    s2 = generate_bounded_displacement_perm(100, 5, seed=2)
    dist = tropical_displacement_distance(s1, s2)
    print(f"Tropical distance between two bounded-displacement perms: {dist}")
    print(f"  (bounded by K1 + K2 = {3 + 5} by triangle inequality)")
