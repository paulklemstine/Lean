"""
Visualization 3: Parallel Möbius Cancellation Bridge

Side-by-side visualization of the Möbius cancellation principle
in two domains:
  1. Number theory: Σ_{d|n} μ(d) = [n=1]
  2. Group theory: Σ_{K≥H} μ(K,⊤) = [H=⊤]

Shows how the same algebraic principle (Möbius inversion on a lattice)
governs both integer divisibility and group generation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def mobius(n):
    """Number-theoretic Möbius function."""
    if n == 1:
        return 1
    factors = []
    d, temp = 2, n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n):
    return sorted(d for d in range(1, n + 1) if n % d == 0)


# Figure setup
fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# Panel 1: Möbius function values
ax1 = axes[0]
ns = range(1, 31)
mus = [mobius(n) for n in ns]
colors = ['#2ecc71' if m == 1 else '#e74c3c' if m == -1 else '#95a5a6' for m in mus]
ax1.bar(ns, mus, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('μ(n)', fontsize=11)
ax1.set_title('Number-Theoretic Möbius Function', fontsize=12)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.set_xticks(range(0, 31, 5))
legend_elements = [
    mpatches.Patch(facecolor='#2ecc71', label='μ(n) = +1 (even # primes)'),
    mpatches.Patch(facecolor='#e74c3c', label='μ(n) = -1 (odd # primes)'),
    mpatches.Patch(facecolor='#95a5a6', label='μ(n) = 0 (squared factor)'),
]
ax1.legend(handles=legend_elements, fontsize=7, loc='lower right')

# Panel 2: Divisor sum cancellation
ax2 = axes[1]
ns_check = range(1, 21)
sums = [sum(mobius(d) for d in divisors(n)) for n in ns_check]
colors2 = ['#2ecc71' if s == 1 else '#3498db' if s == 0 else '#e74c3c' for s in sums]
ax2.bar(ns_check, sums, color=colors2, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('n', fontsize=11)
ax2.set_ylabel('Σ_{d|n} μ(d)', fontsize=11)
ax2.set_title('Möbius Cancellation: Σ_{d|n} μ(d) = [n=1]', fontsize=12)
ax2.axhline(y=0, color='black', linewidth=0.5)

# Annotate
for i, (n, s) in enumerate(zip(ns_check, sums)):
    if s != 0:
        ax2.annotate(f'n={n}', (n, s), textcoords="offset points",
                     xytext=(0, 10), ha='center', fontsize=8, color='green')

# Panel 3: The bridge diagram
ax3 = axes[2]
ax3.axis('off')

# Draw the bridge
bridge_text = """
THE MÖBIUS BRIDGE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NUMBER THEORY          GROUP THEORY
(divisor lattice)    (subgroup lattice)

  Σ_{d|n} μ(d)        Σ_{K≥H} μ(K,⊤)
    = [n=1]              = [H=⊤]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Both are instances of
MÖBIUS INVERSION
on a finite lattice:

  Σ_{y≥x} μ(x,y) = δ(x, 1̂)

where 1̂ is the top element.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CONSEQUENCE:
φ_k(G) = Σ_H μ(H,G) · |H|^k
J_k(n) = Σ_{d|n} μ(n/d) · d^k

Same formula, different lattices!
"""

ax3.text(0.5, 0.5, bridge_text, transform=ax3.transAxes,
         fontsize=9, verticalalignment='center', horizontalalignment='center',
         fontfamily='monospace',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                   edgecolor='orange', alpha=0.8))

ax3.set_title('Abstract Unification', fontsize=12)

plt.suptitle('Parallel Möbius Cancellation: Number Theory ↔ Group Theory',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mobius_bridge.png', dpi=150, bbox_inches='tight')
print("Saved mobius_bridge.png")
