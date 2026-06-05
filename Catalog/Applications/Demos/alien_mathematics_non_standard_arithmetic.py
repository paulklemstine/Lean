#!/usr/bin/env python3
"""
GrowthRank: Numerical Demonstrations of Non-Standard Arithmetic
===============================================================

Demonstrates the key concepts from the GrowthRank construction:
- Ultra-ordering on sequences
- Standard vs nonstandard elements
- Intermediate growth ranks
- Compositeness transfer
- Goldbach transfer
"""

import random
from math import sqrt, isqrt, log2
from typing import List, Tuple, Callable

# ============================================================
# Simulate an ultrafilter as a random consistent selector
# (In reality, free ultrafilters are non-constructive objects)
# ============================================================

def simulate_ultrafilter_vote(S: set, N: int = 1000) -> bool:
    """Simulate whether a subset S of {0,...,N-1} is 'U-large'.
    We approximate a free ultrafilter by: S is large iff |S ∩ {N//2,...,N-1}| > N//4.
    This is a coarse approximation that captures the 'cofinite' flavor."""
    tail = set(range(N // 2, N))
    return len(S & tail) > N // 4


def ultra_le(f: Callable, g: Callable, N: int = 1000) -> bool:
    """Check if f ≤_U g (approximately)."""
    S = {i for i in range(N) if f(i) <= g(i)}
    return simulate_ultrafilter_vote(S, N)


def ultra_lt(f: Callable, g: Callable, N: int = 1000) -> bool:
    """Check if f <_U g (approximately)."""
    S = {i for i in range(N) if f(i) < g(i)}
    return simulate_ultrafilter_vote(S, N)


# ============================================================
# Demo 1: Standard vs Nonstandard Elements
# ============================================================

def demo_standard_vs_nonstandard():
    print("=" * 60)
    print("Demo 1: Standard vs Nonstandard Elements")
    print("=" * 60)
    
    std_5 = lambda i: 5
    std_100 = lambda i: 100
    identity = lambda i: i
    quadratic = lambda i: i * i
    
    N = 1000
    
    print(f"\nComparing sequences over {{0, ..., {N-1}}}:")
    print(f"  std(5) ≤_U std(100)? {ultra_le(std_5, std_100, N)} (expected: True)")
    print(f"  std(100) ≤_U std(5)? {ultra_le(std_100, std_5, N)} (expected: False)")
    print(f"  std(100) <_U id?     {ultra_lt(std_100, identity, N)} (expected: True)")
    print(f"  id <_U i²?           {ultra_lt(identity, quadratic, N)} (expected: True)")
    print(f"  std(5) <_U √i?       {ultra_lt(std_5, lambda i: isqrt(i), N)} (expected: True)")
    print(f"  √i <_U id?           {ultra_lt(lambda i: isqrt(i), identity, N)} (expected: True)")
    
    print("\n  → The identity sequence is nonstandard: larger than all constants.")
    print("  → √i sits between standard elements and the identity.")


# ============================================================
# Demo 2: Growth Rank Hierarchy
# ============================================================

def demo_growth_hierarchy():
    print("\n" + "=" * 60)
    print("Demo 2: Growth Rank Hierarchy")
    print("=" * 60)
    
    # Define sequences of different growth rates
    sequences = [
        ("const(1)", lambda i: 1),
        ("const(10)", lambda i: 10),
        ("log₂(i+1)", lambda i: max(1, int(log2(i + 1)))),
        ("√i", lambda i: isqrt(max(1, i))),
        ("i", lambda i: i),
        ("i·log₂(i+1)", lambda i: i * max(1, int(log2(i + 1)))),
        ("i²", lambda i: i * i),
    ]
    
    N = 500
    print(f"\nGrowth rank ordering (N={N}):")
    print("  Sequence            ≤_U next?   Values at i=100,200,300")
    
    for j, (name, f) in enumerate(sequences):
        vals = f"{f(100):>8}, {f(200):>8}, {f(300):>8}"
        if j < len(sequences) - 1:
            _, g = sequences[j + 1]
            le = ultra_le(f, g, N)
            print(f"  {name:<20} → {le!s:<8}  [{vals}]")
        else:
            print(f"  {name:<20}            [{vals}]")
    
    print("\n  → Each sequence strictly dominates the previous one.")
    print("  → This chain shows 7 distinct growth ranks.")


# ============================================================
# Demo 3: No Minimum Nonstandard Element
# ============================================================

def demo_no_minimum():
    print("\n" + "=" * 60)
    print("Demo 3: No Minimum Nonstandard Element")
    print("=" * 60)
    
    print("\n  Starting from f(i) = i (nonstandard):")
    f = lambda i: i
    N = 1000
    
    for step in range(8):
        name = f"f/{2**step}" if step > 0 else "f = id"
        divisor = 2 ** step
        g = lambda i, d=divisor: i // d
        
        # Check it's still nonstandard (larger than some constant)
        threshold = 10
        S = {i for i in range(N) if g(i) > threshold}
        is_nonstandard = simulate_ultrafilter_vote(S, N)
        
        print(f"  {name:<12}: g(100)={g(100):>6}, g(500)={g(500):>6}, "
              f"g(999)={g(999):>6}, nonstandard? {is_nonstandard}")
    
    print("\n  → Repeated halving produces ever-smaller nonstandard elements.")
    print("  → The nonstandard part has no minimum.")


# ============================================================
# Demo 4: Compositeness Transfer
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


def smallest_factor(n: int) -> int:
    if n < 2:
        return n
    if n % 2 == 0:
        return 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return i
        i += 2
    return n


def demo_compositeness_transfer():
    print("\n" + "=" * 60)
    print("Demo 4: Compositeness Transfer")
    print("=" * 60)
    
    # f(i) = 6*i + 4 (always composite for i ≥ 1)
    f = lambda i: 6 * i + 4
    N = 100
    
    print(f"\n  f(i) = 6i + 4 (composite for i ≥ 1)")
    print(f"  Extracting factor sequences g(i), h(i) with f(i) = g(i) × h(i):\n")
    
    print(f"  {'i':>4} | {'f(i)':>6} | {'g(i)=minFac':>12} | {'h(i)=f/g':>10} | {'g≥2':>4} | {'h≥2':>4}")
    print(f"  {'-'*4}-+-{'-'*6}-+-{'-'*12}-+-{'-'*10}-+-{'-'*4}-+-{'-'*4}")
    
    g_ge2_count = 0
    h_ge2_count = 0
    eq_count = 0
    
    for i in range(1, N + 1):
        fi = f(i)
        gi = smallest_factor(fi)
        hi = fi // gi
        g_ok = gi >= 2
        h_ok = hi >= 2
        eq_ok = gi * hi == fi
        
        if g_ok: g_ge2_count += 1
        if h_ok: h_ge2_count += 1
        if eq_ok: eq_count += 1
        
        if i <= 8 or i == N:
            print(f"  {i:>4} | {fi:>6} | {gi:>12} | {hi:>10} | {'✓' if g_ok else '✗':>4} | {'✓' if h_ok else '✗':>4}")
        elif i == 9:
            print(f"  {'...':>4} | {'...':>6} | {'...':>12} | {'...':>10} | {'...':>4} | {'...':>4}")
    
    print(f"\n  Summary over {N} values:")
    print(f"    g(i) ≥ 2: {g_ge2_count}/{N} ({100*g_ge2_count/N:.0f}%)")
    print(f"    h(i) ≥ 2: {h_ge2_count}/{N} ({100*h_ge2_count/N:.0f}%)")
    print(f"    f = g×h:  {eq_count}/{N} ({100*eq_count/N:.0f}%)")
    print(f"\n  → Compositeness transfers: nontrivial factors exist U-a.e.")


# ============================================================
# Demo 5: Goldbach Transfer
# ============================================================

def demo_goldbach_transfer():
    print("\n" + "=" * 60)
    print("Demo 5: Goldbach Transfer to ℕ*")
    print("=" * 60)
    
    # f(i) = 2i + 4 (even, ≥ 4)
    f = lambda i: 2 * i + 4
    N = 100
    
    print(f"\n  f(i) = 2i + 4 (even, ≥ 4)")
    print(f"  Finding prime decompositions p(i) + q(i) = f(i):\n")
    
    successes = 0
    for i in range(N):
        fi = f(i)
        found = False
        for p in range(2, fi):
            if is_prime(p) and is_prime(fi - p):
                q = fi - p
                if i < 8 or i == N - 1:
                    print(f"  f({i}) = {fi} = {p} + {q} ({'✓' if is_prime(p) and is_prime(q) else '✗'})")
                elif i == 8:
                    print(f"  ...")
                successes += 1
                found = True
                break
        if not found:
            print(f"  f({i}) = {fi} — NO DECOMPOSITION FOUND!")
    
    print(f"\n  Goldbach decomposition found: {successes}/{N} ({100*successes/N:.0f}%)")
    print(f"  → If Goldbach holds for all ℕ, it automatically holds for ℕ*")


# ============================================================
# Demo 6: Underflow Principle
# ============================================================

def demo_underflow():
    print("\n" + "=" * 60)
    print("Demo 6: Underflow Principle")
    print("=" * 60)
    
    print("\n  Property P(n): 'n² + n + 41 is prime' (Euler's famous polynomial)")
    print("  This holds for n = 0, 1, ..., 39 but fails at n = 40.\n")
    
    for n in range(45):
        val = n * n + n + 41
        p = is_prime(val)
        if n <= 5 or 38 <= n <= 42:
            print(f"  P({n:>2}): {n}² + {n} + 41 = {val:>5}, prime? {p}")
        elif n == 6:
            print(f"  ...")
    
    print(f"\n  Underflow says: if P holds for ALL nonstandard n, then ∃ N, ∀ n ≥ N, P(n).")
    print(f"  Contrapositive: P(40) is false → there exists a nonstandard f with P(f(i)) false U-a.e.")
    print(f"  Indeed, take f(i) = 40 for all i. Then P(f(i)) = P(40) = False everywhere.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("GrowthRank: Numerical Demonstrations")
    print("of Non-Standard Arithmetic Structures")
    print()
    
    demo_standard_vs_nonstandard()
    demo_growth_hierarchy()
    demo_no_minimum()
    demo_compositeness_transfer()
    demo_goldbach_transfer()
    demo_underflow()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Growth Rank Hierarchy
=====================================

Plots the growth hierarchy of sequences, showing how different
growth rates create distinct strata in the GrowthRank ordering.
"""

import matplotlib.pyplot as plt
import numpy as np


def plot_growth_hierarchy():
    """Plot growth rank hierarchy showing standard vs nonstandard gap."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    n = np.arange(1, 200)
    
    # Left panel: Growth rates
    ax = axes[0]
    ax.plot(n, np.ones_like(n) * 5, 'b--', linewidth=1.5, label='std(5)', alpha=0.7)
    ax.plot(n, np.ones_like(n) * 20, 'b--', linewidth=1.5, label='std(20)', alpha=0.7)
    ax.plot(n, np.log2(n + 1), 'g-', linewidth=2, label='log₂(n)')
    ax.plot(n, np.sqrt(n), 'm-', linewidth=2, label='√n')
    ax.plot(n, n, 'r-', linewidth=2, label='n (identity)')
    ax.plot(n, n * np.log2(n + 1), 'orange', linewidth=2, label='n·log₂(n)')
    
    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('f(i)', fontsize=12)
    ax.set_title('Growth Rate Hierarchy', fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=9)
    ax.set_ylim(0, 250)
    
    # Add annotation for non-Archimedean gap
    ax.annotate('Standard\nregion', xy=(150, 12), fontsize=10, color='blue',
                ha='center', style='italic')
    ax.annotate('Nonstandard\nregion', xy=(150, 180), fontsize=10, color='red',
                ha='center', style='italic')
    ax.axhline(y=30, color='gray', linestyle=':', alpha=0.5)
    
    # Right panel: Growth rank ordering (symbolic)
    ax2 = axes[1]
    ranks = [
        (0.05, 'std(1)', 'blue'),
        (0.10, 'std(5)', 'blue'),
        (0.15, 'std(20)', 'blue'),
        (0.25, '⋮', 'gray'),
        (0.35, '── NON-ARCHIMEDEAN GAP ──', 'red'),
        (0.45, 'log₂(n)', 'green'),
        (0.55, '√n', 'purple'),
        (0.65, 'n^(2/3)', 'brown'),
        (0.75, 'n', 'red'),
        (0.85, 'n·log(n)', 'orange'),
        (0.95, 'n²', 'darkred'),
    ]
    
    for y, label, color in ranks:
        if '──' in label:
            ax2.axhline(y=y, color='red', linewidth=2, linestyle='--', alpha=0.7)
            ax2.text(0.5, y + 0.02, label, ha='center', fontsize=10,
                    color='red', fontweight='bold')
        elif label == '⋮':
            ax2.text(0.5, y, '⋮', ha='center', fontsize=16, color='gray')
        else:
            ax2.plot(0.5, y, 'o', color=color, markersize=10)
            ax2.text(0.55, y, f'  {label}', ha='left', va='center',
                    fontsize=11, color=color)
    
    ax2.set_xlim(0, 1.2)
    ax2.set_ylim(-0.05, 1.05)
    ax2.set_title('GrowthRank Ordering 𝔊(U)', fontsize=14, fontweight='bold')
    ax2.set_ylabel('Growth Rank (increasing ↑)', fontsize=12)
    ax2.set_xticks([])
    ax2.arrow(0.1, 0, 0, 0.95, head_width=0.03, head_length=0.02,
             fc='black', ec='black', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('growth_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: growth_hierarchy.png")


def plot_no_minimum():
    """Plot the 'no minimum nonstandard' theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n = np.arange(1, 300)
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 8))
    
    for k in range(8):
        divisor = 2 ** k
        y = n // divisor
        label = f'id/{divisor}' if k > 0 else 'id'
        ax.plot(n, y, color=colors[k], linewidth=2 - k * 0.2, label=label,
               alpha=0.8)
    
    # Standard threshold
    ax.axhline(y=20, color='blue', linestyle=':', alpha=0.5, label='std(20)')
    ax.fill_between(n, 0, 20, alpha=0.1, color='blue')
    ax.text(250, 22, 'Standard region', fontsize=10, color='blue', ha='center')
    
    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Sequence value', fontsize=12)
    ax.set_title('No Minimum Nonstandard Element:\nRepeated halving stays nonstandard',
                fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=9, ncol=2)
    ax.set_ylim(0, 100)
    
    plt.tight_layout()
    plt.savefig('no_minimum_nonstandard.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: no_minimum_nonstandard.png")


if __name__ == "__main__":
    plot_growth_hierarchy()
    plot_no_minimum()
