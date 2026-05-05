#!/usr/bin/env python3
"""
Tropical Riesz Representation Theorem: Interactive Demo

This script demonstrates the discrete tropical Riesz representation theorem:
every max-plus linear functional on functions over a finite set is uniquely
represented as a tropical integral against a weight function.

In the max-plus algebra (ℝ ∪ {-∞}, max, +):
- "addition" is max
- "multiplication" is +
- The zero element is -∞
- The unit element is 0

The Riesz theorem says: for any functional Λ satisfying
  Λ(f ∨ g) = Λ(f) ∨ Λ(g)     (preserves sup)
  Λ(c + f) = c + Λ(f)          (commutes with translation)
  Λ(const c) = c                (normalizes constants)

there exists a unique weight w : X → ℝ ∪ {-∞} such that
  Λ(f) = max_x (w(x) + f(x))

This is the tropical analogue of: every positive linear functional is integration
against a measure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product

# Represent -∞ as a very large negative number
NEG_INF = float('-inf')


def trop_add(a, b):
    """Tropical addition = max."""
    return max(a, b)


def trop_mult(a, b):
    """Tropical multiplication = ordinary addition."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b


def trop_integral(w, f):
    """
    Tropical integral: max_x (w(x) + f(x)).
    
    This is the Shilkret integral in the max-plus semiring.
    Classical analogue: ∫ f dμ = Σ_x μ(x) · f(x)
    Tropical analogue:  ∫ᵗ f dw = max_x (w(x) + f(x))
    """
    return max(trop_mult(w[i], f[i]) for i in range(len(w)))


def delta_weight(Lambda, n, x):
    """
    Extract the weight at point x from functional Λ.
    
    w(x) = Λ(δ_x) where δ_x(y) = 0 if y=x, -∞ otherwise.
    
    This is the tropical analogue of: μ({x}) = Λ(1_{x}).
    """
    basis = [0.0 if i == x else NEG_INF for i in range(n)]
    return Lambda(basis)


def verify_representation(Lambda, n, num_tests=1000):
    """
    Verify the tropical Riesz representation theorem numerically.
    
    Extracts the weight function w and checks that
    Λ(f) = max_x (w(x) + f(x)) for random functions f.
    """
    w = [delta_weight(Lambda, n, x) for x in range(n)]
    
    errors = []
    for _ in range(num_tests):
        f = []
        for i in range(n):
            if np.random.random() < 0.1:
                f.append(NEG_INF)
            else:
                f.append(np.random.uniform(-10, 10))
        
        lhs = Lambda(f)
        rhs = trop_integral(w, f)
        
        if lhs == NEG_INF and rhs == NEG_INF:
            continue
        if lhs == NEG_INF or rhs == NEG_INF:
            errors.append(float('inf'))
        else:
            errors.append(abs(lhs - rhs))
    
    return w, max(errors) if errors else 0.0


# ============================================================
# DEMO 1: Explicit evaluation functional
# ============================================================
print("=" * 70)
print("DEMO 1: Evaluation Functional (Tropical Dirac Delta)")
print("=" * 70)
print()

n = 5
x0 = 2

def eval_functional(f, x0=x0):
    """Λ(f) = f(x₀): evaluation at point x₀."""
    return f[x0]

w_eval, err_eval = verify_representation(eval_functional, n)
print(f"Space: X = {{0, 1, 2, 3, 4}}")
print(f"Functional: Λ(f) = f({x0})")
print(f"Recovered weights: w = {w_eval}")
print(f"Expected weights:  w = {[NEG_INF if i != x0 else 0.0 for i in range(n)]}")
print(f"Max error over 1000 random tests: {err_eval:.2e}")
print(f"Interpretation: w(x) = 0 at x={x0}, w(x) = -∞ elsewhere")
print(f"  → The tropical Dirac measure at x={x0}")
print()

# ============================================================
# DEMO 2: Weighted max functional
# ============================================================
print("=" * 70)
print("DEMO 2: Weighted Maximum Functional")
print("=" * 70)
print()

weights = [1.0, -2.0, 3.0, 0.5, NEG_INF]

def weighted_max_functional(f, w=weights):
    return trop_integral(w, f)

w_recovered, err_weighted = verify_representation(weighted_max_functional, n)
print(f"Original weights:  w = {weights}")
print(f"Recovered weights: w = {w_recovered}")
print(f"Max error: {err_weighted:.2e}")
print()

# ============================================================
# DEMO 3: Verifying the axioms
# ============================================================
print("=" * 70)
print("DEMO 3: Verifying Tropical Linearity Axioms")
print("=" * 70)
print()

# Note: For Λ(const c) = c, we need max(w) = 0 (normalization).
w_test = [0.0, -3.0, -2.0, -0.5]
n_test = 4

def Lambda(f, w=w_test):
    return trop_integral(w, f)

print("Axiom 1: Λ(f ∨ g) = Λ(f) ∨ Λ(g)")
for trial in range(5):
    f = [np.random.uniform(-5, 5) for _ in range(n_test)]
    g = [np.random.uniform(-5, 5) for _ in range(n_test)]
    f_sup_g = [max(f[i], g[i]) for i in range(n_test)]
    lhs = Lambda(f_sup_g)
    rhs = max(Lambda(f), Lambda(g))
    print(f"  Trial {trial+1}: Λ(f∨g) = {lhs:.4f}, Λ(f)∨Λ(g) = {rhs:.4f}, "
          f"equal: {abs(lhs-rhs) < 1e-10}")

print()
print("Axiom 2: Λ(c + f) = c + Λ(f)")
for trial in range(5):
    f = [np.random.uniform(-5, 5) for _ in range(n_test)]
    c = np.random.uniform(-3, 3)
    cf = [c + f[i] for i in range(n_test)]
    lhs = Lambda(cf)
    rhs = c + Lambda(f)
    print(f"  Trial {trial+1}: c={c:.2f}, Λ(c+f) = {lhs:.4f}, c+Λ(f) = {rhs:.4f}, "
          f"equal: {abs(lhs-rhs) < 1e-10}")

print()
print("Axiom 3: Λ(const c) = c")
for c in [-3.0, 0.0, 2.5, 7.0]:
    f_const = [c] * n_test
    result = Lambda(f_const)
    print(f"  c = {c:.1f}: Λ(const {c:.1f}) = {result:.4f}, equal: {abs(result-c) < 1e-10}")

# ============================================================
# DEMO 4: Tropical basis decomposition
# ============================================================
print()
print("=" * 70)
print("DEMO 4: Tropical Basis Decomposition")
print("=" * 70)
print()

f_example = [3.0, -1.0, 2.0, 5.0]
print(f"Function f = {f_example}")
print(f"Decomposition: f(y) = max_x (f(x) + δ_x(y))")
print()
for y in range(n_test):
    terms = []
    for x in range(n_test):
        delta_val = 0.0 if y == x else NEG_INF
        term = trop_mult(f_example[x], delta_val)
        terms.append(term)
    result = max(terms)
    print(f"  f({y}) = max over x of (f(x) + δ_x({y})) = {result:.1f} = f({y}) ✓"
          if abs(result - f_example[y]) < 1e-10
          else f"  f({y}) = {result:.1f} ✗")

# ============================================================
# DEMO 5: Uniqueness
# ============================================================
print()
print("=" * 70)
print("DEMO 5: Uniqueness of Representation")
print("=" * 70)
print()

w_original = [1.0, 2.0, -1.0]
n_small = 3
grid = np.arange(-3, 4, 0.5)
found_alternatives = 0

for w0, w1, w2 in product(grid, grid, grid):
    w_candidate = [w0, w1, w2]
    if all(abs(a - b) < 1e-10 for a, b in zip(w_candidate, w_original)):
        continue
    
    same = True
    for _ in range(100):
        f_test = [np.random.uniform(-5, 5) for _ in range(n_small)]
        if abs(trop_integral(w_original, f_test) - trop_integral(w_candidate, f_test)) > 1e-8:
            same = False
            break
    
    if same:
        found_alternatives += 1

print(f"Original weights: w = {w_original}")
print(f"Searched {len(grid)**3:.0f} candidate weight vectors")
print(f"Alternative representations found: {found_alternatives}")
print(f"Uniqueness confirmed: {'YES' if found_alternatives == 0 else 'NO'}")

# ============================================================
# DEMO 6: Application to shortest paths / DP
# ============================================================
print()
print("=" * 70)
print("DEMO 6: Application — Recovering Hidden Costs from an Oracle")
print("=" * 70)
print()

n_nodes = 4
costs = [3.0, 1.0, 4.0, 2.0]

def min_plus_functional(f, c=costs):
    """Min-plus functional: Λ(f) = min_x (c(x) + f(x))."""
    return min(c[i] + f[i] for i in range(len(c)))

recovered_costs = []
for x in range(n_nodes):
    indicator = [0.0 if i == x else 1e10 for i in range(n_nodes)]
    recovered_costs.append(min_plus_functional(indicator))

print(f"Hidden node costs:    {costs}")
print(f"Recovered from oracle: {recovered_costs}")
print(f"Exact recovery: {all(abs(a-b) < 1e-6 for a, b in zip(costs, recovered_costs))}")
print()
print("The tropical Riesz theorem guarantees that ANY min-plus linear oracle")
print("can have its internal weights uniquely recovered by probing with")
print("indicator functions. This is algorithmic tropical inference!")

# ============================================================
# VISUALIZATION
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Tropical Riesz Representation Theorem', fontsize=16, fontweight='bold')

# Plot 1: Tropical basis functions
ax = axes[0, 0]
n_vis = 5
for x0_vis in range(n_vis):
    basis = [0 if i == x0_vis else -5 for i in range(n_vis)]
    ax.bar([i + x0_vis * 0.15 - 0.3 for i in range(n_vis)], basis, width=0.12,
           label=f'δ_{x0_vis}', alpha=0.7)
ax.set_xlabel('y')
ax.set_ylabel('δ_x(y)')
ax.set_title('Tropical Basis Functions (Dirac Deltas)')
ax.legend(fontsize=8)
ax.set_xticks(range(n_vis))
ax.set_ylim(-6, 1)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

# Plot 2: Weight recovery
ax = axes[0, 1]
true_weights = [2.0, -1.0, 3.0, 0.5, 1.0]
n_rec = len(true_weights)
def Lambda_rec(f, w=true_weights):
    return trop_integral(w, f)
recovered = [delta_weight(Lambda_rec, n_rec, x) for x in range(n_rec)]
x_pos = np.arange(n_rec)
width = 0.35
ax.bar(x_pos - width/2, true_weights, width, label='True weights', color='steelblue')
ax.bar(x_pos + width/2, recovered, width, label='Recovered weights', color='coral')
ax.set_xlabel('Point x')
ax.set_ylabel('Weight w(x)')
ax.set_title('Weight Recovery: w(x) = Λ(δ_x)')
ax.legend()
ax.set_xticks(x_pos)

# Plot 3: Representation formula
ax = axes[1, 0]
f_vis = [3.0, -1.0, 2.0, 5.0, 0.0]
w_vis = [1.0, 2.0, -0.5, 0.0, 3.0]
n_v = len(f_vis)
contributions = [w_vis[x] + f_vis[x] for x in range(n_v)]
colors = ['lightcoral' if c < max(contributions) else 'forestgreen' for c in contributions]
ax.bar(range(n_v), contributions, color=colors, alpha=0.7, edgecolor='black')
ax.axhline(y=max(contributions), color='red', linestyle='--', linewidth=2,
           label=f'Λ(f) = max = {max(contributions):.1f}')
ax.set_xlabel('Point x')
ax.set_ylabel('w(x) + f(x)')
ax.set_title('Tropical Integral: Λ(f) = max_x (w(x) + f(x))')
ax.legend()
ax.set_xticks(range(n_v))

# Plot 4: Classical vs tropical comparison table
ax = axes[1, 1]
table_text = [
    ['', 'Classical', 'Tropical'],
    ['⊕ (add)', 'Sum (+)', 'Max (∨)'],
    ['⊗ (mult)', 'Product (·)', 'Plus (+)'],
    ['Zero', '0', '-∞'],
    ['One', '1', '0'],
    ['Functional', 'Σ μ(x)·f(x)', 'max(w(x)+f(x))'],
    ['Repr.', 'Measure μ≥0', 'Weight w∈ℝ∪{-∞}'],
]
ax.axis('off')
table = ax.table(cellText=table_text, loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1, 1.5)
for i in range(len(table_text)):
    for j in range(3):
        cell = table[i, j]
        if i == 0:
            cell.set_facecolor('#4472C4')
            cell.set_text_props(color='white', fontweight='bold')
        elif j == 0:
            cell.set_facecolor('#D6E4F0')
            cell.set_text_props(fontweight='bold')
        else:
            cell.set_facecolor('#F2F2F2' if i % 2 == 0 else 'white')
ax.set_title('Classical vs Tropical Riesz Theorem', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig('demos/tropical_riesz_visualization.png', dpi=150, bbox_inches='tight')
print()
print("Visualization saved to demos/tropical_riesz_visualization.png")
