#!/usr/bin/env python3
"""
Applications of Tropical Polynomial Canonicalization

Demonstrates real-world applications:
1. Shortest-path state compression
2. ReLU neural network simplification
3. Scheduling optimization
"""

import numpy as np
from typing import List, Tuple


class TropMono:
    def __init__(self, exp: int, coeff: float):
        self.exp = exp
        self.coeff = coeff
    def eval(self, x: float) -> float:
        return self.coeff + self.exp * x
    def __repr__(self):
        return f"({self.exp}, {self.coeff:.1f})"


def nat_canonical(monomials: List[TropMono]) -> List[TropMono]:
    """Compute Pareto-canonical form."""
    result = []
    for m in monomials:
        dominated = any(m2 is not m and m2.exp <= m.exp and m2.coeff <= m.coeff
                       for m2 in monomials)
        if not dominated:
            result.append(m)
    return sorted(result, key=lambda m: m.exp)


def trop_eval(monos: List[TropMono], x: float) -> float:
    return min(m.eval(x) for m in monos)


# =============================================================================
# Application 1: Shortest-Path State Compression
# =============================================================================
print("=" * 70)
print("APPLICATION 1: Shortest-Path Network Compression")
print("=" * 70)

print("""
In shortest-path problems, the cost of reaching a destination via k intermediate
hops from source i is: cost(i, k) = c_i + r_i * k, where c_i is the initial
cost from source i and r_i is the per-hop cost.

The optimal cost after k hops: min_i (c_i + r_i * k) — a tropical polynomial!
Canonicalization removes sources that are never optimal, compressing the network.
""")

# Simulate a network with redundant paths
sources = [
    TropMono(2, 0),    # Fast route: 2 cost/hop, 0 initial
    TropMono(1, 5),    # Medium route: 1 cost/hop, 5 initial
    TropMono(3, -1),   # Expensive route: 3 cost/hop, -1 initial
    TropMono(1, 8),    # Dominated medium route
    TropMono(0, 15),   # Direct route: 0 cost/hop, 15 initial
    TropMono(4, -5),   # Very expensive but cheap start
]

print(f"Network routes (rate, initial_cost):")
for s in sources:
    print(f"  Route {s}: cost(k) = {s.coeff:.0f} + {s.exp}·k")

canonical_sources = nat_canonical(sources)
print(f"\nCanonical routes ({len(canonical_sources)}/{len(sources)}):")
for s in canonical_sources:
    print(f"  Route {s}: cost(k) = {s.coeff:.0f} + {s.exp}·k")

print(f"\nOptimal cost comparison:")
for k in [0, 1, 2, 5, 10, 20]:
    full = trop_eval(sources, k)
    compressed = trop_eval(canonical_sources, k)
    print(f"  k={k:2d}: full={full:.0f}, compressed={compressed:.0f}, "
          f"match={'✓' if abs(full-compressed)<1e-10 else '✗'}")


# =============================================================================
# Application 2: ReLU Network Simplification
# =============================================================================
print("\n" + "=" * 70)
print("APPLICATION 2: ReLU Network Tropical Interpretation")
print("=" * 70)

print("""
A single-layer ReLU network computes:
  f(x) = min(max(w₁x + b₁, 0), max(w₂x + b₂, 0), ...) [with appropriate signs]

In the tropical limit, this becomes a min of affine functions.
Canonicalization identifies the essential neurons (decision templates).
""")

# Simulated ReLU network output as tropical polynomial
neurons = [
    TropMono(0, 8),     # Constant neuron (bias unit)
    TropMono(1, 3),     # Linear neuron: 3 + x
    TropMono(2, 0),     # Quadratic-rate neuron: 2x
    TropMono(1, 4),     # Redundant: dominated by (1, 3)
    TropMono(3, -2),    # High-rate neuron: -2 + 3x
    TropMono(2, 1),     # Redundant: dominated by (2, 0)
]

print(f"Network neurons: {len(neurons)}")
canonical_neurons = nat_canonical(neurons)
print(f"Essential neurons (after canonicalization): {len(canonical_neurons)}")
print(f"Pruned neurons: {len(neurons) - len(canonical_neurons)}")

for n in canonical_neurons:
    print(f"  Essential: output = {n.coeff:.0f} + {n.exp}·input")


# =============================================================================
# Application 3: Scheduling with Multiple Machines
# =============================================================================
print("\n" + "=" * 70)
print("APPLICATION 3: Multi-Machine Scheduling Optimization")
print("=" * 70)

print("""
Consider scheduling n identical jobs on different machines, where machine i
has setup cost s_i and per-job processing cost p_i.
Total cost on machine i for n jobs: s_i + p_i · n — a tropical monomial.
The optimal cost: min_i(s_i + p_i · n) — a tropical polynomial.
""")

machines = [
    TropMono(5, 0),     # Fast machine: 0 setup, 5/job
    TropMono(2, 10),    # Medium machine: 10 setup, 2/job
    TropMono(1, 20),    # Slow but cheap: 20 setup, 1/job
    TropMono(3, 8),     # Dominated by medium
    TropMono(0, 50),    # Free per-job but expensive setup
    TropMono(4, 3),     # Slightly dominated
]

print(f"Available machines:")
for m in machines:
    print(f"  Machine (rate={m.exp}, setup={m.coeff:.0f}): "
          f"cost(n) = {m.coeff:.0f} + {m.exp}n")

essential = nat_canonical(machines)
print(f"\nEssential machines ({len(essential)}/{len(machines)}):")
for m in essential:
    print(f"  Machine (rate={m.exp}, setup={m.coeff:.0f})")

print(f"\nOptimal scheduling decisions:")
for n in [0, 1, 2, 3, 5, 10, 20, 50]:
    cost = trop_eval(essential, n)
    best = min(essential, key=lambda m: m.eval(n))
    print(f"  n={n:2d} jobs: cost={cost:.0f} "
          f"(use machine rate={best.exp}, setup={best.coeff:.0f})")

print("\n" + "=" * 70)
print("All applications demonstrated successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Polynomial Canonicalization and Automata Minimization — Demo

Demonstrates the key theorems with concrete numerical examples:
1. Dominance characterization
2. Canonical form computation
3. Language preservation
4. Pareto structure of canonical monomials
5. Residual analysis and Nerode equivalence classes
"""

import numpy as np
from typing import List, Tuple, Set, Dict


# =============================================================================
# Core Data Structures
# =============================================================================

class TropMono:
    """A tropical monomial c + e·x in one variable."""
    def __init__(self, exp: int, coeff: float):
        self.exp = exp
        self.coeff = coeff

    def eval(self, x: float) -> float:
        return self.coeff + self.exp * x

    def __repr__(self):
        if self.exp == 0:
            return f"{self.coeff:.1f}"
        return f"{self.coeff:.1f} + {self.exp}·x"

    def __eq__(self, other):
        return self.exp == other.exp and self.coeff == other.coeff

    def __hash__(self):
        return hash((self.exp, self.coeff))


def trop_eval(monomials: List[TropMono], x: float) -> float:
    """Evaluate a tropical polynomial: min over all monomials."""
    return min(m.eval(x) for m in monomials)


def nat_dominates(m1: TropMono, m2: TropMono) -> bool:
    """Check if m1 ℕ-dominates m2: m1.exp ≤ m2.exp AND m1.coeff ≤ m2.coeff."""
    return m1.exp <= m2.exp and m1.coeff <= m2.coeff


def nat_canonical(monomials: List[TropMono]) -> List[TropMono]:
    """Compute the ℕ-canonical form: remove Pareto-dominated monomials."""
    result = []
    for m in monomials:
        dominated = any(
            m2 != m and nat_dominates(m2, m)
            for m2 in monomials
        )
        if not dominated:
            result.append(m)
    return sorted(result, key=lambda m: m.exp)


def poly_language(monomials: List[TropMono], n: int) -> float:
    """The weighted language L(n) = min_m (m.coeff + m.exp * n)."""
    return trop_eval(monomials, n)


def residual(monomials: List[TropMono], k: int, n: int) -> float:
    """Residual of the language at prefix k: res_k(n) = L(k + n)."""
    return poly_language(monomials, k + n)


# =============================================================================
# Demo 1: Dominance Characterization
# =============================================================================
print("=" * 70)
print("DEMO 1: Dominance Characterization")
print("=" * 70)

m1 = TropMono(3, 2.0)
m2 = TropMono(3, 5.0)
m3 = TropMono(2, 1.0)

print(f"\nm1 = {m1}")
print(f"m2 = {m2}")
print(f"m3 = {m3}")

print(f"\nℕ-Dominates(m1, m2)? {nat_dominates(m1, m2)}")
print(f"  (exp: {m1.exp} ≤ {m2.exp} = {m1.exp <= m2.exp}, "
      f"coeff: {m1.coeff} ≤ {m2.coeff} = {m1.coeff <= m2.coeff})")

print(f"\nℕ-Dominates(m1, m3)? {nat_dominates(m1, m3)}")
print(f"  (exp: {m1.exp} ≤ {m3.exp} = {m1.exp <= m3.exp}, "
      f"coeff: {m1.coeff} ≤ {m3.coeff} = {m1.coeff <= m3.coeff})")

print(f"\nℕ-Dominates(m3, m1)? {nat_dominates(m3, m1)}")
print(f"  (exp: {m3.exp} ≤ {m1.exp} = {m3.exp <= m1.exp}, "
      f"coeff: {m3.coeff} ≤ {m1.coeff} = {m3.coeff <= m1.coeff})")


# =============================================================================
# Demo 2: Canonical Form Computation
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 2: Canonical Form Computation")
print("=" * 70)

poly = [TropMono(0, 10), TropMono(1, 5), TropMono(2, 3),
        TropMono(2, 7), TropMono(3, 0), TropMono(3, 4)]

print(f"\nOriginal polynomial ({len(poly)} monomials):")
for m in poly:
    print(f"  {m}")

canon = nat_canonical(poly)
print(f"\nCanonical form ({len(canon)} monomials):")
for m in canon:
    print(f"  {m}")

print(f"\nCompression: {len(poly)} → {len(canon)} monomials "
      f"({100*(1 - len(canon)/len(poly)):.0f}% reduction)")


# =============================================================================
# Demo 3: Language Preservation
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 3: Language Preservation (canonical_preserves_language)")
print("=" * 70)

print(f"\n{'n':>4} | {'L_orig(n)':>10} | {'L_canon(n)':>10} | {'Equal?':>7}")
print("-" * 40)
all_equal = True
for n in range(15):
    orig = poly_language(poly, n)
    can = poly_language(canon, n)
    eq = abs(orig - can) < 1e-10
    all_equal = all_equal and eq
    print(f"{n:4d} | {orig:10.2f} | {can:10.2f} | {'✓' if eq else '✗':>7}")

print(f"\nAll values equal: {'YES ✓' if all_equal else 'NO ✗'}")


# =============================================================================
# Demo 4: Pareto Structure
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 4: Pareto Structure of Canonical Monomials")
print("=" * 70)

poly2 = [TropMono(0, 15), TropMono(1, 8), TropMono(2, 4),
         TropMono(3, 1), TropMono(5, -2)]

canon2 = nat_canonical(poly2)
print(f"\nPolynomial: {[str(m) for m in poly2]}")
print(f"Canonical:  {[str(m) for m in canon2]}")

print(f"\nPareto structure (exp ↑ ⟹ coeff ↓):")
for i, m in enumerate(canon2):
    print(f"  Monomial {i+1}: exp = {m.exp}, coeff = {m.coeff}")
    if i > 0:
        prev = canon2[i-1]
        print(f"    Check: exp {prev.exp} < {m.exp} and "
              f"coeff {prev.coeff} > {m.coeff}: "
              f"{'✓' if prev.exp < m.exp and prev.coeff > m.coeff else '✗'}")


# =============================================================================
# Demo 5: Residual Analysis and Nerode Classes
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 5: Residual Analysis and Nerode Equivalence Classes")
print("=" * 70)

poly3 = [TropMono(0, 6), TropMono(1, 3), TropMono(3, 0)]

print(f"\nPolynomial: min(6, 3+x, 3x)")
print(f"L(n) values: {[poly_language(poly3, n) for n in range(10)]}")

# Compute residuals for each k
suffix_len = 8
residuals: Dict[int, List[float]] = {}
for k in range(8):
    res = [residual(poly3, k, n) for n in range(suffix_len)]
    residuals[k] = res

print(f"\nResidual table (rows = prefix k, columns = suffix n):")
print(f"{'k':>3} |", end="")
for n in range(suffix_len):
    print(f" n={n:1d}", end="")
print()
print("-" * (5 + 5 * suffix_len))

for k in range(8):
    print(f"{k:3d} |", end="")
    for v in residuals[k]:
        print(f" {v:4.0f}", end="")
    print()

# Find Nerode equivalence classes
classes: Dict[int, List[int]] = {}
class_id = 0
k_to_class: Dict[int, int] = {}

for k in range(8):
    found = False
    for rep, members in classes.items():
        if residuals[k] == residuals[rep]:
            members.append(k)
            k_to_class[k] = k_to_class[rep]
            found = True
            break
    if not found:
        classes[k] = [k]
        k_to_class[k] = class_id
        class_id += 1

print(f"\nNerode equivalence classes: {len(classes)}")
for rep, members in classes.items():
    print(f"  Class [{', '.join(str(m) for m in members)}] "
          f"(representative: k={rep})")

canon3 = nat_canonical(poly3)
print(f"\nCanonical monomials: {len(canon3)}")
for m in canon3:
    print(f"  {m}")

print(f"\n|Nerode classes| = {len(classes)}, |Canonical| = {len(canon3)}")


# =============================================================================
# Demo 6: Monotonicity
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 6: Language Monotonicity (polyLanguage_mono)")
print("=" * 70)

poly4 = [TropMono(0, 8), TropMono(2, 0), TropMono(5, -3)]
print(f"\nPolynomial: min(8, 2x, -3+5x)")

vals = [poly_language(poly4, n) for n in range(12)]
print(f"L(n) = {vals}")

mono_check = all(vals[i] <= vals[i+1] for i in range(len(vals)-1))
print(f"Monotone non-decreasing: {'YES ✓' if mono_check else 'NO ✗'}")


print("\n" + "=" * 70)
print("All demos completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Polynomial Canonicalization

Generates figures showing:
1. Lower envelope of affine functions
2. Pareto front of canonical monomials
3. Language and residual structure
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io


def save_fig_base64(fig) -> str:
    """Save a matplotlib figure as base64-encoded PNG."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# =============================================================================
# Figure 1: Lower Envelope
# =============================================================================

fig1, (ax1a, ax1b) = plt.subplots(1, 2, figsize=(14, 5))

# Define monomials
monomials = [(0, 10), (1, 5), (2, 3), (3, 0), (5, -2)]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

x = np.linspace(0, 8, 200)

# Plot individual monomials
for i, (e, c) in enumerate(monomials):
    y = c + e * x
    ax1a.plot(x, y, '--', color=colors[i], alpha=0.5, linewidth=1,
             label=f'{c} + {e}x')

# Plot lower envelope
envelope = np.array([min(c + e * xi for e, c in monomials) for xi in x])
ax1a.plot(x, envelope, 'k-', linewidth=2.5, label='Lower envelope')

ax1a.set_xlabel('x', fontsize=12)
ax1a.set_ylabel('Value', fontsize=12)
ax1a.set_title('Tropical Polynomial: Lower Envelope', fontsize=13)
ax1a.legend(fontsize=9)
ax1a.set_ylim(-5, 20)
ax1a.grid(True, alpha=0.3)

# Canonical monomials (Pareto)
canonical = [(0, 10), (1, 5), (2, 3), (3, 0), (5, -2)]  # all are Pareto-optimal here

# Plot language on ℕ
ns = range(9)
language = [min(c + e * n for e, c in monomials) for n in ns]
ax1b.plot(ns, language, 'ko-', markersize=8, linewidth=2, label='L(n)')

# Mark which monomial achieves the min
for n in ns:
    vals = [(c + e * n, i) for i, (e, c) in enumerate(monomials)]
    min_val, min_idx = min(vals)
    ax1b.plot(n, min_val, 'o', color=colors[min_idx], markersize=12,
             zorder=5, alpha=0.6)

ax1b.set_xlabel('n (natural number)', fontsize=12)
ax1b.set_ylabel('L(n)', fontsize=12)
ax1b.set_title('Weighted Language on ℕ', fontsize=13)
ax1b.grid(True, alpha=0.3)

fig1.tight_layout()
fig1.savefig('/workspace/request-project/fig_lower_envelope.png', dpi=150, bbox_inches='tight')
fig1_b64 = save_fig_base64(fig1)
plt.close()


# =============================================================================
# Figure 2: Pareto Front
# =============================================================================

fig2, ax2 = plt.subplots(figsize=(8, 6))

# Full set of monomials
all_monos = [(0, 10), (1, 5), (1, 8), (2, 3), (2, 7), (3, 0), (3, 4), (5, -2)]
pareto = [(0, 10), (1, 5), (2, 3), (3, 0), (5, -2)]
dominated = [m for m in all_monos if m not in pareto]

# Plot dominated monomials
for e, c in dominated:
    ax2.plot(e, c, 'x', color='red', markersize=15, markeredgewidth=3, zorder=5)
    ax2.annotate(f'({e}, {c})', (e, c), textcoords="offset points",
                xytext=(10, -10), fontsize=10, color='red')

# Plot canonical monomials
pareto_e = [e for e, c in pareto]
pareto_c = [c for e, c in pareto]
ax2.plot(pareto_e, pareto_c, 'bo-', markersize=12, linewidth=2,
        label='Canonical (Pareto front)', zorder=10)

for e, c in pareto:
    ax2.annotate(f'({e}, {c})', (e, c), textcoords="offset points",
                xytext=(10, 5), fontsize=10, color='blue')

# Shade dominated region from each canonical point
ax2.fill_between([min(pareto_e)-0.5, max(pareto_e)+1],
                [max(pareto_c)+2]*2, [max(pareto_c)+2]*2,
                alpha=0.05, color='red')

ax2.set_xlabel('Exponent (slope)', fontsize=13)
ax2.set_ylabel('Coefficient (intercept)', fontsize=13)
ax2.set_title('Pareto Front: ℕ-Canonical Monomials', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Add arrows showing domination
for e, c in dominated:
    # Find the dominator
    for pe, pc in pareto:
        if pe <= e and pc <= c and (pe, pc) != (e, c):
            ax2.annotate('', xy=(pe, pc), xytext=(e, c),
                        arrowprops=dict(arrowstyle='->', color='red', alpha=0.4,
                                      linewidth=1.5))
            break

fig2.tight_layout()
fig2.savefig('/workspace/request-project/fig_pareto_front.png', dpi=150, bbox_inches='tight')
fig2_b64 = save_fig_base64(fig2)
plt.close()


# =============================================================================
# Figure 3: Residual Structure
# =============================================================================

fig3, (ax3a, ax3b) = plt.subplots(1, 2, figsize=(14, 5))

monomials3 = [(0, 6), (1, 3), (3, 0)]
colors3 = ['#e41a1c', '#377eb8', '#4daf4a']

# Plot residuals
for k in range(6):
    residual = [min(c + e * (k + n) for e, c in monomials3) for n in range(10)]
    ax3a.plot(range(10), residual, 'o-', markersize=5, linewidth=1.5,
             label=f'Residual at k={k}', alpha=0.8)

ax3a.set_xlabel('Suffix length n', fontsize=12)
ax3a.set_ylabel('Value', fontsize=12)
ax3a.set_title('Residual Functions (Nerode Analysis)', fontsize=13)
ax3a.legend(fontsize=9)
ax3a.grid(True, alpha=0.3)

# Nerode class diagram
suffix_len = 15
residuals = {}
for k in range(10):
    residuals[k] = tuple(min(c + e * (k + n) for e, c in monomials3)
                        for n in range(suffix_len))

# Find equivalence classes
classes = {}
for k in range(10):
    found = False
    for rep in classes:
        if residuals[rep] == residuals[k]:
            classes[rep].append(k)
            found = True
            break
    if not found:
        classes[k] = [k]

class_colors = ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e']
y_pos = 0
for i, (rep, members) in enumerate(classes.items()):
    color = class_colors[i % len(class_colors)]
    for k in members:
        ax3b.barh(y_pos, 1, left=k-0.4, height=0.6, color=color, alpha=0.7,
                 edgecolor='black', linewidth=0.5)
        ax3b.text(k, y_pos, str(k), ha='center', va='center', fontsize=10,
                 fontweight='bold')
    ax3b.text(-1.5, y_pos, f'Class {i+1}', ha='right', va='center', fontsize=11,
             color=color, fontweight='bold')
    y_pos += 1

ax3b.set_xlabel('Prefix length k', fontsize=12)
ax3b.set_title('Nerode Equivalence Classes', fontsize=13)
ax3b.set_yticks([])
ax3b.set_xlim(-3, 10)
ax3b.grid(True, alpha=0.3, axis='x')

fig3.tight_layout()
fig3.savefig('/workspace/request-project/fig_residuals.png', dpi=150, bbox_inches='tight')
fig3_b64 = save_fig_base64(fig3)
plt.close()

print("All visualizations saved!")
print(f"  fig_lower_envelope.png")
print(f"  fig_pareto_front.png")
print(f"  fig_residuals.png")

# Save base64 data for PACKAGE.json
with open('/workspace/request-project/_viz_b64.txt', 'w') as f:
    f.write(f"LOWER_ENVELOPE:{fig1_b64}\n")
    f.write(f"PARETO_FRONT:{fig2_b64}\n")
    f.write(f"RESIDUALS:{fig3_b64}\n")
