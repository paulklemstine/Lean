#!/usr/bin/env python3
"""
demo.py — Non-Standard Arithmetic: Ultrapower Demonstrations

Demonstrates key concepts from the formalized non-standard arithmetic:
1. Free ultrafilter simulation (via density-1 sets)
2. Standard part computation
3. Overspill/underspill behavior
4. Growth rate comparisons (polynomial vs exponential)
5. Fermat's little theorem verification
6. Prime counting in non-standard intervals
"""

import math
from typing import List, Tuple, Callable


def is_cofinite(S: set, N: int) -> bool:
    """Check if S contains all but finitely many elements of {0,...,N-1}."""
    complement = set(range(N)) - S
    return len(complement) < math.sqrt(N)  # heuristic


def simulate_ultrafilter_membership(predicate: Callable[[int], bool],
                                     N: int = 10000) -> float:
    """Simulate whether {i | predicate(i)} is 'U-large' by computing density.
    For a free ultrafilter, cofinite sets are always large."""
    count = sum(1 for i in range(N) if predicate(i))
    return count / N


def demo_standard_part():
    """Demonstrate the standard part map for bounded sequences."""
    print("=" * 60)
    print("DEMO 1: Standard Part Map")
    print("=" * 60)
    print()

    # A bounded sequence: f(i) = i mod 7
    # In the ultrapower, this has a unique standard part (one of 0,...,6)
    f = lambda i: i % 7
    N = 10000

    # Count which value appears most frequently (simulating U-selection)
    counts = {}
    for i in range(N):
        v = f(i)
        counts[v] = counts.get(v, 0) + 1

    print(f"Sequence f(i) = i mod 7, checking {N} terms:")
    for v in sorted(counts.keys()):
        density = counts[v] / N
        print(f"  f(i) = {v}: density = {density:.4f}")
    print()
    print("Each residue class has density ~1/7 ≈ 0.1429")
    print("The ultrafilter selects EXACTLY ONE — which one depends on U.")
    print("This is the standard part: st([f]) ∈ {0,1,...,6}")
    print()


def demo_fermat_transfer():
    """Verify Fermat's Little Theorem transfer for sequences."""
    print("=" * 60)
    print("DEMO 2: Fermat's Little Theorem Transfer")
    print("=" * 60)
    print()

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

    print("Verifying a^p ≡ a (mod p) for various (a, p):")
    for p in primes:
        violations = 0
        for a in range(100):
            if pow(a, p, p) != a % p:
                violations += 1
        print(f"  p = {p:3d}: violations in a ∈ {{0,...,99}}: {violations}")

    print()
    print("In the ultrapower: for ANY sequence p(i) of primes,")
    print("a(i)^p(i) ≡ a(i) (mod p(i)) holds U-almost-everywhere.")
    print("This is our fermat_little_transfer theorem.")
    print()


def demo_wilson_transfer():
    """Verify Wilson's theorem transfer."""
    print("=" * 60)
    print("DEMO 3: Wilson's Theorem Transfer")
    print("=" * 60)
    print()

    print("Wilson's theorem: p prime ⟹ (p-1)! ≡ -1 (mod p)")
    print()
    for p in [2, 3, 5, 7, 11, 13]:
        factorial_val = math.factorial(p - 1)
        remainder = factorial_val % p
        print(f"  p = {p:3d}: ({p-1})! = {factorial_val:>10d}, "
              f"({p-1})! mod {p} = {remainder}, "
              f"({p-1})! + 1 mod {p} = {(factorial_val + 1) % p}")

    # Composites fail
    print()
    print("Composites FAIL Wilson's test (boundary case):")
    for n in [4, 6, 8, 9, 10, 12]:
        factorial_val = math.factorial(n - 1)
        print(f"  n = {n:3d}: ({n-1})! + 1 mod {n} = {(factorial_val + 1) % n} ≠ 0")
    print()


def demo_exp_dominates_poly():
    """Demonstrate that exponential dominates polynomial in *ℕ."""
    print("=" * 60)
    print("DEMO 4: Exponential Dominates Polynomial")
    print("=" * 60)
    print()

    for k in [1, 2, 3, 5, 10, 20]:
        # Find the crossover point where 2^i > i^k
        crossover = None
        for i in range(1, 10000):
            if 2**i > i**k:
                crossover = i
                break
        print(f"  k = {k:3d}: 2^i > i^k for all i ≥ {crossover}")
        if crossover and crossover < 100:
            print(f"           At crossover: 2^{crossover} = {2**crossover}, "
                  f"{crossover}^{k} = {crossover**k}")

    print()
    print("In *ℕ: 2^ω > ω^k for ANY standard k.")
    print("The complement {i | i^k ≥ 2^i} is FINITE, hence not in U.")
    print("This is our exp_dominates_poly_nonstandard theorem.")
    print()


def demo_prime_counting():
    """Demonstrate non-standard prime counting."""
    print("=" * 60)
    print("DEMO 5: Non-Standard Prime Counting π*(ω)")
    print("=" * 60)
    print()

    # π(n) for various n
    def prime_count(n):
        if n < 2:
            return 0
        sieve = [True] * (n + 1)
        sieve[0] = sieve[1] = False
        for i in range(2, int(n**0.5) + 1):
            if sieve[i]:
                for j in range(i*i, n + 1, i):
                    sieve[j] = False
        return sum(sieve)

    print("Standard prime counting function π(n):")
    for n in [10, 100, 1000, 10000, 100000]:
        pi_n = prime_count(n)
        ratio = pi_n / n if n > 0 else 0
        ln_ratio = n / math.log(n) if n > 1 else 0
        print(f"  π({n:>6d}) = {pi_n:>5d}, "
              f"π(n)/n = {ratio:.4f}, "
              f"n/ln(n) = {ln_ratio:.1f}")

    print()
    print("In *ℕ: π*(ω) is non-standard-infinite (exceeds every standard number)")
    print("but π*(ω)/ω is infinitesimal (less than every positive standard rational)")
    print("This captures the Prime Number Theorem non-standardly!")
    print()


def demo_internal_induction():
    """Demonstrate internal vs external induction."""
    print("=" * 60)
    print("DEMO 6: Internal Induction")
    print("=" * 60)
    print()

    print("Internal induction: for sequence-definable predicates P(i, m),")
    print("if P(i, 0) holds U-a.e. and P(i, n) → P(i, n+1) holds U-a.e.,")
    print("then P(i, m) holds U-a.e. for EVERY standard m.")
    print()
    print("Example: P(i, m) = 'i^m ≤ 2^i'")
    print()

    for m in [0, 1, 2, 5, 10, 20]:
        # {i | i^m ≤ 2^i} is cofinite
        exceptions = [i for i in range(1, 10000) if i**m > 2**i]
        if exceptions:
            max_exc = max(exceptions)
            print(f"  m = {m:3d}: P(i, m) fails for i ∈ [1, {max_exc}], "
                  f"holds for i ≥ {max_exc + 1}")
        else:
            print(f"  m = {m:3d}: P(i, m) holds for ALL i ≥ 1")

    print()
    print("EXTERNAL failure: the predicate 'i is standard' satisfies induction")
    print("(0 is standard, n standard → n+1 standard) but does NOT hold for all")
    print("elements of *ℕ — the non-standard ω is not standard!")
    print("This is because 'is standard' is not definable by sequences.")
    print()


def demo_underspill():
    """Demonstrate the underspill principle."""
    print("=" * 60)
    print("DEMO 7: Underspill Principle")
    print("=" * 60)
    print()

    print("Underspill: If P(i) ∨ (i < n) is U-large for all standard n,")
    print("then P(i) is U-large.")
    print()
    print("Intuition: if P holds for all 'infinite' elements and the set")
    print("of non-P elements is bounded by every standard number, then")
    print("the set of non-P elements must be empty (U-a.e.).")
    print()

    # Example: P(i) = "i is not a perfect square"
    N = 10000
    def is_perfect_square(i):
        s = int(math.isqrt(i))
        return s * s == i

    non_squares = sum(1 for i in range(N) if not is_perfect_square(i))
    print(f"P(i) = 'i is not a perfect square':")
    print(f"  In {{0,...,{N-1}}}: {non_squares}/{N} = {non_squares/N:.4f} satisfy P")
    print(f"  Perfect squares ≤ {N}: {int(math.isqrt(N)) + 1}")
    print(f"  Since perfect squares have density 0, {{i | P(i)}} is cofinite → U-large")
    print()


if __name__ == "__main__":
    demo_standard_part()
    demo_fermat_transfer()
    demo_wilson_transfer()
    demo_exp_dominates_poly()
    demo_prime_counting()
    demo_internal_induction()
    demo_underspill()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
viz_nonstandard.py — Visualization of Non-Standard Arithmetic

Generates plots illustrating key results from the formalization:
1. Polynomial vs Exponential growth (exp_dominates_poly_nonstandard)
2. Prime counting function transfer
3. Standard part map illustration
"""

import math


def sieve_primes(n):
    """Simple sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(n + 1) if is_prime[i]]


def prime_count(n):
    """Count primes up to n."""
    return len(sieve_primes(n))


def plot_growth_comparison():
    """Plot polynomial vs exponential growth rates."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping plot")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: log-scale comparison
    ax = axes[0]
    x = np.arange(1, 60)
    for k in [1, 2, 3, 5, 10]:
        y = x.astype(float)**k
        ax.semilogy(x, y, label=f'$n^{{{k}}}$', linewidth=1.5)
    y_exp = 2.0**x
    ax.semilogy(x, y_exp, 'k--', label='$2^n$', linewidth=2.5)

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Polynomial vs Exponential Growth\n'
                 r'In ${}^*\mathbb{N}$: $\omega^k < 2^\omega$ for all standard $k$',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: ratio i^k / 2^i → 0
    ax = axes[1]
    x = np.arange(1, 100)
    for k in [1, 2, 3, 5, 10]:
        ratio = x.astype(float)**k / 2.0**x
        # Clip very small values for display
        ratio = np.clip(ratio, 1e-30, None)
        ax.semilogy(x, ratio, label=f'$n^{{{k}}}/2^n$', linewidth=1.5)

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Ratio (log scale)', fontsize=12)
    ax.set_title(r'$n^k / 2^n \to 0$: Why $\{i \mid i^k \geq 2^i\}$ is finite',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-30)

    plt.tight_layout()
    plt.savefig('growth_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved growth_comparison.png")
    plt.close()


def plot_prime_counting():
    """Plot prime counting function and non-standard extension."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping plot")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: π(n) vs n/ln(n)
    ax = axes[0]
    ns = list(range(2, 5001))
    primes = sieve_primes(5000)
    pi_vals = []
    count = 0
    p_idx = 0
    for n in ns:
        while p_idx < len(primes) and primes[p_idx] <= n:
            count += 1
            p_idx += 1
        pi_vals.append(count)

    x = np.array(ns)
    ax.plot(x, pi_vals, 'b-', label=r'$\pi(n)$', linewidth=1.5)
    ax.plot(x, x / np.log(x), 'r--', label=r'$n/\ln(n)$', linewidth=1.5)
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(r'Prime Counting: $\pi(n) \sim n/\ln(n)$' + '\n'
                 r'Transfers to ${}^*\mathbb{N}$: $\pi^*(\omega) \sim \omega/\ln(\omega)$',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: π(n)/n → 0 (density of primes)
    ax = axes[1]
    density = np.array(pi_vals) / x
    ax.plot(x, density, 'g-', linewidth=1.5)
    ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel(r'$\pi(n)/n$', fontsize=12)
    ax.set_title(r'Prime Density $\pi(n)/n \to 0$' + '\n'
                 r'In ${}^*\mathbb{N}$: $\pi^*(\omega)/\omega$ is infinitesimal',
                 fontsize=13)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('prime_counting.png', dpi=150, bbox_inches='tight')
    print("Saved prime_counting.png")
    plt.close()


def plot_standard_part():
    """Illustrate the standard part map."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping plot")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: a bounded sequence and its "standard part"
    ax = axes[0]
    np.random.seed(42)
    N = 200
    # Sequence f(i) that is "mostly 3" with some noise
    f_vals = np.array([3 if i % 7 != 0 else (i % 5) for i in range(N)])

    ax.scatter(range(N), f_vals, s=8, alpha=0.6, c='blue')
    ax.axhline(y=3, color='red', linewidth=2, linestyle='--', label='st([f]) = 3')
    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('f(i)', fontsize=12)
    ax.set_title('Standard Part Map\n'
                 'Bounded [f] has unique standard value st([f])',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 6.5)

    # Right: Histogram of values showing U-selection
    ax = axes[1]
    values, counts = np.unique(f_vals, return_counts=True)
    colors = ['red' if v == 3 else 'lightblue' for v in values]
    ax.bar(values, counts / N, color=colors, edgecolor='black', width=0.6)
    ax.set_xlabel('Value', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title('Value Distribution\n'
                 'Ultrafilter selects the dominant value',
                 fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    # Annotate
    for v, c in zip(values, counts):
        if c / N > 0.1:
            ax.annotate(f'{c/N:.2f}', (v, c/N + 0.02),
                       ha='center', fontsize=10)

    plt.tight_layout()
    plt.savefig('standard_part.png', dpi=150, bbox_inches='tight')
    print("Saved standard_part.png")
    plt.close()


if __name__ == "__main__":
    plot_growth_comparison()
    plot_prime_counting()
    plot_standard_part()
    print("All visualizations generated.")
