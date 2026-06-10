#!/usr/bin/env python3
"""
Demonstration of the Lawvere Metric Coding Theorem for Proof Semirings.

This script illustrates the key theorems proved in Lean:
1. Binary Kraft inequality for prefix-free codes
2. Gibbs variational free-energy bound
3. Lawvere proof coding theorem

We show concrete numerical examples, visualize the Kraft budget,
and demonstrate the variational bound with the Gibbs optimum.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product

# ============================================================
# Part 1: Prefix-Free Codes and the Kraft Inequality
# ============================================================

def is_prefix(u, v):
    """Check if u is a prefix of v."""
    return len(u) <= len(v) and v[:len(u)] == u

def is_prefix_free(code):
    """Check if a set of codewords is prefix-free."""
    for i, u in enumerate(code):
        for j, v in enumerate(code):
            if i != j and is_prefix(u, v):
                return False
    return True

def kraft_weight(w):
    return 2.0 ** (-len(w))

def kraft_sum(code):
    return sum(kraft_weight(w) for w in code)

def all_binary_words(n):
    if n == 0:
        return [[]]
    return [list(bits) for bits in product([False, True], repeat=n)]

def extensions_to_length(w, N):
    return [v for v in all_binary_words(N) if is_prefix(w, v)]

print("=" * 70)
print("DEMO 1: Binary Kraft Inequality for Prefix-Free Codes")
print("=" * 70)

codes = [
    ("Complete {00,01,10,11}", [[0,0],[0,1],[1,0],[1,1]]),
    ("{0, 10, 11}", [[0],[1,0],[1,1]]),
    ("{0, 10, 110, 111}", [[0],[1,0],[1,1,0],[1,1,1]]),
    ("{000, 111}", [[0,0,0],[1,1,1]]),
]

for name, code in codes:
    ks = kraft_sum(code)
    pf = is_prefix_free(code)
    print(f"\n  {name}")
    print(f"    Prefix-free: {pf}    Kraft sum: {ks:.4f}  {'≤ 1 ✓' if ks <= 1.001 else '> 1 ✗'}")

# Demo 2: Counting extensions
print("\n" + "=" * 70)
print("DEMO 2: Disjoint Extensions — The Combinatorial Heart")
print("=" * 70)

N = 4
code = [[0],[1,0],[1,1]]
print(f"\nCode: {{0, 10, 11}}, extending to depth N={N}")
for w in code:
    ext = extensions_to_length(w, N)
    w_str = ''.join(str(b) for b in w)
    print(f"  Extensions of '{w_str}': {len(ext)} words = 2^({N}-{len(w)}) = {2**(N-len(w))}")

ext_sets = [set(tuple(v) for v in extensions_to_length(w, N)) for w in code]
for i in range(len(code)):
    for j in range(i+1, len(code)):
        overlap = ext_sets[i] & ext_sets[j]
        wi = ''.join(str(b) for b in code[i])
        wj = ''.join(str(b) for b in code[j])
        print(f"  '{wi}' ∩ '{wj}': {len(overlap)} words (disjoint!)")

total = sum(len(s) for s in ext_sets)
print(f"  Total: {total} ≤ 2^{N} = {2**N}  →  Kraft sum = {total/2**N} ≤ 1  ✓")

# ============================================================
# Part 2: Gibbs Variational Free-Energy Bound
# ============================================================

def entropy(p):
    return -sum(pi * np.log(pi) for pi in p if pi > 0)

def expected_cost(p, c):
    return np.dot(p, c)

def free_energy_obj(beta, p, c):
    return -beta * expected_cost(p, c) + entropy(p)

def log_partition(beta, c):
    return np.log(np.sum(np.exp(-beta * c)))

def gibbs_dist(beta, c):
    w = np.exp(-beta * c)
    return w / w.sum()

print("\n" + "=" * 70)
print("DEMO 3: Gibbs Variational Free-Energy Bound")
print("=" * 70)

costs = np.array([1.0, 2.0, 3.0, 5.0])
beta = np.log(2)
lz = log_partition(beta, costs)

print(f"\nCosts: {costs},  β = log 2 = {beta:.4f}")
print(f"\n{'Distribution':<25} {'F(p)':>10} {'log Z':>10} {'Gap':>10}")
print("-" * 58)

for name, p in [("Uniform", np.ones(4)/4),
                ("Concentrated", np.array([1,0,0,0], dtype=float)),
                ("Gibbs (optimal)", gibbs_dist(beta, costs))]:
    fe = free_energy_obj(beta, p, costs)
    print(f"{name:<25} {fe:>10.4f} {lz:>10.4f} {lz-fe:>10.4f}")

print(f"\nTheorem: F(p) ≤ log Z for ALL distributions p  ✓")

# ============================================================
# Part 3: Visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Kraft budget
ax = axes[0, 0]
names_plot = [c[0] for c in codes]
sums_plot = [kraft_sum(c[1]) for c in codes]
colors = ['#2ecc71' if s <= 1.001 else '#e74c3c' for s in sums_plot]
bars = ax.barh(names_plot, sums_plot, color=colors, edgecolor='black', alpha=0.8)
ax.axvline(x=1, color='red', linestyle='--', linewidth=2, label='Kraft bound = 1')
ax.set_xlabel('Kraft Sum  Σ 2^{-|w|}')
ax.set_title('Kraft Inequality: Prefix-Free Code Budgets')
ax.legend()
for bar, s in zip(bars, sums_plot):
    ax.text(bar.get_width() + 0.02, bar.get_y() + bar.get_height()/2,
            f'{s:.3f}', va='center', fontweight='bold')

# Plot 2: Free energy landscape
ax = axes[0, 1]
betas = np.linspace(0.01, 3.0, 200)
costs_plot = np.array([1.0, 2.0, 3.0, 5.0])
log_Z_vals = [log_partition(b, costs_plot) for b in betas]
for name, p in [("Uniform", np.ones(4)/4),
                ("Concentrated", np.array([0.7, 0.2, 0.08, 0.02]))]:
    fe_vals = [free_energy_obj(b, p, costs_plot) for b in betas]
    ax.plot(betas, fe_vals, '--', label=f'F({name})', alpha=0.7)
ax.plot(betas, log_Z_vals, 'k-', linewidth=2.5, label='log Z(β) (upper bound)')
ax.fill_between(betas, log_Z_vals, min(min(log_Z_vals), -5), alpha=0.1, color='green')
ax.set_xlabel('Inverse temperature β')
ax.set_ylabel('Free energy / log partition')
ax.set_title('Gibbs Variational Bound: F(p) ≤ log Z(β)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 3: Kraft = Free energy
ax = axes[1, 0]
lengths = np.arange(1, 9)
kw = 2.0 ** (-lengths)
ew = np.exp(-np.log(2) * lengths)
ax.bar(lengths - 0.15, kw, 0.3, label='2^{-n} (Kraft)', color='#3498db', alpha=0.8)
ax.bar(lengths + 0.15, ew, 0.3, label='exp(-n·log 2) (free energy)', color='#e74c3c', alpha=0.8)
ax.set_xlabel('Codeword length n')
ax.set_ylabel('Weight')
ax.set_title('Kraft ↔ Free Energy: 2^{-n} = exp(-n·log 2)')
ax.legend()
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Plot 4: Gibbs distribution
ax = axes[1, 1]
betas_gibbs = [0.1, 0.5, np.log(2), 1.5, 3.0]
for b in betas_gibbs:
    g = gibbs_dist(b, costs_plot)
    ax.plot(range(len(costs_plot)), g, 'o-', label=f'β={b:.2f}', alpha=0.8)
ax.set_xlabel('Proof object index')
ax.set_ylabel('Probability')
ax.set_title('Gibbs Distribution at Various Temperatures')
ax.set_xticks(range(len(costs_plot)))
ax.set_xticklabels([f'c={c:.0f}' for c in costs_plot])
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/kraft_coding_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("\n✓ Visualization saved to demos/kraft_coding_visualization.png")

# ============================================================
# Part 4: Capacity bound demo
# ============================================================

print("\n" + "=" * 70)
print("DEMO 4: Lawvere Capacity Bound — Compression Limits")
print("=" * 70)

proof_names = ["Axiom", "MP", "∧-intro", "∨-elim", "∀-inst", "∃-elim"]
proof_costs = np.array([1.0, 3.0, 3.0, 3.0, 4.0, 4.0])
beta_log2 = np.log(2)
gibbs_p = gibbs_dist(beta_log2, proof_costs)
lz = log_partition(beta_log2, proof_costs)

print(f"\nCapacity bound: H(p) - log(2)·E[length] ≤ log Z = {lz:.4f}")
print(f"\n{'Distribution':<22} {'H(p)':>8} {'E[len]':>8} {'H-log2·E':>10} {'Gap':>8}")
print("-" * 58)
for name, p in [("Uniform", np.ones(6)/6),
                ("Favor short", np.array([0.5, 0.15, 0.15, 0.1, 0.05, 0.05])),
                ("Gibbs optimal", gibbs_p)]:
    h = entropy(p)
    ec = expected_cost(p, proof_costs)
    obj = h - beta_log2 * ec
    print(f"{name:<22} {h:>8.4f} {ec:>8.4f} {obj:>10.4f} {lz-obj:>8.4f}")

print(f"\n→ Gap ≥ 0 always (our theorem!)")
print(f"→ This is the proof-theoretic source coding theorem")
print("\n" + "=" * 70)
print("All demos complete.")
print("=" * 70)
