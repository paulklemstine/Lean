#!/usr/bin/env python3
"""
Prime-Spectral Schrödinger Bridge: Computational Demonstration

This script demonstrates the key theorem computationally:
  derivable x y ⟺ lim_{ε→0⁺} schrodingerCost(ε, K, x, y) = 0

We construct a small coherent closure proof semiring, compute its prime
spectrum, and show how the Schrödinger bridge cost converges (or not)
depending on derivability.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product

# ============================================================
# 1. A Concrete Closure Proof Semiring: Powerset of {a, b, c}
# ============================================================

ELEMENTS = ['a', 'b', 'c']

def cl(S: frozenset) -> frozenset:
    """Closure operator: knowing 'a' gives you 'c'."""
    if 'a' in S:
        return S | {'c'}
    return S

def derivable(x: frozenset, y: frozenset) -> bool:
    """x derives y iff cl(x) ⊆ cl(y)."""
    return cl(x).issubset(cl(y))

class PrimePoint:
    """A prime spectral point: evaluates whether a specific element is present."""
    def __init__(self, element):
        self.element = element
        self.name = f"F_{element}"

    def __call__(self, S: frozenset) -> bool:
        return self.element in S

    def __repr__(self):
        return self.name

# Compute cl-compatible prime spectrum
def all_subsets():
    for bits in cartesian_product([False, True], repeat=len(ELEMENTS)):
        yield frozenset(e for e, b in zip(ELEMENTS, bits) if b)

prime_spectrum = []
for e in ELEMENTS:
    p = PrimePoint(e)
    compatible = all(p(cl(S)) == p(S) for S in all_subsets())
    if compatible:
        prime_spectrum.append(p)

print("=" * 60)
print("PRIME-SPECTRAL SCHRÖDINGER BRIDGE DEMONSTRATION")
print("=" * 60)
print(f"\nLattice: P({{a, b, c}}) with closure cl(S) = S ∪ {{c}} if a ∈ S")
print(f"Prime spectrum: {prime_spectrum}")
print(f"  (F_c excluded: not compatible with closure)")

# ============================================================
# 2. Definitions from the formalization
# ============================================================

def spectral_indicator(x, p):
    return 1.0 if p(x) else 0.0

def free_energy_gap(K, x, y):
    gap = 0.0
    for i, p in enumerate(prime_spectrum):
        ind = spectral_indicator(x, p)
        if ind == 0:
            continue
        if p(y):
            inner = 0.0
        else:
            costs = [K[i][j] for j, q in enumerate(prime_spectrum) if q(y)]
            inner = min(costs) if costs else float('inf')
        gap = max(gap, ind * inner)
    return gap

def schrodinger_cost(eps, K, x, y):
    cost = 0.0
    for i, p in enumerate(prime_spectrum):
        ind = spectral_indicator(x, p)
        if ind == 0:
            continue
        if p(y):
            inner = eps
        else:
            costs = [K[i][j] + eps for j, q in enumerate(prime_spectrum) if q(y)]
            inner = min(costs) if costs else float('inf')
        cost = max(cost, ind * inner)
    return cost

# Markov cost kernel
n_primes = len(prime_spectrum)
K = np.zeros((n_primes, n_primes))
for i in range(n_primes):
    for j in range(n_primes):
        if i != j:
            K[i][j] = 1.0

print(f"\nMarkov cost kernel K:")
for i, p in enumerate(prime_spectrum):
    row = ", ".join(f"{K[i][j]:.1f}" for j in range(n_primes))
    print(f"  K[{p}] = [{row}]")

# ============================================================
# 3. Derivability Examples
# ============================================================

print("\n" + "=" * 60)
print("DERIVABILITY EXAMPLES")
print("=" * 60)

test_pairs = [
    (frozenset({'a'}), frozenset({'a', 'c'})),
    (frozenset({'a'}), frozenset({'c'})),
    (frozenset({'b'}), frozenset({'b'})),
    (frozenset({'a'}), frozenset({'b'})),
    (frozenset(), frozenset({'a'})),
    (frozenset({'a', 'b'}), frozenset({'a', 'c'})),
]

for x, y in test_pairs:
    d = derivable(x, y)
    gap = free_energy_gap(K, x, y)
    xs = str(set(x)) if x else '∅'
    ys = str(set(y)) if y else '∅'
    print(f"\n  x = {xs:>14s}, y = {ys:>14s}")
    clxs = str(set(cl(x))) if cl(x) else '∅'
    clys = str(set(cl(y))) if cl(y) else '∅'
    print(f"  cl(x) = {clxs:>14s}, cl(y) = {clys:>14s}")
    print(f"  derivable: {str(d):>5s}  |  freeEnergyGap: {gap:.3f}  |  "
          f"gap=0 ⟺ derivable: {'✓' if (gap == 0) == d else '✗'}")

# ============================================================
# 4. Convergence Plots
# ============================================================

epsilons = np.logspace(-3, 1, 200)

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle("Schrödinger Bridge Cost Convergence on Prime Spectrum\n"
             "derivable(x,y) ⟺ schrodingerCost(ε) → 0 as ε → 0⁺",
             fontsize=14, fontweight='bold')

for idx, (x, y) in enumerate(test_pairs):
    ax = axes[idx // 3][idx % 3]
    d = derivable(x, y)
    gap = free_energy_gap(K, x, y)

    costs = [schrodinger_cost(eps, K, x, y) for eps in epsilons]

    ax.semilogx(epsilons, costs, 'b-', linewidth=2, label='schrodingerCost(ε)')
    ax.axhline(y=gap, color='r', linestyle='--', linewidth=1.5,
               label=f'freeEnergyGap = {gap:.2f}')

    xs = str(set(x)) if x else '∅'
    ys = str(set(y)) if y else '∅'
    ax.set_xlabel('ε (log scale)')
    ax.set_ylabel('Cost')
    ax.set_title(f'{xs} → {ys}\n'
                 f'{"derivable ✓" if d else "NOT derivable ✗"}',
                 fontsize=10)
    ax.legend(fontsize=8)
    ax.set_ylim(bottom=-0.1)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/schrodinger_convergence.png', dpi=150, bbox_inches='tight')
print("\n  Convergence plot saved to demos/schrodinger_convergence.png")

# ============================================================
# 5. Sandwich Estimate Visualization
# ============================================================

fig2, ax2 = plt.subplots(1, 1, figsize=(10, 6))
x_ex = frozenset({'a'})
y_ex = frozenset({'b'})
gap_ex = free_energy_gap(K, x_ex, y_ex)

eps_range = np.linspace(0, 2, 500)
costs_ex = [schrodinger_cost(e, K, x_ex, y_ex) for e in eps_range]
upper_bound = [gap_ex + e for e in eps_range]

ax2.fill_between(eps_range, gap_ex, upper_bound, alpha=0.2, color='blue',
                  label='Sandwich region')
ax2.plot(eps_range, costs_ex, 'b-', linewidth=2, label='schrodingerCost(ε)')
ax2.axhline(y=gap_ex, color='r', linestyle='--', linewidth=2,
            label=f'freeEnergyGap = {gap_ex:.2f}')
ax2.plot(eps_range, upper_bound, 'g--', linewidth=1.5,
         label='freeEnergyGap + ε')

ax2.set_xlabel('ε', fontsize=12)
ax2.set_ylabel('Cost', fontsize=12)
ax2.set_title('Sandwich Estimate: {a} → {b} (NOT derivable)\n'
              'freeEnergyGap ≤ schrodingerCost(ε) ≤ freeEnergyGap + ε',
              fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/sandwich_estimate.png', dpi=150, bbox_inches='tight')
print("  Sandwich estimate plot saved to demos/sandwich_estimate.png")

# ============================================================
# 6. Numerical Verification
# ============================================================

print("\n" + "=" * 60)
print("NUMERICAL VERIFICATION OF THE MAIN THEOREM")
print("=" * 60)
print("\n  derivable(x,y) ⟺ lim_{ε→0⁺} schrodingerCost(ε,K,x,y) = 0\n")

eps_small = 1e-8
all_correct = True
for x, y in test_pairs:
    d = derivable(x, y)
    cost_small = schrodinger_cost(eps_small, K, x, y)
    gap = free_energy_gap(K, x, y)
    converges_to_zero = cost_small < 1e-6

    correct = d == converges_to_zero
    all_correct = all_correct and correct

    xs = str(set(x)) if x else '∅'
    ys = str(set(y)) if y else '∅'
    print(f"  {xs:>14s} → {ys:>14s}:  "
          f"derivable={str(d):>5s}  cost(10⁻⁸)={cost_small:.2e}  "
          f"gap={gap:.3f}  {'✓' if correct else '✗'}")

print(f"\n  All cases verified: {'✓ YES' if all_correct else '✗ NO'}")

# ============================================================
# 7. Countermodel Analysis
# ============================================================

print("\n" + "=" * 60)
print("COUNTERMODEL INTERPOLATION")
print("=" * 60)
print("\nWhen x does NOT derive y, the free energy gap identifies")
print("the worst-case separating prime — a countermodel to derivability.\n")

for x, y in test_pairs:
    if not derivable(x, y):
        xs = str(set(x)) if x else '∅'
        ys = str(set(y)) if y else '∅'
        print(f"  {xs} ↛ {ys}:")
        for i, p in enumerate(prime_spectrum):
            if p(x) and not p(y):
                costs = [K[i][j] for j, q in enumerate(prime_spectrum) if q(y)]
                min_cost = min(costs) if costs else float('inf')
                print(f"    Separating prime: {p} (min transport cost: {min_cost:.2f})")
        print(f"    Free energy gap: {free_energy_gap(K, x, y):.2f}\n")

print("=" * 60)
print("DEMONSTRATION COMPLETE")
print("=" * 60)
