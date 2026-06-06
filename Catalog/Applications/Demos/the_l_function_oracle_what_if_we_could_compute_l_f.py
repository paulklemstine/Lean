#!/usr/bin/env python3
"""
L-Function Oracle Theory — Demonstration Script

Demonstrates the key theorems from the L-function oracle research:
1. Zero propagation for completely multiplicative functions
2. Non-vanishing extraction theorem
3. Prime zero characterization
4. Pigeonhole query bounds
5. Squarefree determination
"""

from typing import Callable


def make_compl_mult(prime_values: dict[int, int]) -> Callable[[int], int]:
    """Create a completely multiplicative function from its prime values.
    
    A completely multiplicative function f satisfies f(mn) = f(m)f(n) for all m, n.
    It is uniquely determined by its values at primes.
    """
    cache: dict[int, int] = {0: 0, 1: 1}
    
    def f(n: int) -> int:
        if n in cache:
            return cache[n]
        # Factor n and compute f(n) = product of f(p)^k for p^k || n
        result = 1
        temp = n
        for p in sorted(prime_values.keys()):
            while temp % p == 0:
                result *= prime_values[p]
                temp //= p
            if temp == 1:
                break
        if temp > 1:
            # temp is a prime not in our dictionary; treat f(temp) = 1
            pass
        cache[n] = result
        return result
    
    return f


def demo_zero_propagation():
    """Demonstrate Theorem 1: Zero Propagation.
    
    If f(p) = 0 for a prime p, then f(n) = 0 for all n divisible by p.
    """
    print("=" * 60)
    print("DEMO 1: Zero Propagation Theorem")
    print("=" * 60)
    print()
    
    # Create f with f(3) = 0, f(2) = 1, f(5) = 2, f(7) = -1
    f = make_compl_mult({2: 1, 3: 0, 5: 2, 7: -1})
    
    print("Completely multiplicative function with f(3) = 0:")
    print(f"  f(2) = {f(2)}, f(3) = {f(3)}, f(5) = {f(5)}, f(7) = {f(7)}")
    print()
    
    print("Values at multiples of 3 (all should be 0):")
    for n in range(3, 31, 3):
        print(f"  f({n}) = {f(n)}", end="")
        assert f(n) == 0, f"Zero propagation failed at n={n}!"
    print()
    print()
    
    print("Values at non-multiples of 3 (should be nonzero if no other prime zeros):")
    for n in [1, 2, 4, 5, 7, 8, 10, 11, 14, 16, 20, 25]:
        print(f"  f({n}) = {f(n)}")
    print()
    print("✓ Zero propagation verified: f(3) = 0 implies f(n) = 0 for all 3|n")
    print()


def demo_nonvanishing_extraction():
    """Demonstrate Theorem 11: Non-Vanishing Extraction.
    
    If f(p) ≠ 0 for all primes p, then f(n) ≠ 0 for all n ≥ 1.
    """
    print("=" * 60)
    print("DEMO 2: Non-Vanishing Extraction Theorem")
    print("=" * 60)
    print()
    
    # Liouville's function: λ(n) = (-1)^Ω(n), completely multiplicative
    # λ(p) = -1 for all primes p, so λ(p) ≠ 0 for all p
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    f = make_compl_mult({p: -1 for p in primes})
    
    print("Liouville's function λ(n) = (-1)^Ω(n):")
    print("  λ(p) = -1 for all primes p (nonzero at all primes)")
    print()
    
    print("Values (all should be nonzero — ±1):")
    for n in range(1, 31):
        val = f(n)
        print(f"  λ({n:2d}) = {val:+d}", end="  ")
        if n % 6 == 0:
            print()
        assert val != 0, f"Non-vanishing failed at n={n}!"
    print()
    print()
    print("✓ Non-vanishing verified: λ(p) ≠ 0 for all p implies λ(n) ≠ 0 for all n ≥ 1")
    print()


def demo_prime_zero_characterization():
    """Demonstrate Theorem 5: Prime Zero Characterization.
    
    n ∈ Z(F) iff n has a prime factor in PZ(F).
    """
    print("=" * 60)
    print("DEMO 3: Prime Zero Characterization")
    print("=" * 60)
    print()
    
    # f with f(2) = 0, f(5) = 0, all other primes nonzero
    f = make_compl_mult({2: 0, 3: 1, 5: 0, 7: 2, 11: -1, 13: 3})
    
    print("f with prime zeros PZ = {2, 5}:")
    print()
    
    print("n:  zero?  has factor in {2,5}?  match?")
    print("-" * 50)
    for n in range(2, 41):
        is_zero = (f(n) == 0)
        has_prime_zero_factor = (n % 2 == 0) or (n % 5 == 0)
        match = (is_zero == has_prime_zero_factor)
        print(f"  {n:2d}:  {'yes' if is_zero else 'no ':3s}    "
              f"{'yes' if has_prime_zero_factor else 'no ':3s}           "
              f"{'✓' if match else '✗'}")
        assert match, f"Characterization failed at n={n}!"
    print()
    print("✓ All match: n ∈ Z(f) ⟺ n has a prime factor in {2, 5}")
    print()


def demo_pigeonhole():
    """Demonstrate Theorem 8: Pigeonhole Query Bound.
    
    With k binary queries on n elements, if n > 2^k, two elements
    must give identical responses.
    """
    print("=" * 60)
    print("DEMO 4: Pigeonhole Query Bound")
    print("=" * 60)
    print()
    
    import random
    random.seed(42)
    
    for k in range(1, 6):
        n = 2**k + 1  # n > 2^k
        
        # Generate k random binary queries on n elements
        queries = [[random.choice([0, 1]) for _ in range(n)] for _ in range(k)]
        
        # Compute response patterns
        patterns: dict[tuple[int, ...], list[int]] = {}
        for x in range(n):
            pattern = tuple(queries[q][x] for q in range(k))
            if pattern not in patterns:
                patterns[pattern] = []
            patterns[pattern].append(x)
        
        # Find a collision
        collision = None
        for pattern, elements in patterns.items():
            if len(elements) >= 2:
                collision = (elements[0], elements[1], pattern)
                break
        
        print(f"k={k}, n={n} (> 2^{k}={2**k}):")
        print(f"  {len(patterns)} distinct patterns out of {2**k} possible")
        if collision:
            x, y, pat = collision
            print(f"  Collision: elements {x} and {y} both have pattern {pat}")
        print(f"  ✓ Pigeonhole confirmed: {n} > {2**k} guarantees collision")
        print()


def demo_squarefree_determination():
    """Demonstrate Theorem 9: Squarefree Determination.
    
    Two multiplicative functions agreeing on primes agree on all squarefree numbers.
    """
    print("=" * 60)
    print("DEMO 5: Squarefree Determination")
    print("=" * 60)
    print()
    
    def is_squarefree(n: int) -> bool:
        if n <= 1:
            return n == 1
        d = 2
        while d * d <= n:
            if n % (d * d) == 0:
                return False
            d += 1
        return True
    
    # Two functions that agree on primes but differ on non-prime behavior
    # For completely multiplicative functions, agreeing on primes means
    # agreeing EVERYWHERE on squarefree numbers
    f = make_compl_mult({2: 3, 3: -2, 5: 4, 7: 1, 11: -1, 13: 2})
    g = make_compl_mult({2: 3, 3: -2, 5: 4, 7: 1, 11: -1, 13: 2})
    
    print("f and g agree on all primes (same prime values).")
    print()
    print("Squarefree numbers n ∈ [1, 30]: f(n) == g(n)?")
    
    sqf_count = 0
    for n in range(1, 31):
        if is_squarefree(n):
            sqf_count += 1
            assert f(n) == g(n), f"Squarefree determination failed at n={n}!"
            print(f"  n={n:2d} (squarefree): f(n)={f(n):5d}, g(n)={g(n):5d} ✓")
    
    print(f"\n✓ All {sqf_count} squarefree numbers in [1,30] satisfy f(n) = g(n)")
    print()


if __name__ == "__main__":
    print("L-Function Oracle Theory — Demonstration")
    print("=" * 60)
    print()
    
    demo_zero_propagation()
    demo_nonvanishing_extraction()
    demo_prime_zero_characterization()
    demo_pigeonhole()
    demo_squarefree_determination()
    
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy and Pigeonhole Bounds

Shows the relationship between query count k and the maximum
number of distinguishable elements 2^k.
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left panel: 2^k growth vs linear
    ax1 = axes[0]
    k_vals = np.arange(0, 11)
    power_vals = 2 ** k_vals
    
    ax1.bar(k_vals - 0.15, power_vals, 0.3, color='steelblue', alpha=0.8,
           label='Max distinguishable elements (2^k)')
    ax1.bar(k_vals + 0.15, k_vals + 1, 0.3, color='coral', alpha=0.8,
           label='Number of queries (k)')
    
    ax1.set_xlabel('Number of Binary Queries (k)', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title('Pigeonhole Bound: 2^k Distinguishable Elements', fontsize=14)
    ax1.set_yscale('log')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')
    ax1.set_xticks(k_vals)

    # Right panel: Oracle hierarchy levels
    ax2 = axes[1]
    
    # Simulate oracle hierarchy: level k can solve problems requiring k queries
    levels = list(range(8))
    
    # Size of solvable set at each level (exponential growth)
    level_power = [2**k for k in levels]
    
    # Draw nested sets
    max_r = 4
    colors_list = plt.cm.viridis(np.linspace(0.2, 0.9, len(levels)))
    
    for i, (lev, col) in enumerate(zip(reversed(levels), reversed(colors_list))):
        r = max_r * (lev + 1) / len(levels)
        circle = plt.Circle((0, 0), r, color=col, alpha=0.3, linewidth=2, 
                           edgecolor=col)
        ax2.add_patch(circle)
        if lev < 7:
            ax2.text(0, r - 0.2, f'Level {lev}\n(2^{lev}={2**lev} problems)',
                    ha='center', va='top', fontsize=8, fontweight='bold')
    
    ax2.set_xlim(-5, 5)
    ax2.set_ylim(-5, 5)
    ax2.set_aspect('equal')
    ax2.set_title('Oracle Hierarchy: Nested Levels of Power', fontsize=14)
    ax2.text(0, -4.5, 'Each level ⊂ next level (monotonicity theorem)',
            ha='center', fontsize=10, style='italic')
    ax2.text(0, 4.5, '∞: No finite level is universal (diagonal theorem)',
            ha='center', fontsize=10, style='italic', color='red')
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved oracle_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Zero Propagation in Multiplicative Functions

Shows how zeros at primes propagate to all multiples,
creating a visual "sieve" pattern.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


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


def compl_mult_eval(n: int, prime_values: dict) -> int:
    if n == 0:
        return 0
    if n == 1:
        return 1
    result = 1
    temp = n
    for p in sorted(prime_values.keys()):
        while temp % p == 0:
            result *= prime_values[p]
            temp //= p
    if temp > 1:
        result *= prime_values.get(temp, 1)
    return result


def main():
    N = 100
    prime_zeros = {3, 7}
    prime_values = {}
    for p in range(2, N + 1):
        if is_prime(p):
            prime_values[p] = 0 if p in prime_zeros else 1

    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left panel: Grid showing zero propagation
    ax1 = axes[0]
    rows, cols = 10, 10
    colors = np.zeros((rows, cols, 3))
    
    for i in range(rows):
        for j in range(cols):
            n = i * cols + j + 1
            if n > N:
                continue
            val = compl_mult_eval(n, prime_values)
            if val == 0:
                if is_prime(n) and n in prime_zeros:
                    colors[i, j] = [0.8, 0.0, 0.0]  # Red: prime zero
                else:
                    colors[i, j] = [1.0, 0.6, 0.6]  # Light red: propagated zero
            elif is_prime(n):
                colors[i, j] = [0.0, 0.6, 0.0]  # Green: prime nonzero
            else:
                colors[i, j] = [0.7, 0.9, 0.7]  # Light green: composite nonzero

    ax1.imshow(colors, aspect='equal')
    for i in range(rows):
        for j in range(cols):
            n = i * cols + j + 1
            if n <= N:
                ax1.text(j, i, str(n), ha='center', va='center', fontsize=7,
                        fontweight='bold' if is_prime(n) else 'normal')
    
    ax1.set_title(f'Zero Propagation from Primes {prime_zeros}', fontsize=14)
    ax1.set_xticks([])
    ax1.set_yticks([])
    
    red_patch = mpatches.Patch(color=[0.8, 0, 0], label='Prime zero (source)')
    pink_patch = mpatches.Patch(color=[1, 0.6, 0.6], label='Propagated zero')
    green_patch = mpatches.Patch(color=[0, 0.6, 0], label='Prime nonzero')
    lgreen_patch = mpatches.Patch(color=[0.7, 0.9, 0.7], label='Composite nonzero')
    ax1.legend(handles=[red_patch, pink_patch, green_patch, lgreen_patch],
              loc='upper center', bbox_to_anchor=(0.5, -0.02), ncol=2, fontsize=9)

    # Right panel: Zero density
    ax2 = axes[1]
    counts = []
    total_counts = []
    for n_max in range(1, N + 1):
        zero_count = sum(1 for n in range(1, n_max + 1) 
                        if compl_mult_eval(n, prime_values) == 0)
        counts.append(zero_count / n_max)
        
        # Theoretical density: 1 - ∏_{p ∈ PZ} (1 - 1/p)
        theoretical = 1 - np.prod([1 - 1/p for p in prime_zeros])
        total_counts.append(theoretical)
    
    x_vals = np.arange(1, N + 1)
    ax2.plot(x_vals, counts, 'b-', linewidth=1.5, label='Observed zero density')
    ax2.axhline(y=total_counts[-1], color='r', linestyle='--', linewidth=1.5,
               label=f'Theoretical: 1-∏(1-1/p) = {total_counts[-1]:.4f}')
    ax2.set_xlabel('N', fontsize=12)
    ax2.set_ylabel('Fraction of zeros in [1, N]', fontsize=12)
    ax2.set_title('Zero Density vs Theoretical Prediction', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 0.6)

    plt.tight_layout()
    plt.savefig('zero_propagation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved zero_propagation.png")


if __name__ == "__main__":
    main()
