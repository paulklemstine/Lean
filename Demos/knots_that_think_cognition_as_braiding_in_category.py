#!/usr/bin/env python3
"""
Cognitive Braid Algebra — Interactive Demo

Demonstrates the key theorems:
1. Exponent sum is a braid invariant
2. Complexity shadow characterization
3. Coherence ratio computation
"""

from dataclasses import dataclass
from typing import List, Tuple
import math


@dataclass
class BraidGen:
    """A braid generator σ_i^ε"""
    index: int
    pos: bool  # True = σ_i, False = σ_i⁻¹

    @property
    def sign(self) -> int:
        return 1 if self.pos else -1

    def __repr__(self):
        sym = "σ" if self.pos else "σ⁻¹"
        return f"{sym}_{self.index}"


BraidWord = List[BraidGen]


def exponent_sum(w: BraidWord) -> int:
    """The abelianization map B_n → ℤ"""
    return sum(g.sign for g in w)


def pos_count(w: BraidWord) -> int:
    return sum(1 for g in w if g.pos)


def neg_count(w: BraidWord) -> int:
    return sum(1 for g in w if not g.pos)


@dataclass
class ComplexityShadow:
    """The (exponent, crossings) complexity data of a braid"""
    exponent: int
    crossings: int

    @property
    def realizable(self) -> bool:
        return abs(self.exponent) <= self.crossings and \
               (self.exponent + self.crossings) % 2 == 0

    @property
    def coherence_ratio(self) -> float:
        if self.crossings == 0:
            return 0.0
        return abs(self.exponent) / self.crossings


def shadow(w: BraidWord) -> ComplexityShadow:
    return ComplexityShadow(exponent_sum(w), len(w))


def construct_from_shadow(s: ComplexityShadow) -> BraidWord:
    """Construct a braid word realizing a given shadow (if realizable)."""
    assert s.realizable, f"Shadow {s} is not realizable"
    p = (s.crossings + s.exponent) // 2  # positive count
    n = s.crossings - p                   # negative count
    return [BraidGen(0, True)] * p + [BraidGen(0, False)] * n


# ─── Demo 1: Exponent Sum Invariance ───

print("=" * 60)
print("DEMO 1: Exponent Sum is a Braid Invariant")
print("=" * 60)

# The braid relation: σ₁σ₂σ₁ = σ₂σ₁σ₂
w1 = [BraidGen(0, True), BraidGen(1, True), BraidGen(0, True)]
w2 = [BraidGen(1, True), BraidGen(0, True), BraidGen(1, True)]
print(f"\nWord 1 (σ₀σ₁σ₀):  {w1}")
print(f"Word 2 (σ₁σ₀σ₁):  {w2}")
print(f"Exponent sum 1: {exponent_sum(w1)}")
print(f"Exponent sum 2: {exponent_sum(w2)}")
print(f"Equal? {exponent_sum(w1) == exponent_sum(w2)} ✓")

# Cancellation: σ₁σ₁⁻¹ = ε
w3 = [BraidGen(0, True), BraidGen(0, False)]
w4: BraidWord = []
print(f"\nWord 3 (σ₀σ₀⁻¹): {w3}")
print(f"Word 4 (empty):   {w4}")
print(f"Exponent sum 3: {exponent_sum(w3)}")
print(f"Exponent sum 4: {exponent_sum(w4)}")
print(f"Equal? {exponent_sum(w3) == exponent_sum(w4)} ✓")

# ─── Demo 2: Complexity Shadow Characterization ───

print("\n" + "=" * 60)
print("DEMO 2: Complexity Shadow Characterization")
print("=" * 60)
print("\nTheorem: (e, c) is realizable iff |e| ≤ c and e + c is even\n")

test_shadows = [
    ComplexityShadow(3, 5),   # realizable: |3|≤5, 3+5=8 even
    ComplexityShadow(2, 5),   # NOT: 2+5=7 odd
    ComplexityShadow(6, 4),   # NOT: |6|>4
    ComplexityShadow(0, 4),   # realizable: |0|≤4, 0+4=4 even
    ComplexityShadow(-3, 7),  # realizable: |-3|≤7, -3+7=4 even
    ComplexityShadow(0, 0),   # realizable: trivial braid
]

for s in test_shadows:
    status = "✓ realizable" if s.realizable else "✗ NOT realizable"
    reason = f"|{s.exponent}|={'≤' if abs(s.exponent)<=s.crossings else '>'}{s.crossings}, " \
             f"{s.exponent}+{s.crossings}={s.exponent+s.crossings} ({'even' if (s.exponent+s.crossings)%2==0 else 'odd'})"
    print(f"  ({s.exponent:+d}, {s.crossings}): {status}  [{reason}]")

# Construct words for realizable shadows
print("\nConstruction examples:")
for s in test_shadows:
    if s.realizable:
        w = construct_from_shadow(s)
        print(f"  Shadow ({s.exponent:+d}, {s.crossings}) → word {w}")
        print(f"    Verify: exponent_sum={exponent_sum(w)}, length={len(w)}")

# ─── Demo 3: Coherence Ratio ───

print("\n" + "=" * 60)
print("DEMO 3: Coherence Ratio — Measuring Thought Quality")
print("=" * 60)

cognitive_processes = {
    "Focused thought (all positive)": [BraidGen(i % 3, True) for i in range(6)],
    "Creative insight (trefoil)": [BraidGen(0, True), BraidGen(1, True), BraidGen(0, True)],
    "Confused thinking (balanced)": [BraidGen(0, True), BraidGen(0, False),
                                     BraidGen(1, True), BraidGen(1, False)],
    "Linear reasoning (identity)": [],
    "Mixed process": [BraidGen(0, True), BraidGen(1, True), BraidGen(0, False),
                      BraidGen(2, True), BraidGen(1, True)],
}

print(f"\n{'Process':<35} {'|w|':>4} {'Σ':>4} {'|Σ|/|w|':>8} {'Interpretation'}")
print("-" * 80)
for name, w in cognitive_processes.items():
    s = shadow(w)
    interp = ("trivial" if s.crossings == 0
              else "maximally coherent" if s.coherence_ratio == 1.0
              else "maximally incoherent" if s.coherence_ratio == 0.0
              else f"partially coherent")
    print(f"  {name:<33} {s.crossings:>4} {s.exponent:>+4} {s.coherence_ratio:>8.3f}   {interp}")

# ─── Demo 4: Parity and Triangle Inequality ───

print("\n" + "=" * 60)
print("DEMO 4: Parity Theorem Verification")
print("=" * 60)
print("\nTheorem: exponentSum(w) + |w| is always even\n")

import random
random.seed(42)
for trial in range(8):
    n = random.randint(0, 10)
    w = [BraidGen(random.randint(0, 3), random.choice([True, False])) for _ in range(n)]
    e = exponent_sum(w)
    print(f"  Random braid (len {n:>2}): e={e:>+3}, e+|w|={e+n:>+3} "
          f"({'even ✓' if (e+n)%2==0 else 'ODD ✗'}), "
          f"|e|≤|w|? {abs(e)<=n} ✓")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Realizable Complexity Shadows

Plots the lattice of realizable (exponent, crossings) pairs,
showing the triangle inequality and parity constraints.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    max_c = 15
    realizable_e = []
    realizable_c = []
    unrealizable_e = []
    unrealizable_c = []

    for c in range(max_c + 1):
        for e in range(-c, c + 1):
            if abs(e) <= c and (e + c) % 2 == 0:
                realizable_e.append(e)
                realizable_c.append(c)
            else:
                unrealizable_e.append(e)
                unrealizable_c.append(c)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Plot unrealizable points
    ax.scatter(unrealizable_e, unrealizable_c, c='lightgray', s=20,
               alpha=0.5, label='Not realizable', zorder=1)

    # Plot realizable points colored by coherence ratio
    coherence = [abs(e) / c if c > 0 else 0
                 for e, c in zip(realizable_e, realizable_c)]
    sc = ax.scatter(realizable_e, realizable_c, c=coherence, cmap='RdYlGn_r',
                    s=40, edgecolors='black', linewidths=0.5,
                    label='Realizable', zorder=2, vmin=0, vmax=1)

    # Draw boundary lines |e| = c
    e_line = np.linspace(-max_c, max_c, 100)
    ax.plot(e_line, np.abs(e_line), 'r--', linewidth=1.5, alpha=0.7,
            label='Boundary: |e| = c')

    # Mark special points
    special = {
        (0, 0): 'Trivial\n(identity)',
        (3, 3): 'Maximally\ncoherent',
        (0, 4): 'Balanced\n(confused)',
    }
    for (e, c), label in special.items():
        ax.annotate(label, (e, c), textcoords="offset points",
                    xytext=(15, 10), fontsize=8,
                    arrowprops=dict(arrowstyle='->', color='black'))

    plt.colorbar(sc, ax=ax, label='Coherence ratio |e|/c')
    ax.set_xlabel('Exponent sum (e)', fontsize=12)
    ax.set_ylabel('Crossing count (c)', fontsize=12)
    ax.set_title('Complexity Shadow Lattice\n'
                 'Realizable iff |e| ≤ c and e + c even', fontsize=14)
    ax.legend(loc='upper left')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('shadow_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved shadow_lattice.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Cognitive Braid Trajectories

Plots the partial exponent sum trajectory for different types
of cognitive processes, showing how coherent vs confused thought
patterns differ in their complexity evolution.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def partial_sums(signs):
    """Compute running partial sums."""
    sums = [0]
    for s in signs:
        sums.append(sums[-1] + s)
    return sums


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Define cognitive process types
    processes = {
        'Focused thought\n(all positive, coherence=1.0)': {
            'signs': [1, 1, 1, 1, 1, 1, 1, 1],
            'color': '#2ca02c',
            'ax': axes[0, 0]
        },
        'Creative insight\n(trefoil braid, coherence=1.0)': {
            'signs': [1, 1, 1],
            'color': '#d62728',
            'ax': axes[0, 1]
        },
        'Confused thinking\n(balanced, coherence=0.0)': {
            'signs': [1, -1, 1, -1, 1, -1, 1, -1],
            'color': '#9467bd',
            'ax': axes[1, 0]
        },
        'Mixed process\n(partial coherence=0.6)': {
            'signs': [1, 1, -1, 1, 1, -1, 1, -1, 1, 1],
            'color': '#ff7f0e',
            'ax': axes[1, 1]
        },
    }

    for title, info in processes.items():
        signs = info['signs']
        sums = partial_sums(signs)
        ax = info['ax']

        # Plot trajectory
        ax.plot(range(len(sums)), sums, 'o-', color=info['color'],
                linewidth=2, markersize=6)
        ax.fill_between(range(len(sums)), sums, alpha=0.15, color=info['color'])
        ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')

        # Annotate
        e = sum(signs)
        c = len(signs)
        cr = abs(e) / c if c > 0 else 0
        depth = max(abs(s) for s in sums)

        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_xlabel('Step')
        ax.set_ylabel('Partial exponent sum')
        ax.text(0.02, 0.98,
                f'e = {e:+d}\nc = {c}\n|e|/c = {cr:.2f}\ndepth = {depth}',
                transform=ax.transAxes, fontsize=9, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
        ax.grid(True, alpha=0.3)
        ax.set_xticks(range(len(sums)))

    plt.suptitle('Cognitive Braid Trajectories\n'
                 'Partial exponent sums reveal thought structure',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('braid_trajectories.png', dpi=150, bbox_inches='tight')
    print("Saved braid_trajectories.png")


if __name__ == "__main__":
    main()
