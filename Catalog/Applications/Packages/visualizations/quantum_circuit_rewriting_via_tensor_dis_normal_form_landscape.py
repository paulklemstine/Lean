#!/usr/bin/env python3
"""
Visualization 3: Normal Form Landscape

Visualizes the landscape of canonical normal forms for 2-qubit circuits:
how many syntactically distinct circuits map to each equivalence class,
and the distribution of monomial counts across circuit expressions.

This illustrates how normalization compresses the space of circuit descriptions.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
import itertools

# ─── Inline QExpr implementation ───

class QExpr:
    pass

class Gate(QExpr):
    def __init__(self, n):
        self.n = n
    def __eq__(self, o): return isinstance(o, Gate) and self.n == o.n
    def __hash__(self): return hash(("g", self.n))

class Seq(QExpr):
    def __init__(self, a, b):
        self.a, self.b = a, b
    def __eq__(self, o): return isinstance(o, Seq) and self.a == o.a and self.b == o.b
    def __hash__(self): return hash(("s", self.a, self.b))

class Add(QExpr):
    def __init__(self, a, b):
        self.a, self.b = a, b
    def __eq__(self, o): return isinstance(o, Add) and self.a == o.a and self.b == o.b
    def __hash__(self): return hash(("a", self.a, self.b))

class One(QExpr):
    def __eq__(self, o): return isinstance(o, One)
    def __hash__(self): return hash("one")

def expand(e):
    if isinstance(e, Gate): return [[e.n]]
    if isinstance(e, One): return [[]]
    if isinstance(e, Add): return expand(e.a) + expand(e.b)
    if isinstance(e, Seq): return [p+q for p in expand(e.a) for q in expand(e.b)]
    return [[]]

def normalize(e):
    return tuple(sorted(tuple(m) for m in expand(e)))

# ─── Generate circuits ───

GATE_IDS = [0, 1, 2, 3, 4]
GATE_NAMES = {0:"H⊗I", 1:"I⊗H", 2:"T⊗I", 3:"I⊗T", 4:"CNOT"}

def gen_product_circuits(depth):
    """Generate product circuits (no Add) up to given depth."""
    if depth <= 0:
        return [One()]
    if depth == 1:
        return [Gate(g) for g in GATE_IDS]
    result = [Gate(g) for g in GATE_IDS]
    prev = gen_product_circuits(depth - 1)
    for g in GATE_IDS:
        for c in prev:
            result.append(Seq(Gate(g), c))
    return result

def gen_circuits_with_add(depth):
    """Generate circuits including Add nodes."""
    products = gen_product_circuits(depth)
    all_circuits = list(products)
    # Add combinations of product circuits
    for i in range(min(len(products), 15)):
        for j in range(min(len(products), 15)):
            if i != j:
                all_circuits.append(Add(products[i], products[j]))
                # Also seq with an add
                if len(GATE_IDS) > 0:
                    all_circuits.append(Seq(Add(products[i], products[j]), Gate(GATE_IDS[0])))
    return all_circuits

# ─── Compute data ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Normal Form Landscape for 2-Qubit Circuits',
             fontsize=16, fontweight='bold', y=0.98)

# Panel 1: Circuit count vs NF count by depth
ax1 = axes[0, 0]
depths = range(1, 5)
circuit_counts = []
nf_counts = []

for d in depths:
    circuits = gen_circuits_with_add(d)
    nfs = set()
    for c in circuits:
        nfs.add(normalize(c))
    circuit_counts.append(len(circuits))
    nf_counts.append(len(nfs))

x = np.arange(len(list(depths)))
width = 0.35
bars1 = ax1.bar(x - width/2, circuit_counts, width, label='Syntactic circuits',
                color='#2196F3', alpha=0.8)
bars2 = ax1.bar(x + width/2, nf_counts, width, label='Distinct normal forms',
                color='#FF9800', alpha=0.8)
ax1.set_xlabel('Circuit Depth')
ax1.set_ylabel('Count')
ax1.set_title('Compression: Circuits → Normal Forms')
ax1.set_xticks(x)
ax1.set_xticklabels([str(d) for d in depths])
ax1.legend()
ax1.set_yscale('log')

# Panel 2: Monomial count distribution
ax2 = axes[0, 1]
circuits = gen_circuits_with_add(3)
mono_counts = [len(expand(c)) for c in circuits]
counts = Counter(mono_counts)
xs = sorted(counts.keys())
ys = [counts[x] for x in xs]
ax2.bar(xs, ys, color='#4CAF50', alpha=0.8, edgecolor='#2E7D32')
ax2.set_xlabel('Number of Monomials in Expansion')
ax2.set_ylabel('Number of Circuits')
ax2.set_title('Distribution of Expansion Sizes (depth ≤ 3)')

# Panel 3: Equivalence class sizes
ax3 = axes[1, 0]
circuits = gen_circuits_with_add(3)
nf_groups = {}
for c in circuits:
    nf = normalize(c)
    if nf not in nf_groups:
        nf_groups[nf] = 0
    nf_groups[nf] += 1

class_sizes = sorted(nf_groups.values(), reverse=True)
ax3.bar(range(min(30, len(class_sizes))), class_sizes[:30],
        color='#9C27B0', alpha=0.8, edgecolor='#6A1B9A')
ax3.set_xlabel('Equivalence Class (ranked by size)')
ax3.set_ylabel('Number of Circuits in Class')
ax3.set_title('Top 30 Equivalence Classes by Size')

# Panel 4: Compression ratio
ax4 = axes[1, 1]
compression = [c/n if n > 0 else 1 for c, n in zip(circuit_counts, nf_counts)]
ax4.plot(list(depths), compression, 'o-', color='#E91E63', linewidth=2.5,
         markersize=10, markerfacecolor='white', markeredgewidth=2)
ax4.set_xlabel('Circuit Depth')
ax4.set_ylabel('Compression Ratio (circuits / normal forms)')
ax4.set_title('Normalization Compression Ratio')
ax4.grid(True, alpha=0.3)

for i, (d, cr) in enumerate(zip(depths, compression)):
    ax4.annotate(f'{cr:.1f}×', (d, cr), textcoords="offset points",
                xytext=(0, 12), ha='center', fontsize=10, fontweight='bold',
                color='#E91E63')

plt.tight_layout()
plt.savefig('viz_normal_form_landscape.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved viz_normal_form_landscape.png")
