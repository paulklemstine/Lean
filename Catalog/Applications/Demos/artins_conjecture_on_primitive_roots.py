#!/usr/bin/env python3
"""
Demo: Artin's Conjecture on Primitive Roots

Numerical exploration of primitive roots and Artin's conjecture.
Demonstrates key theorems and computational predictions.
"""

from algorithms import (
    is_primitive_root, artin_primes, artin_constant_approx,
    artin_density, safe_primes, find_primitive_root,
    is_artin_candidate, euler_totient, prime_factors, is_prime
)


def demo_primitive_root_existence():
    """Demonstrate that every prime has primitive roots."""
    print("=" * 60)
    print("THEOREM: Every prime p has primitive roots")
    print("=" * 60)
    print()
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        g = find_primitive_root(p)
        phi = euler_totient(p - 1) if p > 2 else 1
        print(f"  p = {p:3d}: smallest primitive root = {g}, "
              f"φ(p-1) = φ({p-1}) = {phi} primitive roots total")
    print()


def demo_primitive_root_test():
    """Demonstrate the primitive root test criterion."""
    print("=" * 60)
    print("THEOREM: Primitive Root Test Criterion")
    print("  a is a primitive root mod p iff a^((p-1)/q) ≢ 1 (mod p)")
    print("  for every prime q | (p-1)")
    print("=" * 60)
    print()
    p = 23
    print(f"  Testing p = {p}, p-1 = {p-1}")
    pf = prime_factors(p - 1)
    print(f"  Prime factors of {p-1}: {pf}")
    print()
    for a in range(2, p):
        checks = []
        for q in pf:
            val = pow(a, (p - 1) // q, p)
            checks.append(f"  {a}^({p-1}/{q}) ≡ {val} (mod {p})")
        is_pr = is_primitive_root(a, p)
        status = "✓ PRIMITIVE ROOT" if is_pr else "✗ not primitive root"
        print(f"  a = {a:2d}: {status}")
        if a <= 7:  # Show details for first few
            for c in checks:
                print(f"       {c}")
    print()


def demo_artin_candidates():
    """Show which small integers are Artin candidates."""
    print("=" * 60)
    print("DEFINITION: Artin Candidates (a ≠ ±1, not a perfect square)")
    print("=" * 60)
    print()
    for a in range(-20, 21):
        if is_artin_candidate(a):
            primes = artin_primes(a, 100)
            print(f"  a = {a:4d}: primitive root mod {primes[:10]}{'...' if len(primes) > 10 else ''}")
    print()


def demo_artin_constant():
    """Compute and display the Artin constant."""
    print("=" * 60)
    print("THE ARTIN CONSTANT")
    print("  C = ∏_q prime (1 - 1/(q(q-1))) ≈ 0.3739558136...")
    print("=" * 60)
    print()
    for n in [10, 100, 1000, 10000]:
        c = artin_constant_approx(n)
        print(f"  Using first {n:6d} primes: C ≈ {c:.12f}")
    print()


def demo_artin_density():
    """Compare actual density with Artin constant prediction."""
    print("=" * 60)
    print("ARTIN'S CONJECTURE: Density of primitive root primes ≈ C_Artin")
    print("=" * 60)
    print()
    C = artin_constant_approx(5000)
    print(f"  Artin constant C ≈ {C:.10f}")
    print()
    for a in [2, 3, 5, 6, 7, 10]:
        if not is_artin_candidate(a):
            continue
        print(f"  a = {a}:")
        for bound in [100, 1000, 10000, 100000]:
            count, total, ratio = artin_density(a, bound)
            print(f"    primes ≤ {bound:7d}: {count:5d}/{total:5d} "
                  f"= {ratio:.6f} (predicted ≈ {C:.6f})")
        print()


def demo_safe_primes():
    """Demonstrate the safe prime theorem for primitive roots."""
    print("=" * 60)
    print("THEOREM: Safe Primes p = 2q+1 (q prime)")
    print("  For safe primes, primitive root testing is especially easy:")
    print("  only need to check two conditions.")
    print("=" * 60)
    print()
    sps = safe_primes(200)
    for p, q in sps:
        g = find_primitive_root(p)
        # Count primitive roots
        pr_count = sum(1 for a in range(1, p) if is_primitive_root(a, p))
        print(f"  p = {p:4d} = 2·{q} + 1: "
              f"smallest primitive root = {g}, "
              f"total = {pr_count} = φ({p-1})")
    print()


def demo_count_primitive_roots():
    """Verify φ(p-1) counts primitive roots."""
    print("=" * 60)
    print("THEOREM: Number of primitive roots mod p = φ(p-1)")
    print("=" * 60)
    print()
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61]:
        actual = sum(1 for a in range(1, p) if is_primitive_root(a, p))
        predicted = euler_totient(p - 1)
        status = "✓" if actual == predicted else "✗"
        print(f"  {status} p = {p:3d}: actual = {actual}, φ({p-1}) = {predicted}")
    print()


def demo_heath_brown():
    """Illustrate Heath-Brown's result: among {2,3,5}, at least one is
    a primitive root mod infinitely many primes."""
    print("=" * 60)
    print("HEATH-BROWN (1986): Among {2, 3, 5}, at least one is")
    print("  a primitive root mod infinitely many primes.")
    print("=" * 60)
    print()
    bound = 10000
    for a in [2, 3, 5]:
        primes = artin_primes(a, bound)
        print(f"  a = {a}: {len(primes)} primes ≤ {bound} where {a} is a primitive root")
    # Union
    s2 = set(artin_primes(2, bound))
    s3 = set(artin_primes(3, bound))
    s5 = set(artin_primes(5, bound))
    union = s2 | s3 | s5
    total = sum(1 for p in range(2, bound + 1) if is_prime(p))
    print(f"  Union: {len(union)} out of {total} primes ≤ {bound}")
    print(f"  Coverage: {len(union)/total:.4f}")
    print()


if __name__ == "__main__":
    demo_primitive_root_existence()
    demo_count_primitive_roots()
    demo_primitive_root_test()
    demo_artin_candidates()
    demo_artin_constant()
    demo_artin_density()
    demo_safe_primes()
    demo_heath_brown()


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
