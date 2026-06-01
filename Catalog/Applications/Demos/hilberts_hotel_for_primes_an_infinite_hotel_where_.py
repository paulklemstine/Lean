#!/usr/bin/env python3
"""
Hilbert's Hotel for Primes: Numerical Demonstrations

Demonstrates key results about asymptotically identity permutations
and their effect on prime rearrangements.
"""

import random
import math
from typing import List, Callable

def nth_prime(n: int) -> int:
    """Return the n-th prime (1-indexed)."""
    if n < 1:
        return 2
    primes = []
    candidate = 2
    while len(primes) < n:
        if all(candidate % p != 0 for p in primes):
            primes.append(candidate)
        candidate += 1
    return primes[-1]

def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def generate_primes(n: int) -> List[int]:
    """Generate first n primes using sieve with overestimate."""
    if n <= 0:
        return []
    # Prime counting function estimate: p_n ~ n * ln(n) for n >= 6
    if n < 6:
        limit = 15
    else:
        limit = int(n * (math.log(n) + math.log(math.log(n))) * 1.2) + 100
    primes = sieve_primes(limit)
    while len(primes) < n:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:n]


def demo_adjacent_swap(N: int = 1000):
    """Demonstrate that adjacent swap gives ratio → 1."""
    print("=" * 60)
    print(f"Demo 1: Adjacent Swap Permutation (N={N})")
    print("=" * 60)
    primes = generate_primes(N)

    print(f"\n{'n':>8} {'p_n':>10} {'p_σ(n)':>10} {'ratio':>10}")
    print("-" * 42)
    for n in [10, 50, 100, 500, N]:
        idx = n - 1  # 0-indexed
        if idx % 2 == 0:
            sigma_idx = idx + 1
        else:
            sigma_idx = idx - 1
        if sigma_idx < len(primes):
            ratio = primes[sigma_idx] / primes[idx]
            print(f"{n:>8} {primes[idx]:>10} {primes[sigma_idx]:>10} {ratio:>10.6f}")

    # Compute max deviation
    max_dev = 0
    for i in range(N):
        if i % 2 == 0:
            si = i + 1
        else:
            si = i - 1
        if si < N and i > 0:
            ratio = primes[si] / primes[i]
            max_dev = max(max_dev, abs(ratio - 1))
    print(f"\nMax |ratio - 1| over all n ≤ {N}: {max_dev:.6f}")
    print("(Converges to 0 as N → ∞)")


def demo_random_permutations(N: int = 10000, num_trials: int = 10):
    """Demonstrate ratio behavior for random permutations."""
    print("\n" + "=" * 60)
    print(f"Demo 2: Random Permutations (N={N}, trials={num_trials})")
    print("=" * 60)
    primes = generate_primes(N)

    for trial in range(num_trials):
        perm = list(range(N))
        random.shuffle(perm)

        # Compute ratio statistics at the tail
        tail_start = int(0.9 * N)
        ratios = []
        for i in range(tail_start, N):
            if i > 0:
                ratios.append(primes[perm[i]] / primes[i])

        mean_ratio = sum(ratios) / len(ratios)
        max_ratio = max(ratios)
        min_ratio = min(ratios)
        print(f"  Trial {trial+1:>2}: mean={mean_ratio:.4f}, "
              f"min={min_ratio:.4f}, max={max_ratio:.4f}")

    print("\nNote: Random permutations do NOT give ratio → 1.")
    print("Most random permutations move elements far from their position.")


def demo_bounded_displacement(N: int = 5000, k: int = 10):
    """Demonstrate bounded displacement permutations."""
    print("\n" + "=" * 60)
    print(f"Demo 3: Bounded Displacement (N={N}, k={k})")
    print("=" * 60)
    primes = generate_primes(N)

    # Create a random bounded-displacement permutation
    perm = list(range(N))
    for i in range(N - 1):
        # Swap with a random element within distance k
        j = random.randint(max(0, i), min(N - 1, i + k))
        perm[i], perm[j] = perm[j], perm[i]

    # Check displacement bound
    max_disp = max(abs(perm[i] - i) for i in range(N))
    print(f"  Actual max displacement: {max_disp}")

    # Compute ratios at various points
    print(f"\n{'n':>8} {'ratio':>10} {'|ratio-1|':>12}")
    print("-" * 34)
    for n in [100, 500, 1000, 2000, N - 1]:
        if n < N and n > 0:
            ratio = primes[perm[n]] / primes[n]
            print(f"{n:>8} {ratio:>10.6f} {abs(ratio-1):>12.8f}")

    # Show convergence
    tail_ratios = [primes[perm[i]] / primes[i] for i in range(N//2, N) if i > 0]
    mean_dev = sum(abs(r - 1) for r in tail_ratios) / len(tail_ratios)
    print(f"\n  Mean |ratio-1| in tail half: {mean_dev:.8f}")
    print(f"  Theory predicts O(k/n) = O({k}/{N}) = {k/N:.8f}")


def demo_density_conjecture(N: int = 100, epsilon: float = 0.5, num_samples: int = 10000):
    """Test the density conjecture: what fraction of permutations are ε-close?"""
    print("\n" + "=" * 60)
    print(f"Demo 4: Density Conjecture (N={N}, ε={epsilon})")
    print("=" * 60)

    count_good = 0
    for _ in range(num_samples):
        perm = list(range(1, N + 1))
        random.shuffle(perm)
        is_good = all(abs(perm[i] / (i + 1) - 1) < epsilon
                      for i in range(N))
        if is_good:
            count_good += 1

    fraction = count_good / num_samples
    print(f"  Fraction of permutations with max|σ(n)/n - 1| < {epsilon}: "
          f"{fraction:.4f}")
    print(f"  ({count_good} out of {num_samples} samples)")

    # Test for different N values
    print(f"\n  N vs fraction (ε={epsilon}):")
    for test_N in [10, 20, 30, 50]:
        count = 0
        for _ in range(num_samples):
            perm = list(range(1, test_N + 1))
            random.shuffle(perm)
            is_good = all(abs(perm[i] / (i + 1) - 1) < epsilon
                          for i in range(test_N))
            if is_good:
                count += 1
        print(f"    N={test_N:>3}: {count/num_samples:.4f}")
    print("\n  Conjecture: this fraction → 0 as N → ∞")


def demo_sigma_over_n_convergence():
    """Show σ(n)/n convergence for various permutation types."""
    print("\n" + "=" * 60)
    print("Demo 5: σ(n)/n Convergence Comparison")
    print("=" * 60)

    N = 5000

    # Identity
    identity_ratios = [(i+1)/(i+1) for i in range(N)]

    # Adjacent swap
    adj_ratios = []
    for i in range(N):
        if i % 2 == 0 and i + 1 < N:
            adj_ratios.append((i + 2) / (i + 1))
        elif i % 2 == 1:
            adj_ratios.append(i / (i + 1))
        else:
            adj_ratios.append(1.0)

    # Block reversal (reverse blocks of size sqrt(n))
    block_perm = list(range(N))
    block_size = int(math.sqrt(N))
    for start in range(0, N, block_size):
        end = min(start + block_size, N)
        block_perm[start:end] = reversed(block_perm[start:end])
    block_ratios = [(block_perm[i] + 1) / (i + 1) for i in range(N)]

    print(f"\n{'n':>8} {'Identity':>10} {'AdjSwap':>10} {'BlockRev':>10}")
    print("-" * 42)
    for n in [10, 100, 500, 1000, 2000, N]:
        i = n - 1
        print(f"{n:>8} {identity_ratios[i]:>10.6f} "
              f"{adj_ratios[i]:>10.6f} {block_ratios[i]:>10.6f}")

    # Show tail statistics
    tail = range(N//2, N)
    for name, ratios in [("Identity", identity_ratios),
                         ("AdjSwap", adj_ratios),
                         ("BlockRev", block_ratios)]:
        tail_dev = max(abs(ratios[i] - 1) for i in tail)
        print(f"  {name:>10} max tail |ratio-1|: {tail_dev:.8f}")


if __name__ == "__main__":
    random.seed(42)
    demo_adjacent_swap()
    demo_random_permutations()
    demo_bounded_displacement()
    demo_density_conjecture()
    demo_sigma_over_n_convergence()
    print("\n" + "=" * 60)
    print("All demos complete.")


#!/usr/bin/env python3
"""
Visualization: Prime ratio convergence for different permutation types.
"""

import math
import random

def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def generate_primes(n):
    if n <= 0:
        return []
    if n < 6:
        limit = 15
    else:
        limit = int(n * (math.log(n) + math.log(math.log(n))) * 1.2) + 100
    primes = sieve_primes(limit)
    while len(primes) < n:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:n]

def main():
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    random.seed(42)
    N = 2000
    primes = generate_primes(N)

    # Create permutations
    # 1. Identity
    identity = list(range(N))

    # 2. Adjacent swap
    adj_swap = list(range(N))
    for i in range(0, N - 1, 2):
        adj_swap[i], adj_swap[i+1] = adj_swap[i+1], adj_swap[i]

    # 3. Bounded displacement (k=10)
    bd_perm = list(range(N))
    for i in range(N - 1):
        j = random.randint(i, min(N - 1, i + 10))
        bd_perm[i], bd_perm[j] = bd_perm[j], bd_perm[i]

    # 4. Random permutation
    rand_perm = list(range(N))
    random.shuffle(rand_perm)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Prime Ratio p_σ(n) / p_n for Different Permutation Types",
                 fontsize=14, fontweight='bold')

    perms = [
        ("Identity", identity, 'blue'),
        ("Adjacent Swap", adj_swap, 'green'),
        ("Bounded Displacement (k=10)", bd_perm, 'orange'),
        ("Random Permutation", rand_perm, 'red'),
    ]

    for ax, (name, perm, color) in zip(axes.flat, perms):
        ratios = [primes[perm[i]] / primes[i] for i in range(1, N)]
        ns = list(range(1, N))

        ax.scatter(ns, ratios, s=0.5, alpha=0.5, color=color)
        ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.5)
        ax.set_title(name)
        ax.set_xlabel('n')
        ax.set_ylabel('p_σ(n) / p_n')

        # Compute running average
        window = 50
        if len(ratios) > window:
            running_avg = []
            for i in range(window, len(ratios)):
                running_avg.append(sum(ratios[i-window:i]) / window)
            ax.plot(range(window + 1, N), running_avg, color='black',
                    linewidth=1.5, label='Moving avg')
            ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('prime_ratio_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved prime_ratio_convergence.png")

if __name__ == "__main__":
    main()
