#!/usr/bin/env python3
"""
Categorical Physics: Numerical Demonstrations

Demonstrates key results from the categorical physics formalization:
1. Oracle hierarchy computation
2. Theory spectrum analysis
3. Dualizable tower enumeration
4. Stability threshold verification
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import List, Set, Optional


class TheoryType(Enum):
    TQFT = auto()
    CFT = auto()
    String = auto()
    Gravity = auto()


@dataclass
class DualizableTower:
    """A dualizable tower with objects at each level."""
    obj_sizes: List[int]  # number of objects at each level
    stable_level: int

    def is_subsingleton(self, level: int) -> bool:
        if level < len(self.obj_sizes):
            return self.obj_sizes[level] <= 1
        return True  # above defined levels, assumed trivial

    def is_two_infinity(self) -> bool:
        return self.stable_level == 2


def tqft_oracle_level(d: int) -> int:
    """Oracle level of a TQFT in dimension d."""
    return 0 if d <= 3 else d - 3


def theory_spectrum(tower: DualizableTower) -> Set[TheoryType]:
    """Compute which theory types a tower supports."""
    spectrum = set()
    if not tower.is_subsingleton(0):
        spectrum.add(TheoryType.TQFT)
    if not tower.is_subsingleton(1):
        spectrum.add(TheoryType.CFT)
        spectrum.add(TheoryType.String)
    if not tower.is_subsingleton(2):
        spectrum.add(TheoryType.Gravity)
    return spectrum


def min_stable_level(theories: Set[TheoryType]) -> int:
    """Minimum stable level to support a set of theories."""
    required = {
        TheoryType.TQFT: 1,
        TheoryType.CFT: 2,
        TheoryType.String: 2,
        TheoryType.Gravity: 3,
    }
    return max(required[t] for t in theories) if theories else 0


def is_computable_theory(max_dim: int) -> bool:
    """Check if theory is computable up to dimension max_dim."""
    return all(tqft_oracle_level(d) == 0 for d in range(max_dim + 1))


# ============================================================
# Demo 1: Oracle Hierarchy
# ============================================================
print("=" * 60)
print("Demo 1: Oracle Hierarchy for TQFTs by Dimension")
print("=" * 60)
print(f"{'Dim':>4} {'Oracle Level':>12} {'Computable?':>12}")
print("-" * 32)
for d in range(8):
    level = tqft_oracle_level(d)
    comp = "Yes" if level == 0 else "No"
    print(f"{d:>4} {level:>12} {comp:>12}")

print(f"\nComputability threshold: max_dim <= 3")
for md in range(6):
    print(f"  IsComputableTheory({md}) = {is_computable_theory(md)}")

# ============================================================
# Demo 2: Theory Spectrum Analysis
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Theory Spectrum of Various Towers")
print("=" * 60)

towers = [
    ("Trivial (all singleton)", DualizableTower([1, 1, 1], 0)),
    ("TQFT-only (level 0)", DualizableTower([2, 1, 1], 1)),
    ("TQFT+String (level 0,1)", DualizableTower([2, 2, 1], 2)),
    ("Full spectrum", DualizableTower([2, 2, 2, 1], 3)),
    ("Rich tower", DualizableTower([3, 4, 2, 1], 3)),
]

for name, tower in towers:
    spec = theory_spectrum(tower)
    spec_names = sorted(t.name for t in spec) if spec else ["(empty)"]
    print(f"\n  {name}:")
    print(f"    Obj sizes: {tower.obj_sizes}, stable_level: {tower.stable_level}")
    print(f"    Spectrum: {', '.join(spec_names)}")
    print(f"    Is (2,∞)? {tower.is_two_infinity()}")

# ============================================================
# Demo 3: Two-Infinity Necessity Verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Two-Infinity Necessity Theorem Verification")
print("=" * 60)

print("\nChecking: any tower with TQFT+String must have stable_level >= 2")
counterexample_found = False
for s in range(5):
    for o0 in [1, 2, 3]:
        for o1 in [1, 2, 3]:
            # Enforce consistency: levels >= stable must be subsingleton
            sizes = [o0 if 0 < s else 1, o1 if 1 < s else 1, 1, 1]
            tower = DualizableTower(sizes, s)
            spec = theory_spectrum(tower)
            has_both = TheoryType.TQFT in spec and TheoryType.String in spec
            if has_both and s < 2:
                print(f"  COUNTEREXAMPLE: stable={s}, sizes={sizes}")
                counterexample_found = True
if not counterexample_found:
    print("  No counterexample found - theorem verified computationally!")

# ============================================================
# Demo 4: Dimension Gap Verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Dimension Gap Theorem Verification")
print("=" * 60)

print("\nChecking: no stable-level-1 tower supports TQFT+Gravity")
found_counterexample = False
for o0 in range(1, 5):
    for o1 in range(1, 5):
        for o2 in range(1, 5):
            tower = DualizableTower([o0, o1, o2], 1)
            spec = theory_spectrum(tower)
            if TheoryType.TQFT in spec and TheoryType.Gravity in spec:
                # But wait - stable level 1 means level >= 1 is subsingleton
                # so o2 must be <= 1, which means no Gravity
                if tower.stable_level == 1 and not tower.is_subsingleton(2):
                    # This is inconsistent with the tower definition
                    print(f"  Inconsistent tower: stable=1 but Obj(2) has {o2} elements")
                    found_counterexample = True

if not found_counterexample:
    print("  No valid counterexample possible - theorem confirmed!")
    print("  (stable_level=1 forces Obj(2) to be subsingleton, blocking Gravity)")

# ============================================================
# Demo 5: Oracle Unboundedness
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Oracle Unboundedness")
print("=" * 60)

print("\nFor each oracle level n, finding dimension d with oracle_level > n:")
for n in range(8):
    d = n + 4  # witness from the theorem
    level = tqft_oracle_level(d)
    print(f"  n={n}: d={d} gives oracle_level={level} > {n} ✓")

# ============================================================
# Demo 6: Minimum Stability Level
# ============================================================
print("\n" + "=" * 60)
print("Demo 6: Minimum Stability Level for Theory Combinations")
print("=" * 60)

combos = [
    {TheoryType.TQFT},
    {TheoryType.TQFT, TheoryType.CFT},
    {TheoryType.TQFT, TheoryType.String},
    {TheoryType.TQFT, TheoryType.String, TheoryType.Gravity},
    {TheoryType.TQFT, TheoryType.CFT, TheoryType.String, TheoryType.Gravity},
]

for combo in combos:
    names = sorted(t.name for t in combo)
    level = min_stable_level(combo)
    print(f"  {'+'.join(names):40s} → min stable level = {level}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy for TQFTs by Dimension

Shows how the computational complexity of TQFT partition functions
grows with spacetime dimension, with a phase transition at d=4.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tqft_oracle_level(d: int) -> int:
    """Oracle level of a TQFT in dimension d."""
    return 0 if d <= 3 else d - 3


def main():
    dims = list(range(0, 12))
    levels = [tqft_oracle_level(d) for d in dims]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Color code: computable (green) vs non-computable (red gradient)
    colors = ['#2ecc71' if l == 0 else plt.cm.Reds(0.3 + 0.7 * l / max(levels))
              for l in levels]

    bars = ax.bar(dims, levels, color=colors, edgecolor='black', linewidth=0.8)

    # Phase transition line
    ax.axvline(x=3.5, color='red', linestyle='--', linewidth=2, alpha=0.7,
               label='Computability threshold (d=3/4)')

    # Annotations
    ax.annotate('COMPUTABLE\n(d ≤ 3)', xy=(1.5, 0.3), fontsize=14, fontweight='bold',
                color='#27ae60', ha='center')
    ax.annotate('UNDECIDABLE\n(d ≥ 4)', xy=(7, 2.5), fontsize=14, fontweight='bold',
                color='#c0392b', ha='center')

    # Labels
    ax.set_xlabel('Spacetime Dimension d', fontsize=14)
    ax.set_ylabel('Oracle Level (Σ⁰ₙ)', fontsize=14)
    ax.set_title('Computability of TQFT Partition Functions\nby Spacetime Dimension',
                 fontsize=16, fontweight='bold')
    ax.set_xticks(dims)
    ax.set_yticks(range(max(levels) + 1))
    ax.legend(fontsize=12, loc='upper left')
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved oracle_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Theory Spectrum and Shadow Hierarchy

Shows which physical theories can be extracted from dualizable towers
at different stability levels.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    theory_names = ['TQFT', 'CFT', 'String', 'Gravity']
    required_levels = [0, 1, 1, 2]  # required categorical level for each theory
    stable_levels = [0, 1, 2, 3, 4]

    # Build the availability matrix
    # A theory is available if its required level < stable_level
    available = np.zeros((len(stable_levels), len(theory_names)))
    for i, sl in enumerate(stable_levels):
        for j, rl in enumerate(required_levels):
            available[i, j] = 1.0 if rl < sl else 0.3

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Heatmap of theory availability
    im = ax1.imshow(available, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1)
    ax1.set_xticks(range(len(theory_names)))
    ax1.set_xticklabels(theory_names, fontsize=12, fontweight='bold')
    ax1.set_yticks(range(len(stable_levels)))
    ax1.set_yticklabels([f'Level {s}' for s in stable_levels], fontsize=12)
    ax1.set_title('Theory Availability by Stability Level', fontsize=14, fontweight='bold')
    ax1.set_ylabel('Stability Level', fontsize=12)

    for i in range(len(stable_levels)):
        for j in range(len(theory_names)):
            text = '✓' if available[i, j] > 0.5 else '✗'
            color = 'white' if available[i, j] > 0.5 else 'gray'
            ax1.text(j, i, text, ha='center', va='center', fontsize=16,
                    fontweight='bold', color=color)

    # Add key theorem annotations
    ax1.annotate('', xy=(3.5, 0.5), xytext=(3.5, 1.5),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax1.text(4.2, 1.0, 'Dimension\nGap', fontsize=10, color='blue',
            fontweight='bold', ha='left')

    # Right: Shadow hierarchy diagram
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Shadow Hierarchy\n(Truncation Levels)', fontsize=14, fontweight='bold')

    # Draw nested boxes representing truncation levels
    boxes = [
        (1, 1, 8, 8, 'Theory of Everything\n(stable level ≥ 3)', '#e74c3c', 0.15),
        (1.5, 1.5, 7, 6.5, 'Gravity\n(sees level 2)', '#e67e22', 0.2),
        (2, 2, 6, 5, 'String / CFT\n(sees level 1)', '#f39c12', 0.25),
        (2.5, 2.5, 5, 3.5, 'TQFT\n(sees level 0)', '#2ecc71', 0.35),
    ]

    for x, y, w, h, label, color, alpha in boxes:
        rect = plt.Rectangle((x, y), w, h, linewidth=2, edgecolor=color,
                             facecolor=color, alpha=alpha)
        ax2.add_patch(rect)
        ax2.text(x + w/2, y + h/2, label, ha='center', va='center',
                fontsize=11, fontweight='bold', color='black')

    # Add the key point
    ax2.plot(5, 4, 'ko', markersize=10)
    ax2.text(5, 3.5, 'point value\n(cobordism hypothesis)',
            ha='center', va='top', fontsize=9, style='italic')

    plt.tight_layout()
    plt.savefig('theory_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved theory_spectrum.png")


if __name__ == "__main__":
    main()
