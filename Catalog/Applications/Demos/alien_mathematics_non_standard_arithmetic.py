#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Numerical Demonstrations

Demonstrates key concepts from the ultrapower construction ℕ* = ∏ℕ/U:
1. Ultrafilter selection of values from finite ranges
2. Non-Archimedean elements (sequences growing beyond any bound)
3. Infinite primes (prime sequences that exceed all standard naturals)
4. Infinitely divisible elements (n! is divisible by every positive integer)
5. Descending chains (ω, ω-1, ω-2, ... demonstrating failure of well-ordering)
"""

import math
from typing import List, Tuple


def demonstrate_ultrafilter_selection():
    """Show how an ultrafilter 'selects' values from a 2-coloring."""
    print("=" * 60)
    print("1. ULTRAFILTER COLOR SELECTION")
    print("=" * 60)
    # Consider the 2-coloring c(n) = n mod 2
    N = 20
    coloring = [n % 2 for n in range(N)]
    evens = {i for i in range(N) if coloring[i] == 0}
    odds = {i for i in range(N) if coloring[i] == 1}
    print(f"Coloring c(n) = n mod 2 for n < {N}:")
    print(f"  Evens: {sorted(evens)}")
    print(f"  Odds:  {sorted(odds)}")
    print("  A free ultrafilter must contain exactly one of these")
    print("  (by the ultrafilter prime ideal property)")
    print()


def demonstrate_infinite_elements():
    """Show the 'infinite element' ω = [0, 1, 2, 3, ...]."""
    print("=" * 60)
    print("2. INFINITE ELEMENTS IN ℕ*")
    print("=" * 60)
    # ω = identity sequence, std(n) = constant-n sequence
    print("The element ω = [0, 1, 2, 3, 4, ...] in ℕ*")
    print("For any standard n, the set {i | n ≤ ω(i)} = {i | n ≤ i}")
    print("is cofinite, hence in any free ultrafilter.")
    print()
    for n in [5, 100, 10**6]:
        agreement_set = f"{{i | i ≥ {n}}}"
        print(f"  std({n}) ≤ ω because {agreement_set} is cofinite")
    print()
    print("Therefore ω exceeds EVERY standard natural — it is 'infinite'")
    print()


def demonstrate_infinite_primes():
    """Show the sequence of primes gives an infinite prime in ℕ*."""
    print("=" * 60)
    print("3. INFINITE PRIMES IN ℕ*")
    print("=" * 60)

    def nth_prime(n: int) -> int:
        """Return the n-th prime (0-indexed)."""
        count = 0
        candidate = 2
        while True:
            if all(candidate % d != 0 for d in range(2, int(math.sqrt(candidate)) + 1)):
                if count == n:
                    return candidate
                count += 1
            candidate += 1

    primes = [nth_prime(i) for i in range(15)]
    print(f"p* = [{', '.join(str(p) for p in primes)}, ...]")
    print()
    print("isPrime'(p*) holds because {i | Nat.Prime(p*(i))} = ℕ ∈ U")
    print()
    for n in [10, 50, 100]:
        # Find first index where p_i ≥ n
        idx = next(i for i in range(1000) if nth_prime(i) >= n)
        print(f"  std({n}) ≤ p* because p*({idx}) = {nth_prime(idx)} ≥ {n}")
    print()
    print("p* is simultaneously prime AND larger than every standard natural!")
    print()


def demonstrate_infinitely_divisible():
    """Show that n! is divisible by every standard natural."""
    print("=" * 60)
    print("4. INFINITELY DIVISIBLE ELEMENTS")
    print("=" * 60)
    print("ω! = [0!, 1!, 2!, 3!, ...] = [1, 1, 2, 6, 24, 120, ...]")
    print()
    factorials = [math.factorial(i) for i in range(10)]
    print(f"Sequence: {factorials}")
    print()
    for n in [2, 3, 5, 7, 12]:
        div_set = [i for i in range(20) if math.factorial(i) % n == 0]
        print(f"  {n} divides ω! on indices {div_set}...")
        print(f"    (all i ≥ {n}, which is cofinite → in U)")
    print()
    print("ω! is divisible by EVERY positive standard natural!")
    print()


def demonstrate_descending_chain():
    """Show the descending chain ω, ω-1, ω-2, ..."""
    print("=" * 60)
    print("5. FAILURE OF WELL-ORDERING: DESCENDING CHAINS")
    print("=" * 60)
    print("Define f(n) = mk(i ↦ i - n) = ω - std(n)")
    print()
    N = 8
    for n in range(6):
        seq = [max(0, i - n) for i in range(N)]
        print(f"  f({n}) = [{', '.join(str(x) for x in seq)}, ...]")
    print()
    print("f(n+1) ≤ f(n) because (i-(n+1)) ≤ (i-n) for all i")
    print("f(n+1) ≠ f(n) because they differ on {i | i > n+1} ∈ U")
    print()
    print("This is an INFINITE STRICTLY DESCENDING CHAIN!")
    print("ℕ* is linearly ordered but NOT well-ordered.")
    print("This means induction on ℕ* elements is impossible")
    print("— a fundamental difference from standard ℕ.")
    print()


def demonstrate_geometric_bound():
    """Show the geometric sum bound bridging to p-adic analysis."""
    print("=" * 60)
    print("6. BRIDGE TO p-ADIC ANALYSIS: GEOMETRIC SUM BOUND")
    print("=" * 60)
    for p in [2, 3, 5]:
        print(f"\n  p = {p}:")
        for n in range(1, 7):
            geo_sum = sum(p**k for k in range(n))
            power = p**n
            ratio = geo_sum / power
            print(f"    Σ_{{k<{n}}} {p}^k = {geo_sum:>6} ≤ {p}^{n} = {power:>6}  "
                  f"(ratio = {ratio:.4f})")
    print()
    print("The ratio Σp^k / p^n → 1/(p-1) as n → ∞")
    print("This growth pattern mirrors p-adic valuation depth:")
    print("v_p(n!) ~ n/(p-1), connecting ultrapowers to p-adic analysis.")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  NON-STANDARD ARITHMETIC: ULTRAPOWER CONSTRUCTION ℕ*   ║")
    print("║  Formally Verified in Lean 4 with Mathlib              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demonstrate_ultrafilter_selection()
    demonstrate_infinite_elements()
    demonstrate_infinite_primes()
    demonstrate_infinitely_divisible()
    demonstrate_descending_chain()
    demonstrate_geometric_bound()

    print("=" * 60)
    print("SUMMARY OF FORMALLY VERIFIED RESULTS")
    print("=" * 60)
    results = [
        ("std_injective", "ℕ ↪ ℕ* is injective"),
        ("std_add/mul", "std preserves +, ×"),
        ("std_le_iff", "std preserves ≤"),
        ("transfer_add_comm", "a + b = b + a in ℕ*"),
        ("transfer_mul_comm", "a × b = b × a in ℕ*"),
        ("transfer_add_assoc", "(a+b)+c = a+(b+c) in ℕ*"),
        ("transfer_mul_add", "a×(b+c) = a×b + a×c in ℕ*"),
        ("transfer_zero_product", "ab = 0 → a = 0 ∨ b = 0"),
        ("nonstd_le_total", "a ≤ b ∨ b ≤ a (linear order)"),
        ("nonstd_le_antisymm", "a ≤ b ∧ b ≤ a → a = b"),
        ("exists_infinite_element", "∃ω > every std n"),
        ("exists_infinite_prime", "∃p prime, p > every std n"),
        ("exists_infinitely_divisible", "∃ω, ∀n>0: n | ω"),
        ("euclid_transfer", "p prime, p|ab → p|a ∨ p|b"),
        ("exists_descending_chain", "ℕ* is NOT well-ordered"),
        ("geometric_sum_le_power", "Σp^k ≤ p^n (p-adic bridge)"),
    ]
    for name, desc in results:
        print(f"  ✓ {name:30s} — {desc}")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Non-Standard Arithmetic Ultrapower Structure

Generates a multi-panel figure showing:
1. The identity element ω vs standard naturals
2. The prime sequence p* exceeding all bounds
3. The factorial sequence ω! divisibility
4. The descending chain ω, ω-1, ω-2, ...
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def nth_prime(n):
    """Return the n-th prime (0-indexed)."""
    primes = []
    candidate = 2
    while len(primes) <= n:
        if all(candidate % p != 0 for p in primes if p * p <= candidate):
            primes.append(candidate)
        candidate += 1
    return primes[n]


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Non-Standard Arithmetic: The Ultrapower ℕ*',
                 fontsize=16, fontweight='bold', y=0.98)

    N = 25

    # Panel 1: ω = [0,1,2,...] vs standard naturals
    ax = axes[0, 0]
    indices = np.arange(N)
    omega_seq = indices.copy()
    for n in [5, 10, 15, 20]:
        std_seq = np.full(N, n)
        ax.plot(indices, std_seq, '--', alpha=0.5, label=f'std({n})')
        # Shade where ω ≥ std(n)
        mask = omega_seq >= n
        ax.fill_between(indices, 0, omega_seq, where=mask, alpha=0.05, color='blue')
    ax.plot(indices, omega_seq, 'b-', linewidth=2.5, label='ω = [0,1,2,...]', zorder=5)
    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.set_title('Infinite Element ω Exceeds All Standard Naturals')
    ax.legend(fontsize=8, loc='upper left')
    ax.set_ylim(-1, N + 2)
    ax.grid(True, alpha=0.3)

    # Panel 2: Prime sequence p*
    ax = axes[0, 1]
    prime_seq = [nth_prime(i) for i in range(N)]
    ax.plot(indices, prime_seq, 'r-o', markersize=4, linewidth=2, label='p* = [p₀, p₁, p₂, ...]')
    for n in [10, 30, 60]:
        ax.axhline(y=n, color='gray', linestyle='--', alpha=0.5)
        # Find first index exceeding n
        idx = next(i for i in range(N) if prime_seq[i] >= n)
        ax.annotate(f'std({n})', xy=(0, n), fontsize=8, color='gray')
        ax.plot(idx, prime_seq[idx], 'k*', markersize=10, zorder=5)
    ax.set_xlabel('Index i')
    ax.set_ylabel('p*(i)')
    ax.set_title('Infinite Prime p* = [2, 3, 5, 7, 11, ...]')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Factorial divisibility
    ax = axes[1, 0]
    fact_seq = [math.factorial(i) for i in range(12)]
    divisors = [2, 3, 5, 7]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    bar_width = 0.18
    x = np.arange(12)
    for j, (d, c) in enumerate(zip(divisors, colors)):
        divides = [1 if f % d == 0 else 0 for f in fact_seq]
        ax.bar(x + j * bar_width - 0.27, divides, bar_width, label=f'{d} | i!',
               color=c, alpha=0.7)
    ax.set_xlabel('Index i')
    ax.set_ylabel('Divides? (1=yes)')
    ax.set_title('ω! = [0!, 1!, 2!, ...] Divisible by All Standard n')
    ax.set_xticks(x)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 4: Descending chain
    ax = axes[1, 1]
    chain_length = 6
    N_chain = 20
    indices_chain = np.arange(N_chain)
    cmap = plt.cm.viridis
    for k in range(chain_length):
        chain_seq = np.maximum(0, indices_chain - k)
        color = cmap(k / (chain_length - 1))
        label = f'ω-{k}' if k > 0 else 'ω'
        ax.plot(indices_chain, chain_seq, '-', linewidth=2, color=color, label=label)
    ax.set_xlabel('Index i')
    ax.set_ylabel('f(k)(i) = max(0, i-k)')
    ax.set_title('Descending Chain: ω, ω-1, ω-2, ... (Never Reaches 0)')
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('ultrapower_structure.png', dpi=150, bbox_inches='tight')
    print("Saved ultrapower_structure.png")


if __name__ == "__main__":
    main()
