"""
Non-Standard Arithmetic Demo
============================
Demonstrates the ultrapower construction and key properties
of non-standard natural numbers.
"""

import random
from typing import List, Callable, Set, Tuple

# --- Ultrafilter Simulation ---
# We cannot construct a true free ultrafilter computationally (requires AC),
# but we can simulate one using a density-based heuristic:
# a set S ⊆ ℕ is "U-large" if it has density 1.

def density(S: Set[int], N: int = 10000) -> float:
    """Estimate the density of S ∩ {0,...,N-1}."""
    return len([x for x in range(N) if x in S]) / N

def is_U_large(S: Set[int], N: int = 10000) -> bool:
    """Heuristic: S is 'U-large' if it has high density."""
    return density(S, N) > 0.5

# --- Ultrapower Element ---
class UltrapowerElement:
    """Represents an element of ℕ* as a sequence ℕ → ℕ."""
    def __init__(self, f: Callable[[int], int], name: str = ""):
        self.f = f
        self.name = name or "anonymous"

    def __repr__(self):
        vals = [self.f(i) for i in range(10)]
        return f"[{self.name}] = ({', '.join(map(str, vals))}, ...)"

    def add(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        return UltrapowerElement(lambda i: self.f(i) + other.f(i),
                                f"({self.name} + {other.name})")

    def mul(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        return UltrapowerElement(lambda i: self.f(i) * other.f(i),
                                f"({self.name} * {other.name})")

    def eq_on(self, other: 'UltrapowerElement', N: int = 10000) -> Set[int]:
        """Set where self == other."""
        return {i for i in range(N) if self.f(i) == other.f(i)}

    def lt_on(self, other: 'UltrapowerElement', N: int = 10000) -> Set[int]:
        """Set where self < other."""
        return {i for i in range(N) if self.f(i) < other.f(i)}


# --- Demo 1: Standard Embedding ---
print("=" * 60)
print("DEMO 1: Standard Embedding ℕ → ℕ*")
print("=" * 60)

std_5 = UltrapowerElement(lambda i: 5, "std(5)")
std_7 = UltrapowerElement(lambda i: 7, "std(7)")
print(f"  std(5) = {std_5}")
print(f"  std(7) = {std_7}")
print(f"  std(5) + std(7) = {std_5.add(std_7)}")
print(f"  std(5) * std(7) = {std_5.mul(std_7)}")
print(f"  Agree set (std(5) == std(7)): density = {density(std_5.eq_on(std_7)):.4f}")
print(f"  → std(5) ≠ std(7) (empty agree set)")
print()

# --- Demo 2: Infinite Element ---
print("=" * 60)
print("DEMO 2: The Infinite Element id ∈ ℕ*")
print("=" * 60)

omega = UltrapowerElement(lambda i: i, "ω")
print(f"  ω = {omega}")
for n in [10, 100, 1000]:
    std_n = UltrapowerElement(lambda i, n=n: n, f"std({n})")
    agree = omega.eq_on(std_n)
    exceed = omega.lt_on(std_n)
    print(f"  ω vs std({n}): agree density = {density(agree):.4f}, "
          f"ω > std({n}) density = {1 - density(exceed):.4f}")
print(f"  → ω exceeds ALL standard numbers (agree density → 0)")
print()

# --- Demo 3: Division Algorithm Transfer ---
print("=" * 60)
print("DEMO 3: Division Algorithm in ℕ*")
print("=" * 60)

f_elem = UltrapowerElement(lambda i: i * i + 7, "i²+7")
g_elem = UltrapowerElement(lambda i: i + 1, "i+1")
q_elem = UltrapowerElement(lambda i: (i*i + 7) // (i + 1), "q")
r_elem = UltrapowerElement(lambda i: (i*i + 7) % (i + 1), "r")

print(f"  f = {f_elem}")
print(f"  g = {g_elem}")
print(f"  q = f/g = {q_elem}")
print(f"  r = f%g = {r_elem}")

div_check = {i for i in range(1, 10000) if f_elem.f(i) == g_elem.f(i) * q_elem.f(i) + r_elem.f(i)}
rem_check = {i for i in range(1, 10000) if r_elem.f(i) < g_elem.f(i)}
print(f"  f = g*q + r holds on: density = {len(div_check)/9999:.4f}")
print(f"  r < g holds on: density = {len(rem_check)/9999:.4f}")
print(f"  → Division algorithm transfers to ℕ* ✓")
print()

# --- Demo 4: GCD Transfer ---
print("=" * 60)
print("DEMO 4: GCD Transfer in ℕ*")
print("=" * 60)

import math
f_gcd = UltrapowerElement(lambda i: 6 * i + 12, "6i+12")
g_gcd = UltrapowerElement(lambda i: 4 * i + 8, "4i+8")
d_gcd = UltrapowerElement(lambda i: math.gcd(6*i+12, 4*i+8), "gcd")

print(f"  f = {f_gcd}")
print(f"  g = {g_gcd}")
print(f"  gcd(f,g) = {d_gcd}")

gcd_divf = {i for i in range(10000) if d_gcd.f(i) > 0 and f_gcd.f(i) % d_gcd.f(i) == 0}
gcd_divg = {i for i in range(10000) if d_gcd.f(i) > 0 and g_gcd.f(i) % d_gcd.f(i) == 0}
print(f"  gcd | f density = {density(gcd_divf):.4f}")
print(f"  gcd | g density = {density(gcd_divg):.4f}")
print(f"  → GCD transfers to ℕ* ✓")
print()

# --- Demo 5: Overspill ---
print("=" * 60)
print("DEMO 5: Overspill Principle Illustration")
print("=" * 60)

print("  Property P(i, n) = 'i > n' (downward closed)")
print("  For each standard n: {i | P(i,n)} = {i | i > n}")
print("  This set has density → 1 as N → ∞")
for n in [10, 100, 1000]:
    P_set = {i for i in range(10000) if i > n}
    print(f"    n={n}: density = {density(P_set):.4f}")
print()
print("  Overspill: ∃ f(i) → ∞ with P(i, f(i)) = 'i > f(i)' U-large")
print("  f = id works: {i | i > i} = ∅ → FAILS for f=id")
print("  f(i) = i-1 works: {i | i > i-1} = ℕ\\{0} → SUCCESS")
print("  The proof constructs the optimal f by case analysis.")
print()

# --- Demo 6: Trichotomy ---
print("=" * 60)
print("DEMO 6: Order Trichotomy in ℕ*")
print("=" * 60)

a = UltrapowerElement(lambda i: i**2, "i²")
b = UltrapowerElement(lambda i: 2*i + 1, "2i+1")

lt_set = a.lt_on(b)
eq_set = a.eq_on(b)
gt_set = {i for i in range(10000) if a.f(i) > b.f(i)}

print(f"  a = {a}")
print(f"  b = {b}")
print(f"  a < b density: {density(lt_set):.4f}")
print(f"  a = b density: {density(eq_set):.4f}")
print(f"  a > b density: {density(gt_set):.4f}")
print(f"  → Exactly one is 'U-large' (dominant density)")
print()

# --- Demo 7: Standard Part ---
print("=" * 60)
print("DEMO 7: Standard Part of Bounded Elements")
print("=" * 60)

bounded = UltrapowerElement(lambda i: i % 5, "i mod 5")
print(f"  f = {bounded} (bounded by 4)")
for m in range(5):
    eq_set = {i for i in range(10000) if bounded.f(i) == m}
    print(f"    f = {m} density: {density(eq_set):.4f}")
print("  → No single value dominates (no free ultrafilter simulation)")
print("  But for a TRUE free ultrafilter, exactly one value is selected!")
print()

print("=" * 60)
print("All demos completed successfully.")
print("=" * 60)


"""
Visualization: Ultrapower Elements and Transfer Properties
==========================================================
Standalone matplotlib visualization of non-standard arithmetic concepts.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def plot_ultrapower_elements():
    """Plot standard vs non-standard elements of ℕ*."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Non-Standard Arithmetic: Ultrapower Elements', fontsize=16, fontweight='bold')

    N = 50
    indices = np.arange(N)

    # Plot 1: Standard vs Infinite elements
    ax1 = axes[0, 0]
    ax1.plot(indices, np.full(N, 5), 'b-', linewidth=2, label='std(5) = (5, 5, 5, ...)')
    ax1.plot(indices, indices, 'r-', linewidth=2, label='ω = (0, 1, 2, ...)')
    ax1.plot(indices, indices**2, 'g--', linewidth=1.5, label='ω² = (0, 1, 4, ...)')
    ax1.set_xlabel('Index i')
    ax1.set_ylabel('Value')
    ax1.set_title('Standard vs Non-Standard Elements')
    ax1.legend()
    ax1.set_ylim(-5, 100)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Division algorithm transfer
    ax2 = axes[0, 1]
    f_vals = indices**2 + 7
    g_vals = indices + 1
    q_vals = np.array([f_vals[i] // g_vals[i] for i in range(N)])
    r_vals = np.array([f_vals[i] % g_vals[i] for i in range(N)])
    check = np.array([f_vals[i] == g_vals[i] * q_vals[i] + r_vals[i] for i in range(N)])

    ax2.plot(indices, q_vals, 'b-', linewidth=1.5, label='q = f÷g')
    ax2.plot(indices, r_vals, 'r-', linewidth=1.5, label='r = f mod g')
    ax2.fill_between(indices, 0, g_vals, alpha=0.1, color='green', label='g (divisor bound)')
    ax2.plot(indices, g_vals, 'g--', linewidth=1, alpha=0.5)
    ax2.set_xlabel('Index i')
    ax2.set_ylabel('Value')
    ax2.set_title(f'Division Algorithm Transfer (all {sum(check)} indices verify)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Plot 3: GCD transfer
    ax3 = axes[1, 0]
    f_gcd = 6 * indices + 12
    g_gcd = 4 * indices + 8
    d_gcd = np.array([math.gcd(int(f_gcd[i]), int(g_gcd[i])) for i in range(N)])

    ax3.plot(indices, f_gcd, 'b-', linewidth=1.5, label='f = 6i+12')
    ax3.plot(indices, g_gcd, 'r-', linewidth=1.5, label='g = 4i+8')
    ax3.plot(indices, d_gcd, 'k-', linewidth=2, label='gcd(f,g)')
    ax3.fill_between(indices, 0, d_gcd, alpha=0.2, color='yellow')
    ax3.set_xlabel('Index i')
    ax3.set_ylabel('Value')
    ax3.set_title('GCD Transfer: gcd(6i+12, 4i+8)')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Plot 4: Overspill illustration
    ax4 = axes[1, 1]
    N_overspill = 100
    idx = np.arange(N_overspill)

    # P(i, n) = "i > n" — downward closed
    # For each n, {i | i > n} contains {n+1, n+2, ...}
    for n in [5, 15, 30, 50]:
        P_set = idx > n
        ax4.fill_between(idx, 0, P_set.astype(float) * 0.8 + n * 0.01,
                        alpha=0.15, label=f'P(·, {n})')
        ax4.axhline(y=n * 0.01, color='gray', linestyle=':', alpha=0.3)

    # The overspill witness f(i) = i-1
    f_overspill = np.maximum(idx - 1, 0)
    ax4.plot(idx, f_overspill / N_overspill, 'k-', linewidth=2,
            label='f(i) = i-1 (overspill)')
    ax4.set_xlabel('Index i')
    ax4.set_ylabel('Normalized value')
    ax4.set_title('Overspill: P(i,n)="i>n" spills to non-standard f')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('ultrapower_elements.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved ultrapower_elements.png")


def plot_trichotomy():
    """Visualize order trichotomy in ℕ*."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Order Trichotomy in ℕ*: Exactly One Relation Holds U-a.e.',
                fontsize=14, fontweight='bold')

    N = 200
    indices = np.arange(N)

    comparisons = [
        (lambda i: i**2, lambda i: 3*i + 10, 'i² vs 3i+10'),
        (lambda i: 2*i + 1, lambda i: 2*i + 1, '2i+1 vs 2i+1'),
        (lambda i: i + 100, lambda i: i**2, 'i+100 vs i²'),
    ]

    for ax, (f, g, title) in zip(axes, comparisons):
        f_vals = np.array([f(i) for i in range(N)])
        g_vals = np.array([g(i) for i in range(N)])

        lt_mask = f_vals < g_vals
        eq_mask = f_vals == g_vals
        gt_mask = f_vals > g_vals

        colors = np.where(lt_mask, 'blue', np.where(eq_mask, 'green', 'red'))

        for i in range(N):
            ax.bar(i, 1, color=colors[i], alpha=0.7, width=1.0)

        lt_pct = sum(lt_mask) / N * 100
        eq_pct = sum(eq_mask) / N * 100
        gt_pct = sum(gt_mask) / N * 100

        ax.set_title(f'{title}\n< {lt_pct:.0f}% = {eq_pct:.0f}% > {gt_pct:.0f}%')
        ax.set_xlabel('Index i')
        ax.set_yticks([])

    blue_patch = mpatches.Patch(color='blue', alpha=0.7, label='f < g')
    green_patch = mpatches.Patch(color='green', alpha=0.7, label='f = g')
    red_patch = mpatches.Patch(color='red', alpha=0.7, label='f > g')
    fig.legend(handles=[blue_patch, green_patch, red_patch],
              loc='lower center', ncol=3, fontsize=12)

    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    plt.savefig('trichotomy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved trichotomy.png")


def plot_standard_part():
    """Visualize the standard part theorem."""
    fig, ax = plt.subplots(figsize=(12, 6))
    fig.suptitle('Standard Part Theorem: Bounded Elements are Standard',
                fontsize=14, fontweight='bold')

    N = 500
    indices = np.arange(N)
    bound = 4

    # f(i) = i mod 5 (bounded by 4)
    f_vals = indices % 5

    # Color each point by its value
    colors_map = {0: '#1f77b4', 1: '#ff7f0e', 2: '#2ca02c', 3: '#d62728', 4: '#9467bd'}
    colors = [colors_map[v] for v in f_vals]

    ax.scatter(indices, f_vals, c=colors, s=5, alpha=0.7)

    # Add horizontal lines for each standard value
    for m in range(5):
        count = sum(1 for v in f_vals if v == m)
        density = count / N
        ax.axhline(y=m, color=colors_map[m], linestyle='--', alpha=0.5)
        ax.text(N + 5, m, f'm={m}: {density:.1%}', color=colors_map[m],
               fontsize=10, va='center')

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('f(i) = i mod 5', fontsize=12)
    ax.set_title(f'f = i mod 5 (bounded by {bound})\n'
                'Ultrafilter selects exactly one value m with {{i | f(i)=m}} ∈ U',
                fontsize=11)
    ax.set_xlim(-10, N + 60)
    ax.set_ylim(-0.5, 5)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('standard_part.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved standard_part.png")


if __name__ == "__main__":
    plot_ultrapower_elements()
    plot_trichotomy()
    plot_standard_part()
    print("\nAll visualizations generated.")
