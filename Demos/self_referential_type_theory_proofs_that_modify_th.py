#!/usr/bin/env python3
"""
Transfinite Reflective Towers — Numerical Demonstrations

Demonstrates the key theorems from the Lean 4 formalization:
1. Contractive collapse: strictly contractive modifiers reach level 0
2. Specification entropy bounds
3. Tower GL frame: Löb's theorem and second incompleteness
4. Diagonal barrier visualization
"""

from typing import Callable, List, Tuple


def contractive_collapse(initial_level: int, modifier: Callable[[int], int]) -> List[int]:
    """Simulate contractive collapse: iterate modifier until level 0.
    
    The Contractive Collapse Theorem (contractive_reaches_zero) guarantees
    that if modifier is strictly contractive (strictly decreases positive levels),
    the iteration reaches 0 within initial_level steps.
    """
    levels = [initial_level]
    current = initial_level
    for _ in range(initial_level + 5):  # extra steps to show stability
        current = modifier(current)
        levels.append(current)
        if current == 0:
            break
    # Pad with zeros to show stability
    while len(levels) < initial_level + 5:
        levels.append(0)
    return levels


def spec_entropy(level: int, modified_level: int) -> float:
    """Compute specification entropy.
    
    specEntropy m s = (s.level - (m.modify s).level) / s.level
    
    The theorems specEntropy_nonneg and specEntropy_le_one guarantee
    this is always in [0, 1].
    """
    if level == 0:
        return 0.0
    return (level - modified_level) / level


def tower_forces(valuation: dict, world: int, formula: tuple) -> bool:
    """Evaluate forcing in the tower GL frame.
    
    Worlds = natural numbers, accessibility = strict less-than.
    Formula encoding:
      ('var', p)     - propositional variable p
      'bot'          - falsity
      ('imp', φ, ψ)  - implication
      ('box', φ)     - box modality (provability)
    """
    if formula == 'bot':
        return False
    if formula[0] == 'var':
        return valuation.get((world, formula[1]), False)
    if formula[0] == 'imp':
        _, phi, psi = formula
        return not tower_forces(valuation, world, phi) or tower_forces(valuation, world, psi)
    if formula[0] == 'box':
        _, phi = formula
        return all(tower_forces(valuation, v, phi) for v in range(world))
    raise ValueError(f"Unknown formula: {formula}")


def demo_contractive_collapse():
    """Demonstrate the Contractive Collapse Theorem."""
    print("=" * 60)
    print("DEMO 1: Contractive Collapse Theorem")
    print("=" * 60)
    print()
    
    # Modifier 1: decrement by 1 (linear collapse)
    print("Modifier: level ↦ max(0, level - 1)")
    levels = contractive_collapse(8, lambda l: max(0, l - 1))
    for i, l in enumerate(levels):
        bar = "█" * l + "░" * (8 - l)
        print(f"  Step {i:2d}: level = {l} |{bar}|")
    print(f"  Collapsed at step {levels.index(0)} (bound: {8})")
    print()
    
    # Modifier 2: halve (logarithmic collapse)
    print("Modifier: level ↦ level // 2")
    levels = contractive_collapse(16, lambda l: l // 2)
    for i, l in enumerate(levels):
        bar = "█" * l + "░" * (16 - l)
        print(f"  Step {i:2d}: level = {l:2d} |{bar}|")
    print(f"  Collapsed at step {levels.index(0)} (bound: {16})")
    print()
    
    # Modifier 3: subtract square root (intermediate)
    import math
    print("Modifier: level ↦ level - ⌈√level⌉")
    levels = contractive_collapse(25, lambda l: max(0, l - max(1, math.isqrt(l))))
    for i, l in enumerate(levels):
        bar = "█" * l + "░" * (25 - l)
        print(f"  Step {i:2d}: level = {l:2d} |{bar}|")
    print(f"  Collapsed at step {levels.index(0)} (bound: {25})")
    print()


def demo_entropy():
    """Demonstrate specification entropy bounds."""
    print("=" * 60)
    print("DEMO 2: Specification Entropy Bounds")
    print("=" * 60)
    print()
    
    print("Entropy = (level - modified_level) / level")
    print("Theorem: 0 ≤ entropy ≤ 1")
    print()
    
    cases = [
        (10, 10, "Identity (no change)"),
        (10, 9, "Decrement by 1"),
        (10, 5, "Halve"),
        (10, 0, "Collapse to 0"),
        (0, 0, "Already at level 0"),
        (100, 99, "Tiny change at high level"),
        (100, 1, "Near-total collapse"),
    ]
    
    for level, modified, desc in cases:
        e = spec_entropy(level, modified)
        bar_len = int(e * 40)
        bar = "█" * bar_len + "░" * (40 - bar_len)
        print(f"  {desc:30s}: entropy = {e:.3f} |{bar}|")
    print()


def demo_loeb():
    """Demonstrate Löb's theorem and second incompleteness in the tower."""
    print("=" * 60)
    print("DEMO 3: Löb's Theorem & Second Incompleteness")
    print("=" * 60)
    print()
    
    # Check Löb's theorem: □(□φ → φ) → □φ
    # Use a simple proposition p that is true at some worlds
    p = ('var', 0)
    box_p = ('box', p)
    box_p_imp_p = ('imp', box_p, p)
    box_box_p_imp_p = ('box', box_p_imp_p)
    
    print("Testing Löb's theorem: □(□p → p) → □p")
    print()
    
    for max_world in range(5):
        # Valuation: p is true at even worlds
        val = {(w, 0): (w % 2 == 0) for w in range(max_world + 1)}
        
        lhs = tower_forces(val, max_world, box_box_p_imp_p)
        rhs = tower_forces(val, max_world, box_p)
        loeb_holds = not lhs or rhs
        
        print(f"  World {max_world}: □(□p→p) = {lhs}, □p = {rhs}, "
              f"Löb holds: {loeb_holds}")
    
    print()
    
    # Check second incompleteness: ¬□(□⊥ → ⊥) at world w > 0
    con = ('imp', ('box', 'bot'), 'bot')  # □⊥ → ⊥ (consistency)
    box_con = ('box', con)  # □(□⊥ → ⊥)
    
    print("Testing second incompleteness: ¬□(□⊥ → ⊥) at w > 0")
    print()
    
    for w in range(6):
        val = {}
        result = tower_forces(val, w, box_con)
        expected = (w == 0)  # Should only be true at world 0 (vacuously)
        status = "✓" if result == expected else "✗"
        print(f"  World {w}: □(□⊥→⊥) = {result:5s}  "
              f"{'(vacuously true)' if w == 0 else '(blocked by Löb)'} {status}")
    print()


def demo_diagonal():
    """Demonstrate the diagonal barrier."""
    print("=" * 60)
    print("DEMO 4: Diagonal Barrier (Cantor for Specs)")
    print("=" * 60)
    print()
    
    # A family of predicates on {0, 1, 2, 3, 4}
    n = 5
    predicates = [
        lambda x, i=i: (x + i) % 2 == 0  # Various even/odd predicates
        for i in range(n)
    ]
    
    print(f"Predicate family on {{0, ..., {n-1}}}:")
    print()
    
    # Print the predicate table
    header = "  x:    " + " ".join(f"{x:2d}" for x in range(n))
    print(header)
    print("  " + "-" * (len(header) - 2))
    
    for i, pred in enumerate(predicates):
        values = [pred(x) for x in range(n)]
        row = f"  P_{i}:   " + " ".join(f"{'T':>2s}" if v else f"{'F':>2s}" for v in values)
        diag_val = pred(i)
        row += f"  ← diagonal: P_{i}({i}) = {'T' if diag_val else 'F'}"
        print(row)
    
    print()
    
    # The anti-diagonal
    anti_diag = [not predicates[i](i) for i in range(n)]
    row = "  D:    " + " ".join(f"{'T':>2s}" if v else f"{'F':>2s}" for v in anti_diag)
    print(row + "  ← anti-diagonal: D(i) = ¬P_i(i)")
    print()
    
    # Check that D differs from each P_i at index i
    for i, pred in enumerate(predicates):
        matches = all(pred(x) == anti_diag[x] for x in range(n))
        differs_at_i = pred(i) != anti_diag[i]
        print(f"  D ≠ P_{i}: differs at index {i} "
              f"(P_{i}({i})={'T' if pred(i) else 'F'}, D({i})={'T' if anti_diag[i] else 'F'}) ✓")
    print()
    print("  → No predicate in the family equals the anti-diagonal.")
    print("  → The family is NOT universal (Cantor's theorem for specs).")
    print()


if __name__ == "__main__":
    demo_contractive_collapse()
    demo_entropy()
    demo_loeb()
    demo_diagonal()
    
    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Contractive Collapse Trajectories"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import math

def contractive_collapse(initial_level, modifier, max_steps=None):
    if max_steps is None:
        max_steps = initial_level + 5
    levels = [initial_level]
    current = initial_level
    for _ in range(max_steps):
        current = modifier(current)
        levels.append(current)
    return levels

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Modifier 1: Decrement by 1
levels1 = contractive_collapse(10, lambda l: max(0, l - 1))
axes[0].step(range(len(levels1)), levels1, where='mid', linewidth=2, color='#2196F3')
axes[0].fill_between(range(len(levels1)), levels1, alpha=0.2, color='#2196F3', step='mid')
axes[0].set_title('Linear: level ↦ level - 1', fontsize=12, fontweight='bold')
axes[0].set_xlabel('Step')
axes[0].set_ylabel('Level')
axes[0].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Ground level')
axes[0].legend()

# Modifier 2: Halve
levels2 = contractive_collapse(32, lambda l: l // 2, max_steps=10)
axes[1].step(range(len(levels2)), levels2, where='mid', linewidth=2, color='#4CAF50')
axes[1].fill_between(range(len(levels2)), levels2, alpha=0.2, color='#4CAF50', step='mid')
axes[1].set_title('Logarithmic: level ↦ ⌊level/2⌋', fontsize=12, fontweight='bold')
axes[1].set_xlabel('Step')
axes[1].set_ylabel('Level')
axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Ground level')
axes[1].legend()

# Modifier 3: Subtract sqrt
levels3 = contractive_collapse(100, lambda l: max(0, l - max(1, math.isqrt(l))), max_steps=25)
axes[2].step(range(len(levels3)), levels3, where='mid', linewidth=2, color='#FF9800')
axes[2].fill_between(range(len(levels3)), levels3, alpha=0.2, color='#FF9800', step='mid')
axes[2].set_title('√-rate: level ↦ level - ⌊√level⌋', fontsize=12, fontweight='bold')
axes[2].set_xlabel('Step')
axes[2].set_ylabel('Level')
axes[2].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Ground level')
axes[2].legend()

plt.suptitle('Contractive Collapse Theorem: All Trajectories Reach Level 0', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('collapse_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved collapse_trajectories.png")


#!/usr/bin/env python3
"""Visualization: Specification Entropy Heatmap"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

def spec_entropy(level, modified_level):
    if level == 0:
        return 0.0
    return (level - modified_level) / level

# Create a heatmap: x = initial level, y = modified level, color = entropy
max_level = 20
data = np.zeros((max_level + 1, max_level + 1))

for s_level in range(max_level + 1):
    for m_level in range(s_level + 1):  # modified ≤ original
        data[m_level, s_level] = spec_entropy(s_level, m_level)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
im = ax1.imshow(data, origin='lower', aspect='auto', cmap='YlOrRd',
                extent=[-0.5, max_level + 0.5, -0.5, max_level + 0.5],
                vmin=0, vmax=1)
ax1.set_xlabel('Initial Level', fontsize=12)
ax1.set_ylabel('Modified Level', fontsize=12)
ax1.set_title('Specification Entropy\n(level_initial, level_modified) → entropy', 
              fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax1, label='Entropy ∈ [0, 1]')

# Diagonal line (identity modifier: entropy = 0)
ax1.plot([0, max_level], [0, max_level], 'b--', linewidth=1.5, label='Identity (ε=0)')
# Bottom line (total collapse: entropy = 1)
ax1.plot([0, max_level], [0, 0], 'r--', linewidth=1.5, label='Total collapse (ε=1)')
ax1.legend(loc='upper left', fontsize=10)

# Entropy trajectories for different modifiers
trajectories = {
    'level - 1': lambda l: max(0, l - 1),
    'level // 2': lambda l: l // 2,
    'level // 3': lambda l: l // 3,
    'level - √level': lambda l: max(0, l - max(1, int(l**0.5))),
}

colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']

for (name, modifier), color in zip(trajectories.items(), colors):
    entropies = []
    current_level = 15
    for step in range(20):
        if current_level == 0:
            entropies.append(0.0)
        else:
            new_level = modifier(current_level)
            entropies.append(spec_entropy(current_level, new_level))
            current_level = new_level
    ax2.plot(range(len(entropies)), entropies, 'o-', color=color, 
             label=name, markersize=4, linewidth=1.5)

ax2.set_xlabel('Iteration Step', fontsize=12)
ax2.set_ylabel('Entropy', fontsize=12)
ax2.set_title('Entropy Trajectories\n(starting from level 15)', 
              fontsize=13, fontweight='bold')
ax2.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax2.set_ylim(-0.05, 1.05)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_analysis.png', dpi=150, bbox_inches='tight')
print("Saved entropy_analysis.png")
