#!/usr/bin/env python3
"""
Tropical Surprise Theory — Numerical Demonstrations

Demonstrates the key theorems from the tropical surprise framework:
1. Geometric surprise decay and convergence
2. Jensen's surprise inequality
3. Entropy maximization
4. Novelty-familiarity duality
5. KL divergence non-negativity
6. Refinement increases entropy
"""

import math
from typing import List, Tuple

# ─────────────────────────────────────────────
# Demo 1: Surprise Decay and Convergence
# ─────────────────────────────────────────────

def repeated_surprise(s0: float, r: float, n: int) -> float:
    """Surprise of the n-th repetition."""
    return s0 * r ** n

def total_surprise_partial(s0: float, r: float, N: int) -> float:
    """Sum of surprise over N repetitions."""
    return sum(repeated_surprise(s0, r, n) for n in range(N))

def total_surprise_limit(s0: float, r: float) -> float:
    """Theoretical limit: s0 / (1 - r)."""
    return s0 / (1 - r)

print("=" * 60)
print("DEMO 1: Surprise Decay Under Repetition")
print("=" * 60)

s0, r = 10.0, 0.7
print(f"\nInitial surprise: {s0}, decay rate: {r}")
print(f"Theoretical total (s0/(1-r)): {total_surprise_limit(s0, r):.4f}")
print(f"\n{'N':>5} | {'Partial Sum':>12} | {'Gap to Limit':>12} | {'S(N)':>8}")
print("-" * 45)
for N in [1, 5, 10, 20, 50, 100]:
    partial = total_surprise_partial(s0, r, N)
    gap = total_surprise_limit(s0, r) - partial
    print(f"{N:>5} | {partial:>12.4f} | {gap:>12.6f} | {repeated_surprise(s0, r, N):>8.6f}")

# ─────────────────────────────────────────────
# Demo 2: Jensen's Surprise Inequality
# ─────────────────────────────────────────────

print(f"\n{'=' * 60}")
print("DEMO 2: Jensen's Surprise Inequality")
print("=" * 60)

def neg_log(p: float) -> float:
    return -math.log(p) if p > 0 else float('inf')

print(f"\nFor p=0.2, q=0.8, varying t:")
print(f"{'t':>5} | {'LHS: -log(mix)':>14} | {'RHS: t*(-logp)+(1-t)*(-logq)':>28} | {'Gap':>8}")
print("-" * 62)
p, q = 0.2, 0.8
for t in [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0]:
    mix = t * p + (1 - t) * q
    lhs = neg_log(mix)
    rhs = t * neg_log(p) + (1 - t) * neg_log(q)
    print(f"{t:>5.1f} | {lhs:>14.6f} | {rhs:>28.6f} | {rhs - lhs:>8.6f}")

# ─────────────────────────────────────────────
# Demo 3: Entropy Maximization
# ─────────────────────────────────────────────

print(f"\n{'=' * 60}")
print("DEMO 3: Entropy ≤ log(n)")
print("=" * 60)

def entropy(probs: List[float]) -> float:
    return -sum(p * math.log(p) for p in probs if p > 0)

n = 4
print(f"\nDistributions on {n} outcomes (bound = log({n}) = {math.log(n):.4f}):")
distributions = [
    ("Uniform", [1/n] * n),
    ("Peaked", [0.7, 0.1, 0.1, 0.1]),
    ("Very peaked", [0.97, 0.01, 0.01, 0.01]),
    ("Two-equal", [0.5, 0.5, 0.001, 0.001]),  # Adjusted to sum ~1
]
# Fix sums
distributions[3] = ("Two-heavy", [0.499, 0.499, 0.001, 0.001])

print(f"{'Name':>15} | {'H(p)':>8} | {'log(n)':>8} | {'Gap':>8}")
print("-" * 45)
for name, probs in distributions:
    s = sum(probs)
    probs_norm = [p / s for p in probs]
    H = entropy(probs_norm)
    print(f"{name:>15} | {H:>8.4f} | {math.log(n):>8.4f} | {math.log(n) - H:>8.4f}")

# ─────────────────────────────────────────────
# Demo 4: Novelty-Familiarity Duality
# ─────────────────────────────────────────────

print(f"\n{'=' * 60}")
print("DEMO 4: Novelty-Familiarity Bound (p·(-log p) ≤ 1/e)")
print("=" * 60)

bound = 1 / math.e
print(f"\nBound: 1/e = {bound:.6f}")
print(f"Optimal p: 1/e = {1/math.e:.6f}")
print(f"\n{'p':>8} | {'p·(-log p)':>12} | {'1/e':>8} | {'≤ 1/e?':>8}")
print("-" * 45)
for p in [0.01, 0.05, 0.1, 0.2, 1/math.e, 0.5, 0.8, 0.99]:
    val = p * (-math.log(p))
    print(f"{p:>8.4f} | {val:>12.6f} | {bound:>8.6f} | {'✓' if val <= bound + 1e-10 else '✗':>8}")

# ─────────────────────────────────────────────
# Demo 5: KL Divergence
# ─────────────────────────────────────────────

print(f"\n{'=' * 60}")
print("DEMO 5: KL Divergence Non-negativity")
print("=" * 60)

def kl_div(p: List[float], q: List[float]) -> float:
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q) if pi > 0 and qi > 0)

pairs = [
    ("Uniform vs Uniform", [1/3]*3, [1/3]*3),
    ("Peaked vs Uniform", [0.7, 0.2, 0.1], [1/3]*3),
    ("Uniform vs Peaked", [1/3]*3, [0.7, 0.2, 0.1]),
    ("Very different", [0.9, 0.05, 0.05], [0.1, 0.45, 0.45]),
]

print(f"\n{'Description':>25} | {'D_KL(p||q)':>12} | {'≥ 0?':>6}")
print("-" * 50)
for name, p, q in pairs:
    d = kl_div(p, q)
    print(f"{name:>25} | {d:>12.6f} | {'✓' if d >= -1e-10 else '✗':>6}")

# ─────────────────────────────────────────────
# Demo 6: Refinement Increases Entropy
# ─────────────────────────────────────────────

print(f"\n{'=' * 60}")
print("DEMO 6: Refinement Increases Entropy")
print("=" * 60)

print(f"\nSplitting p = p₁ + p₂ increases entropy contribution:")
print(f"{'p':>6} | {'p₁':>6} | {'p₂':>6} | {'-p·log(p)':>12} | {'-p₁·log(p₁)-p₂·log(p₂)':>24} | {'Increase':>8}")
print("-" * 70)
splits = [
    (0.5, 0.25, 0.25),
    (0.5, 0.4, 0.1),
    (0.5, 0.49, 0.01),
    (0.8, 0.4, 0.4),
    (0.8, 0.7, 0.1),
]
for p_val, p1, p2 in splits:
    before = -p_val * math.log(p_val)
    after = -p1 * math.log(p1) - p2 * math.log(p2)
    print(f"{p_val:>6.2f} | {p1:>6.2f} | {p2:>6.2f} | {before:>12.6f} | {after:>24.6f} | {after - before:>8.6f}")

# ─────────────────────────────────────────────
# Demo 7: Tropical Max-Plus Structure
# ─────────────────────────────────────────────

print(f"\n{'=' * 60}")
print("DEMO 7: Tropical Distributivity and Surprise Dominance")
print("=" * 60)

print(f"\nMax-Plus Distributivity: max(a,b) + c = max(a+c, b+c)")
test_cases = [(3, 7, 2), (5, 5, 1), (-1, 4, 3)]
for a, b, c in test_cases:
    lhs = max(a, b) + c
    rhs = max(a + c, b + c)
    print(f"  max({a},{b}) + {c} = {lhs} = max({a+c},{b+c}) = {rhs}  {'✓' if lhs == rhs else '✗'}")

print(f"\nSurprise Dominance: max(a,b) ≥ (a+b)/2")
for a, b in [(1, 9), (5, 5), (0, 100), (3, 7)]:
    print(f"  max({a},{b}) = {max(a,b)} ≥ ({a}+{b})/2 = {(a+b)/2}  {'✓' if max(a,b) >= (a+b)/2 else '✗'}")

print(f"\n{'=' * 60}")
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Entropy Landscape and Jensen's Inequality

Shows entropy maximization on simplices and Jensen's inequality for -log.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: -log(p) is convex
p = np.linspace(0.01, 2.0, 500)
neg_log = -np.log(p)

# Show Jensen's inequality graphically
p1, p2 = 0.2, 1.5
t_vals = np.linspace(0, 1, 100)
mix = np.outer(t_vals, [p1]) + np.outer(1 - t_vals, [p2])
chord_y = np.outer(t_vals, [-np.log(p1)]) + np.outer(1 - t_vals, [-np.log(p2)])
curve_y = -np.log(mix)

axes[0].plot(p, neg_log, 'b-', linewidth=2, label='-log(p)')
axes[0].plot([p1, p2], [-np.log(p1), -np.log(p2)], 'r--', linewidth=2, label='Chord')
axes[0].fill_between(mix.flatten(), curve_y.flatten(), chord_y.flatten(),
                      alpha=0.2, color='red', label='Jensen gap')
axes[0].plot([p1], [-np.log(p1)], 'ko', markersize=8)
axes[0].plot([p2], [-np.log(p2)], 'ko', markersize=8)
axes[0].set_xlabel('p')
axes[0].set_ylabel('-log(p)')
axes[0].set_title("Jensen's Inequality: -log is convex")
axes[0].legend()
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-1.5, 5)

# Panel 2: Entropy on the 2-simplex
n_points = 200
p_range = np.linspace(0.001, 0.999, n_points)
H = np.array([-p * np.log(p) - (1-p) * np.log(1-p) for p in p_range])

axes[1].plot(p_range, H, 'b-', linewidth=2)
axes[1].axhline(y=np.log(2), color='r', linestyle='--', label=f'log(2) ≈ {np.log(2):.3f}')
axes[1].axvline(x=0.5, color='g', linestyle=':', alpha=0.5, label='p = 0.5 (uniform)')
axes[1].set_xlabel('p (probability of outcome 1)')
axes[1].set_ylabel('H(p, 1-p)')
axes[1].set_title('Binary Entropy: H ≤ log(2)')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Panel 3: KL divergence from uniform
# D_KL(p || uniform) for binary distributions
q_uniform = 0.5
kl_vals = np.array([
    p * np.log(p / q_uniform) + (1-p) * np.log((1-p) / (1-q_uniform))
    for p in p_range
])

axes[2].plot(p_range, kl_vals, 'b-', linewidth=2, label='D_KL(p || uniform)')
axes[2].axhline(y=0, color='r', linestyle='--', alpha=0.5, label='D_KL ≥ 0')
axes[2].fill_between(p_range, 0, kl_vals, alpha=0.1, color='blue')
axes[2].set_xlabel('p')
axes[2].set_ylabel('D_KL(p || uniform)')
axes[2].set_title("KL Divergence ≥ 0 (Gibbs' Inequality)")
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: entropy_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Surprise Spectrum and Tropical Structure

Shows the surprise spectrum, spectral bounds, and tropical operations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Surprise Spectrum
outcomes = ['A', 'B', 'C', 'D', 'E', 'F']
weights = [2.0, 5.0, 1.5, 8.0, 3.0, 4.5]
n = len(weights)
max_w = max(weights)
total_w = sum(weights)

colors = ['#ff6b6b' if w == max_w else '#4ecdc4' for w in weights]
bars = axes[0].bar(outcomes, weights, color=colors, edgecolor='black', linewidth=0.5)
axes[0].axhline(y=max_w, color='red', linestyle='--', linewidth=2,
                label=f'Max (tropical ⊕) = {max_w}')
axes[0].axhline(y=total_w/n, color='blue', linestyle=':', linewidth=2,
                label=f'Average = {total_w/n:.1f}')
axes[0].set_ylabel('Surprise Weight')
axes[0].set_title('Surprise Spectrum')
axes[0].legend()
axes[0].grid(True, alpha=0.3, axis='y')

# Panel 2: Spectral Bound
n_vals = np.arange(2, 15)
# For different max/total ratios
for ratio_label, ratio in [('Uniform', 1.0), ('Moderate', 0.5), ('Peaked', 0.2)]:
    # total = n * max * ratio
    totals = n_vals * ratio
    axes[1].plot(n_vals, totals, 'o-', label=f'Spectral ratio = {ratio}', markersize=5)

axes[1].plot(n_vals, n_vals * 1.0, 'k--', alpha=0.3, label='Upper bound: n × max')
axes[1].set_xlabel('Number of Outcomes (n)')
axes[1].set_ylabel('Total / Max')
axes[1].set_title('Spectral Bound: Total ≤ n × Max')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Panel 3: Tropical max-plus operations
# Show that max(a,b) + c = max(a+c, b+c)
a_vals = np.linspace(-2, 5, 100)
b = 3.0
c = 2.0

max_then_add = np.maximum(a_vals, b) + c
add_then_max = np.maximum(a_vals + c, b + c)

axes[2].plot(a_vals, max_then_add, 'b-', linewidth=3, label='max(a,b) + c')
axes[2].plot(a_vals, add_then_max, 'r--', linewidth=2, label='max(a+c, b+c)')
axes[2].axvline(x=b, color='gray', linestyle=':', alpha=0.5, label=f'a = b = {b}')
axes[2].set_xlabel('a')
axes[2].set_ylabel('Value')
axes[2].set_title(f'Tropical Distributivity (b={b}, c={c})')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectrum_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: spectrum_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Surprise Decay Under Repetition

Shows geometric decay of surprise and convergence of total lifetime surprise.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def repeated_surprise(s0: float, r: float, n: np.ndarray) -> np.ndarray:
    return s0 * r ** n

def total_surprise_limit(s0: float, r: float) -> float:
    return s0 / (1 - r)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Surprise decay for different rates
n = np.arange(0, 20)
rates = [0.3, 0.5, 0.7, 0.9]
s0 = 10.0

for r in rates:
    axes[0].plot(n, repeated_surprise(s0, r, n), 'o-', label=f'r = {r}', markersize=4)
axes[0].set_xlabel('Repetition n')
axes[0].set_ylabel('Surprise s(n)')
axes[0].set_title('Surprise Decay: s₀·rⁿ')
axes[0].legend()
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Panel 2: Cumulative surprise convergence
for r in rates:
    cumsum = np.cumsum(repeated_surprise(s0, r, n))
    limit = total_surprise_limit(s0, r)
    axes[1].plot(n, cumsum, 'o-', label=f'r={r}, limit={limit:.1f}', markersize=4)
    axes[1].axhline(y=limit, color='gray', linestyle='--', alpha=0.3)
axes[1].set_xlabel('Number of Repetitions N')
axes[1].set_ylabel('Cumulative Surprise')
axes[1].set_title('Total Lifetime Surprise → s₀/(1-r)')
axes[1].legend(fontsize=8)
axes[1].grid(True, alpha=0.3)

# Panel 3: Novelty-familiarity product
p = np.linspace(0.001, 1.0, 500)
nf_product = p * (-np.log(p))
bound = 1 / np.e

axes[2].plot(p, nf_product, 'b-', linewidth=2, label='p·(-log p)')
axes[2].axhline(y=bound, color='r', linestyle='--', label=f'1/e ≈ {bound:.4f}')
axes[2].axvline(x=1/np.e, color='g', linestyle=':', alpha=0.5, label=f'p* = 1/e ≈ {1/np.e:.4f}')
axes[2].fill_between(p, nf_product, bound, where=nf_product <= bound, alpha=0.1, color='blue')
axes[2].set_xlabel('Probability p')
axes[2].set_ylabel('Impact p·(-log p)')
axes[2].set_title('Novelty-Familiarity Duality')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('surprise_decay_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: surprise_decay_visualization.png")
