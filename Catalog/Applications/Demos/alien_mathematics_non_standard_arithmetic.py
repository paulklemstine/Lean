#!/usr/bin/env python3
"""
Demo: Non-Standard Arithmetic via Ultrafilters

Demonstrates key concepts from the formalized theory:
1. Ultrafilter color selection (2-coloring dichotomy)
2. Standard part computation (pigeonhole on bounded sequences)
3. Saturation degree estimation
4. Prime/composite dichotomy for diagonal elements
"""

import random
from typing import List, Callable, Set

# ============================================================
# Demo 1: Ultrafilter Color Selection
# ============================================================

def demo_color_selection():
    """
    For any 2-coloring of ℕ, an ultrafilter selects exactly one color.
    We simulate this with a "principal-like" filter concentrated on large numbers.
    """
    print("=" * 60)
    print("DEMO 1: Ultrafilter Color Selection")
    print("=" * 60)

    colorings = {
        "parity": lambda n: n % 2,
        "mod3_threshold": lambda n: 0 if n % 3 == 0 else 1,
        "sqrt_parity": lambda n: int(n ** 0.5) % 2,
    }

    N = 100000  # simulate "U-large" by looking at tail behavior

    for name, c in colorings.items():
        count_0 = sum(1 for i in range(N // 2, N) if c(i) == 0)
        count_1 = sum(1 for i in range(N // 2, N) if c(i) == 1)
        total = N // 2
        selected = 0 if count_0 > count_1 else 1
        print(f"\n  Coloring '{name}':")
        print(f"    Color 0 density (tail): {count_0/total:.4f}")
        print(f"    Color 1 density (tail): {count_1/total:.4f}")
        print(f"    → Ultrafilter would select color {selected}")

    print()


# ============================================================
# Demo 2: Standard Part Theorem
# ============================================================

def demo_standard_part():
    """
    For a bounded sequence f with f(i) ≤ n, the ultrafilter
    selects exactly one value m ≤ n (the "standard part").
    """
    print("=" * 60)
    print("DEMO 2: Standard Part Theorem")
    print("=" * 60)

    sequences = {
        "f(i) = i mod 3": lambda i: i % 3,
        "f(i) = min(i, 5)": lambda i: min(i, 5),
        "f(i) = (i*i) mod 7": lambda i: (i * i) % 7,
    }

    N = 100000

    for name, f in sequences.items():
        bound = max(f(i) for i in range(N))
        # Count how often each value appears in the tail
        value_counts = {}
        for i in range(N // 2, N):
            v = f(i)
            value_counts[v] = value_counts.get(v, 0) + 1

        total = N // 2
        print(f"\n  Sequence '{name}' (bound = {bound}):")
        for v in sorted(value_counts.keys()):
            density = value_counts[v] / total
            print(f"    Value {v}: density = {density:.4f}")

        # The "standard part" is the value selected by the ultrafilter
        # For a density-based ultrafilter, it's the most common value
        std_part = max(value_counts.keys(), key=lambda v: value_counts[v])
        print(f"    → Standard part (density-selected): {std_part}")

    print()


# ============================================================
# Demo 3: Saturation Degree
# ============================================================

def demo_saturation_degree():
    """
    The saturation degree measures how far a predicate extends
    into the "non-standard" realm (large indices).
    """
    print("=" * 60)
    print("DEMO 3: Saturation Degree")
    print("=" * 60)

    predicates = {
        "P(i) = 'i is even'": lambda i: i % 2 == 0,
        "P(i) = 'i < 1000'": lambda i: i < 1000,
        "P(i) = 'i has a factor > 10'": lambda i: any(i % p == 0 for p in range(11, i + 1)) if i > 1 else False,
        "P(i) = 'i is not a perfect square'": lambda i: int(i ** 0.5) ** 2 != i,
    }

    N = 10000

    for name, P in predicates.items():
        # Estimate saturation degree: find the largest n such that
        # P holds on "most" of {n, n+1, ..., N}
        sat_deg = 0
        for n in range(N):
            count = sum(1 for i in range(n, min(n + 1000, N)) if P(i))
            if count > 500:  # "U-large" ≈ density > 0.5
                sat_deg = n
            else:
                break

        if sat_deg >= N - 1001:
            print(f"\n  {name}: satDeg = ∞ (holds everywhere)")
        else:
            print(f"\n  {name}: satDeg ≈ {sat_deg}")

    print()


# ============================================================
# Demo 4: Prime/Composite Dichotomy
# ============================================================

def is_prime(n: int) -> bool:
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


def demo_prime_dichotomy():
    """
    The diagonal element ω = [id] is prime in some ultrapowers
    and composite in others. We visualize the prime density.
    """
    print("=" * 60)
    print("DEMO 4: Prime/Composite Dichotomy for ω = [id]")
    print("=" * 60)

    N = 100000
    prime_count = 0
    composite_count = 0

    for i in range(2, N):
        if is_prime(i):
            prime_count += 1
        else:
            composite_count += 1

    print(f"\n  Among {{2, ..., {N-1}}}:")
    print(f"    Primes: {prime_count} ({100*prime_count/(N-2):.2f}%)")
    print(f"    Composites: {composite_count} ({100*composite_count/(N-2):.2f}%)")
    print(f"\n  → An ultrafilter concentrating on primes makes ω prime")
    print(f"  → An ultrafilter concentrating on composites makes ω composite")
    print(f"  → BOTH types of ultrafilter exist (proved in Lean!)")

    # Show prime density decay (approximation to PNT)
    print(f"\n  Prime density at different scales:")
    for k in [100, 1000, 10000, 100000]:
        count = sum(1 for i in range(2, k) if is_prime(i))
        import math
        theoretical = k / math.log(k)
        print(f"    π({k}) = {count}, N/ln(N) ≈ {theoretical:.0f}, ratio = {count/theoretical:.4f}")

    print()


# ============================================================
# Demo 5: Residue Class Selection
# ============================================================

def demo_residue_selection():
    """
    For any modulus m, an ultrafilter selects exactly one residue class.
    """
    print("=" * 60)
    print("DEMO 5: Residue Class Selection")
    print("=" * 60)

    for m in [2, 3, 5, 7, 12]:
        print(f"\n  Modulus m = {m}:")
        print(f"    Residue classes: {{0, 1, ..., {m-1}}}")
        print(f"    An ultrafilter selects EXACTLY ONE class")
        print(f"    (proved for all m > 0 in Lean)")

    print()


if __name__ == "__main__":
    demo_color_selection()
    demo_standard_part()
    demo_saturation_degree()
    demo_prime_dichotomy()
    demo_residue_selection()

    print("=" * 60)
    print("All demos complete. See Lean proofs in Novelty/NonStdArith/")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Prime Density and the Ultrafilter Dichotomy

Shows how the prime density decays (PNT), illustrating why BOTH
prime-selecting and composite-selecting ultrafilters exist.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def sieve_of_eratosthenes(limit: int) -> list:
    """Return list of primes up to limit."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def main():
    N = 100000
    primes = set(sieve_of_eratosthenes(N))

    # Compute running prime density
    xs = list(range(2, N + 1))
    prime_count = [0] * len(xs)
    running = 0
    for idx, x in enumerate(xs):
        if x in primes:
            running += 1
        prime_count[idx] = running

    densities = [prime_count[i] / xs[i] for i in range(len(xs))]
    pnt_approx = [1 / math.log(x) if x > 1 else 0 for x in xs]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Non-Standard Arithmetic: Prime/Composite Dichotomy\nfor the Diagonal Element ω = [id]',
                 fontsize=14, fontweight='bold')

    # Plot 1: Prime counting function
    ax1 = axes[0, 0]
    ax1.plot(xs, prime_count, 'b-', linewidth=0.5, label='π(n)')
    ax1.plot(xs, [x / math.log(x) if x > 1 else 0 for x in xs],
             'r--', linewidth=1, label='n/ln(n)')
    ax1.set_xlabel('n')
    ax1.set_ylabel('π(n)')
    ax1.set_title('Prime Counting Function π(n)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Prime density
    ax2 = axes[0, 1]
    ax2.plot(xs[10:], densities[10:], 'b-', linewidth=0.5, label='π(n)/n')
    ax2.plot(xs[10:], pnt_approx[10:], 'r--', linewidth=1, label='1/ln(n)')
    ax2.set_xlabel('n')
    ax2.set_ylabel('Density')
    ax2.set_title('Prime Density → 0 (but primes are infinite)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 0.3)

    # Plot 3: Local prime indicator (window of size 100)
    ax3 = axes[1, 0]
    window = 100
    local_density = []
    local_xs = []
    for start in range(2, N - window, window):
        count = sum(1 for i in range(start, start + window) if i in primes)
        local_density.append(count / window)
        local_xs.append(start + window // 2)

    ax3.bar(local_xs[:200], local_density[:200], width=window * 0.9,
            color=['blue' if d > 0.15 else 'red' for d in local_density[:200]],
            alpha=0.6)
    ax3.axhline(y=0.15, color='green', linestyle='--', label='Threshold')
    ax3.set_xlabel('n (center of window)')
    ax3.set_ylabel('Local prime density')
    ax3.set_title('Local Prime Density (window=100)\nBlue=high, Red=low')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Plot 4: Saturation degree illustration
    ax4 = axes[1, 1]
    predicates = {
        'P(i) = "i is even"': lambda i: i % 2 == 0,
        'P(i) = "i > 100"': lambda i: i > 100,
        'P(i) = "i is prime"': lambda i: i in primes,
        'P(i) = "i < 500"': lambda i: i < 500,
    }

    colors = ['blue', 'green', 'red', 'orange']
    for (name, P), color in zip(predicates.items(), colors):
        sat_profile = []
        check_range = range(0, 2000, 10)
        for n in check_range:
            count = sum(1 for i in range(n, n + 200) if P(i))
            sat_profile.append(count / 200)
        ax4.plot(list(check_range), sat_profile, color=color, label=name, linewidth=1.5)

    ax4.axhline(y=0.5, color='black', linestyle=':', label='U-large threshold')
    ax4.set_xlabel('Starting index n')
    ax4.set_ylabel('Density of P on [n, n+200]')
    ax4.set_title('Saturation Degree: How Far P Extends')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_prime_density.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_prime_density.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Ultrafilter Color Selection and Residue Classes

Demonstrates how ultrafilters partition ℕ by selecting one color
from any finite coloring, and one residue class from any modulus.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Ultrafilter Selection: Color Classes and Residue Classes',
                 fontsize=14, fontweight='bold')

    N = 500

    # Plot 1: 2-coloring by parity
    ax1 = axes[0, 0]
    xs = np.arange(N)
    colors_parity = ['blue' if x % 2 == 0 else 'red' for x in xs]
    ax1.scatter(xs, [x % 2 for x in xs], c=colors_parity, s=2, alpha=0.5)
    ax1.set_xlabel('n')
    ax1.set_ylabel('c(n)')
    ax1.set_title('2-Coloring: Parity\nUltrafilter selects ONE class')
    ax1.set_yticks([0, 1])
    ax1.set_yticklabels(['Even (blue)', 'Odd (red)'])

    # Plot 2: 3-coloring by mod 3
    ax2 = axes[0, 1]
    color_map = {0: 'blue', 1: 'green', 2: 'red'}
    colors_mod3 = [color_map[x % 3] for x in xs]
    ax2.scatter(xs, [x % 3 for x in xs], c=colors_mod3, s=2, alpha=0.5)
    ax2.set_xlabel('n')
    ax2.set_ylabel('c(n)')
    ax2.set_title('3-Coloring: mod 3\nUltrafilter selects ONE residue class')
    ax2.set_yticks([0, 1, 2])

    # Plot 3: Residue class densities for different moduli
    ax3 = axes[1, 0]
    moduli = [2, 3, 5, 7, 11]
    for m in moduli:
        densities = []
        for r in range(m):
            count = sum(1 for i in range(N) if i % m == r)
            densities.append(count / N)
        ax3.bar([f"m={m},r={r}" for r in range(m)], densities,
                alpha=0.6, label=f'mod {m}')

    ax3.set_xlabel('Residue class')
    ax3.set_ylabel('Density')
    ax3.set_title('Residue Class Densities\n(Equal by symmetry → ultrafilter breaks tie)')
    ax3.tick_params(axis='x', rotation=90, labelsize=6)

    # Plot 4: Standard part illustration
    ax4 = axes[1, 1]
    # Sequence f(i) = i mod 5
    f_vals = [i % 5 for i in range(N)]
    window = 50
    for m in range(5):
        running = []
        for start in range(0, N - window, 5):
            count = sum(1 for i in range(start, start + window) if f_vals[i] == m)
            running.append(count / window)
        ax4.plot(range(0, N - window, 5), running,
                 label=f'Density of f=={m}', linewidth=1.5)

    ax4.axhline(y=0.5, color='black', linestyle=':', label='Majority threshold')
    ax4.set_xlabel('Window start')
    ax4.set_ylabel('Density')
    ax4.set_title('Standard Part: f(i) = i mod 5\nUltrafilter selects one value')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_ultrafilter_selection.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_ultrafilter_selection.png")


if __name__ == "__main__":
    main()
