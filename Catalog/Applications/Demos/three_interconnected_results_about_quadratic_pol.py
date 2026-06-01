#!/usr/bin/env python3
"""
Demonstration of discriminant uniformity and splitting type analysis.

This script verifies the main theorems computationally:
1. Discriminant fiber uniformity for quadratic polynomials
2. Exact splitting type counts
3. Split fraction convergence to 1/2
4. Cubic uniformity conjecture testing
"""

from algorithms import (
    enumerate_fiber,
    compute_fiber_sizes,
    splitting_type_counts,
    discriminant_profile,
    verify_cubic_uniformity,
)


def demo_fiber_uniformity():
    """Verify discriminant fiber uniformity for small primes."""
    print("=" * 60)
    print("THEOREM A: Discriminant Fiber Uniformity")
    print("For odd prime p, every fiber of (b,c) ↦ b²-4c has size p.")
    print("=" * 60)
    
    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    for p in primes:
        sizes = compute_fiber_sizes(p)
        all_equal_p = all(s == p for s in sizes.values())
        status = "✓" if all_equal_p else "✗"
        min_s, max_s = min(sizes.values()), max(sizes.values())
        print(f"  p = {p:3d}: fiber sizes in [{min_s}, {max_s}], "
              f"all = {p}? {status}")
    print()


def demo_splitting_counts():
    """Verify exact splitting type formulas."""
    print("=" * 60)
    print("THEOREM B: Splitting Type Counts")
    print("Split = p(p-1)/2, Ramified = p, Inert = p(p-1)/2")
    print("=" * 60)
    
    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    for p in primes:
        profile = discriminant_profile(p)
        match_s = profile["numSplit"] == profile["theoreticalSplit"]
        match_r = profile["numRamified"] == profile["theoreticalRamified"]
        match_i = profile["numInert"] == profile["theoreticalInert"]
        status = "✓" if (match_s and match_r and match_i) else "✗"
        print(f"  p = {p:3d}: split={profile['numSplit']:5d} "
              f"(pred {profile['theoreticalSplit']:5d}), "
              f"ram={profile['numRamified']:3d} "
              f"(pred {profile['theoreticalRamified']:3d}), "
              f"inert={profile['numInert']:5d} "
              f"(pred {profile['theoreticalInert']:5d})  {status}")
    print()


def demo_split_fraction_convergence():
    """Show split fraction → 1/2 as p → ∞."""
    print("=" * 60)
    print("THEOREM C: Split Fraction → 1/2")
    print("(p-1)/(2p) approaches 0.5 as p grows")
    print("=" * 60)
    
    primes = [3, 5, 7, 11, 13, 29, 53, 97, 197, 499, 997]
    for p in primes:
        frac = (p - 1) / (2 * p)
        error = abs(frac - 0.5)
        print(f"  p = {p:5d}: split fraction = {frac:.6f}, "
              f"|error| = {error:.6f}")
    print()


def demo_fiber_parametrization():
    """Show the explicit fiber parametrization."""
    print("=" * 60)
    print("FIBER PARAMETRIZATION")
    print("b ↦ (b, (b²-d)/4) enumerates the fiber over d")
    print("=" * 60)
    
    p, d = 7, 3
    fiber = enumerate_fiber(p, d)
    print(f"  p = {p}, d = {d}")
    print(f"  Fiber over {d}:")
    for b, c in fiber:
        disc = (b * b - 4 * c) % p
        print(f"    b={b}, c={c}, b²-4c = {b*b}-{4*c} ≡ {disc} (mod {p})")
    print(f"  Fiber size: {len(fiber)} (should be {p})")
    print()


def demo_cubic_conjecture():
    """Test the cubic uniformity conjecture."""
    print("=" * 60)
    print("CONJECTURE: Cubic Discriminant Uniformity")
    print("Uniform for p ≡ 2 (mod 3), non-uniform for p ≡ 1 (mod 3)")
    print("=" * 60)
    
    # p ≡ 2 (mod 3): expect uniform
    print("\n  Primes p ≡ 2 (mod 3) — expect UNIFORM:")
    for p in [5, 11, 17, 23, 29]:
        is_uniform, sizes = verify_cubic_uniformity(p)
        status = "✓ UNIFORM" if is_uniform else "✗ NON-UNIFORM"
        min_s, max_s = min(sizes.values()), max(sizes.values())
        print(f"    p = {p:3d} (p mod 3 = {p % 3}): "
              f"fiber range [{min_s}, {max_s}]  {status}")
    
    # p ≡ 1 (mod 3): expect non-uniform
    print("\n  Primes p ≡ 1 (mod 3) — expect NON-UNIFORM:")
    for p in [7, 13, 19, 31, 37]:
        is_uniform, sizes = verify_cubic_uniformity(p)
        status = "✓ NON-UNIFORM" if not is_uniform else "✗ UNIFORM"
        min_s, max_s = min(sizes.values()), max(sizes.values())
        print(f"    p = {p:3d} (p mod 3 = {p % 3}): "
              f"fiber range [{min_s}, {max_s}]  {status}")
    print()


if __name__ == "__main__":
    demo_fiber_uniformity()
    demo_splitting_counts()
    demo_split_fraction_convergence()
    demo_fiber_parametrization()
    demo_cubic_conjecture()


#!/usr/bin/env python3
"""
Visualization of discriminant fiber uniformity and splitting type distributions.
"""
import matplotlib.pyplot as plt
import numpy as np


def compute_fiber_sizes(p):
    sizes = {d: 0 for d in range(p)}
    for b in range(p):
        for c in range(p):
            d = (b * b - 4 * c) % p
            sizes[d] += 1
    return sizes


def cubic_fiber_sizes(p):
    sizes = {d: 0 for d in range(p)}
    for b in range(p):
        for c in range(p):
            d = (-4 * b**3 - 27 * c**2) % p
            sizes[d] += 1
    return sizes


def plot_fiber_uniformity():
    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    primes = [3, 5, 7, 11, 13, 17]
    
    for ax, p in zip(axes.flat, primes):
        sizes = compute_fiber_sizes(p)
        ds = list(range(p))
        vals = [sizes[d] for d in ds]
        
        ax.bar(ds, vals, color='steelblue', alpha=0.8, edgecolor='navy')
        ax.axhline(y=p, color='red', linestyle='--', linewidth=1.5,
                   label=f'Expected = {p}')
        ax.set_title(f'p = {p}', fontsize=13, fontweight='bold')
        ax.set_xlabel('Discriminant d')
        ax.set_ylabel('Fiber size')
        ax.legend(fontsize=9)
        ax.set_ylim(0, p * 1.3)
    
    fig.suptitle('Discriminant Fiber Uniformity: |{(b,c) : b²-4c ≡ d}| = p',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fiber_uniformity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fiber_uniformity.png")


def plot_cubic_comparison():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # p ≡ 2 mod 3 (uniform)
    for ax, p in zip(axes[0], [5, 11]):
        sizes = cubic_fiber_sizes(p)
        ds = list(range(p))
        vals = [sizes[d] for d in ds]
        ax.bar(ds, vals, color='forestgreen', alpha=0.8, edgecolor='darkgreen')
        ax.axhline(y=p, color='red', linestyle='--', linewidth=1.5)
        ax.set_title(f'Cubic: p = {p} (p ≡ 2 mod 3) — UNIFORM', 
                     fontsize=11, fontweight='bold')
        ax.set_xlabel('Discriminant d')
        ax.set_ylabel('Fiber size')
    
    # p ≡ 1 mod 3 (non-uniform)
    for ax, p in zip(axes[1], [7, 13]):
        sizes = cubic_fiber_sizes(p)
        ds = list(range(p))
        vals = [sizes[d] for d in ds]
        colors = ['coral' if v != p else 'steelblue' for v in vals]
        ax.bar(ds, vals, color=colors, alpha=0.8, edgecolor='darkred')
        ax.axhline(y=p, color='red', linestyle='--', linewidth=1.5)
        ax.set_title(f'Cubic: p = {p} (p ≡ 1 mod 3) — NON-UNIFORM',
                     fontsize=11, fontweight='bold')
        ax.set_xlabel('Discriminant d')
        ax.set_ylabel('Fiber size')
    
    fig.suptitle('Cubic Discriminant Fibers: Uniformity Depends on p mod 3',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('cubic_fibers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved cubic_fibers.png")


def plot_convergence():
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53,
              59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 127, 149, 197, 251,
              307, 401, 499, 599, 701, 797, 907, 997]
    fractions = [(p - 1) / (2 * p) for p in primes]
    
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(primes, fractions, 'o-', color='steelblue', markersize=4,
            linewidth=1.5, label='Split fraction (p-1)/(2p)')
    ax.axhline(y=0.5, color='red', linestyle='--', linewidth=2,
               label='Limit = 1/2 (random permutation in S₂)')
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Split fraction', fontsize=12)
    ax.set_title('Split Fraction Convergence to 1/2 (Chebotarev for S₂)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved convergence.png")


if __name__ == "__main__":
    plot_fiber_uniformity()
    plot_cubic_comparison()
    plot_convergence()
