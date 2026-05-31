#!/usr/bin/env python3
"""
Visualization: Artin Primitive Root Density
Plots the density of primes where a given integer is a primitive root,
compared to the Artin constant prediction.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    r, d = 0, n - 1
    while d % 2 == 0: r += 1; d //= 2
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
        if a >= n: continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1: continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1: break
        else: return False
    return True


def prime_factors(n):
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0: n //= d
        d += 1
    if n > 1: factors.append(n)
    return factors


def is_primitive_root(a, p):
    if p == 2: return a % 2 == 1
    a_mod = a % p
    if a_mod == 0: return False
    for q in prime_factors(p - 1):
        if pow(a_mod, (p - 1) // q, p) == 1: return False
    return True


def artin_constant_approx(num_primes=5000):
    product = 1.0
    count = 0
    n = 2
    while count < num_primes:
        if is_prime(n):
            product *= (1.0 - 1.0 / (n * (n - 1)))
            count += 1
        n += 1
    return product


def compute_running_density(a, bound):
    """Compute running density of primes where a is a primitive root."""
    x_vals = []
    y_vals = []
    count = 0
    total = 0
    for p in range(2, bound + 1):
        if is_prime(p):
            total += 1
            if is_primitive_root(a % p, p):
                count += 1
            if total >= 5:  # Start plotting after enough data
                x_vals.append(p)
                y_vals.append(count / total)
    return x_vals, y_vals


def main():
    C = artin_constant_approx(5000)
    bound = 20000

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Artin's Conjecture: Primitive Root Density", fontsize=16, fontweight='bold')

    # Plot 1: Running density for a=2,3,5,7
    ax = axes[0, 0]
    for a, color in [(2, 'blue'), (3, 'red'), (5, 'green'), (7, 'purple')]:
        x, y = compute_running_density(a, bound)
        ax.plot(x, y, color=color, alpha=0.7, linewidth=0.8, label=f'a = {a}')
    ax.axhline(y=C, color='black', linestyle='--', linewidth=1.5, label=f'C_Artin ≈ {C:.4f}')
    ax.set_xlabel('Prime p')
    ax.set_ylabel('Density')
    ax.set_title('Running Density of Primitive Root Primes')
    ax.legend(fontsize=9)
    ax.set_ylim(0.25, 0.55)
    ax.grid(True, alpha=0.3)

    # Plot 2: Count of primitive root primes vs C·π(N)
    ax = axes[0, 1]
    for a, color in [(2, 'blue'), (3, 'red'), (5, 'green')]:
        counts = []
        pi_vals = []
        count = 0
        total = 0
        checkpoints = list(range(100, bound + 1, 100))
        cp_idx = 0
        for p in range(2, bound + 1):
            if is_prime(p):
                total += 1
                if is_primitive_root(a % p, p):
                    count += 1
            if cp_idx < len(checkpoints) and p >= checkpoints[cp_idx]:
                counts.append(count)
                pi_vals.append(total)
                cp_idx += 1
        ax.plot(pi_vals, counts, color=color, alpha=0.8, linewidth=1.0, label=f'a = {a}')
    pi_arr = np.array(pi_vals)
    ax.plot(pi_arr, C * pi_arr, 'k--', linewidth=1.5, label=f'C·π(N)')
    ax.set_xlabel('π(N)')
    ax.set_ylabel('#{p ≤ N : a is prim. root mod p}')
    ax.set_title('Count vs. Artin Prediction')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Histogram of primitive root counts mod p
    ax = axes[1, 0]
    ratios = []
    for p in range(3, 5000):
        if is_prime(p):
            pr_count = sum(1 for a in range(1, min(p, 200)) if is_primitive_root(a, p))
            # Approximate ratio (for small p we check all, for large p we sample)
            if p < 200:
                ratio = pr_count / (p - 1)
            else:
                ratio = pr_count / 199
            ratios.append(ratio)
    ax.hist(ratios, bins=40, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=C, color='red', linestyle='--', linewidth=2, label=f'C_Artin ≈ {C:.4f}')
    ax.set_xlabel('φ(p-1)/(p-1)')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of Primitive Root Ratios')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Safe primes
    ax = axes[1, 1]
    safe_ps = []
    non_safe_prs = []
    safe_prs = []
    for p in range(5, 3000):
        if is_prime(p):
            q = (p - 1) // 2
            pr_count = sum(1 for a in range(2, p) if is_primitive_root(a, p))
            ratio = pr_count / (p - 1)
            if is_prime(q) and p > 3:
                safe_ps.append(p)
                safe_prs.append(ratio)
            else:
                non_safe_prs.append((p, ratio))

    if non_safe_prs:
        ns_p, ns_r = zip(*non_safe_prs)
        ax.scatter(ns_p, ns_r, s=3, alpha=0.3, color='gray', label='Non-safe primes')
    ax.scatter(safe_ps, safe_prs, s=15, alpha=0.8, color='red', label='Safe primes', zorder=5)
    ax.axhline(y=0.5, color='blue', linestyle='--', alpha=0.5, label='50% (safe prime limit)')
    ax.set_xlabel('Prime p')
    ax.set_ylabel('φ(p-1)/(p-1)')
    ax.set_title('Primitive Root Density: Safe vs. Non-Safe Primes')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('artin_density_plot.png', dpi=150, bbox_inches='tight')
    print("Saved artin_density_plot.png")


if __name__ == '__main__':
    main()
