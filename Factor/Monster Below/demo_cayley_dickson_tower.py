#!/usr/bin/env python3
"""
=============================================================================
DEMO 3: The Cayley-Dickson Tower — Division Algebras Below the Monster
=============================================================================

The Cayley-Dickson construction builds:
  ℝ → ℂ → ℍ → 𝕆 → 𝕊 → ...

At each level:
- Level 0 (ℝ): No Pythagorean structure
- Level 1 (ℂ): Two-square identity → Pythagorean TRIPLES → S¹
- Level 2 (ℍ): Four-square identity → Pythagorean QUADRUPLES → S² → Null cone
- Level 3 (𝕆): Eight-square identity → Pythagorean OCTUPLES → S⁶ → ??
- Level 4 (𝕊): Sixteen-square identity → NOT A DIVISION ALGEBRA!

The tower BREAKS at level 4 (sedenions) — and this breaking
corresponds to the impossibility of extending the Hopf fibration.

This program visualizes:
1. The norm-multiplicativity at each level
2. The algebraic properties lost at each step
3. The connection to Bott periodicity and K-theory

Run: python3 demo_cayley_dickson_tower.py
Output: cayley_dickson_tower.png, norm_multiplicativity.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch

# ============================================================================
# Cayley-Dickson Algebras
# ============================================================================

class CayleyDickson:
    """A Cayley-Dickson number represented as a pair of elements from the
    previous level, with conjugation rule (a,b)* = (a*, -b)."""

    def __init__(self, components):
        """components: list/array of real numbers, length must be power of 2."""
        self.components = np.array(components, dtype=float)
        self.dim = len(components)
        assert self.dim & (self.dim - 1) == 0, "Dimension must be power of 2"

    def conjugate(self):
        """Cayley-Dickson conjugation."""
        if self.dim == 1:
            return CayleyDickson([self.components[0]])
        result = self.components.copy()
        result[1:] = -result[1:]
        return CayleyDickson(result)

    def norm_sq(self):
        """Squared norm = sum of squares of components."""
        return np.sum(self.components**2)

    def __mul__(self, other):
        """Cayley-Dickson multiplication."""
        if self.dim == 1:
            return CayleyDickson([self.components[0] * other.components[0]])

        n = self.dim // 2
        a = CayleyDickson(self.components[:n])
        b = CayleyDickson(self.components[n:])
        c = CayleyDickson(other.components[:n])
        d = CayleyDickson(other.components[n:])

        # (a,b)(c,d) = (ac - d*b, da + bc*)
        d_conj = d.conjugate()
        c_conj = c.conjugate()

        part1 = a * c + CayleyDickson((-d_conj * b).components)
        part2 = d * a + b * c_conj

        return CayleyDickson(np.concatenate([part1.components, part2.components]))

    def __neg__(self):
        return CayleyDickson(-self.components)

    def __add__(self, other):
        return CayleyDickson(self.components + other.components)

    def __sub__(self, other):
        return CayleyDickson(self.components - other.components)

    def __repr__(self):
        names = {1: 'ℝ', 2: 'ℂ', 4: 'ℍ', 8: '𝕆', 16: '𝕊'}
        name = names.get(self.dim, f'CD({self.dim})')
        return f"{name}{list(np.round(self.components, 4))}"

# ============================================================================
# Experiment: Test Norm Multiplicativity at Each Level
# ============================================================================

def test_norm_multiplicativity(dim, n_trials=1000):
    """Test |xy|² = |x|²|y|² for random elements."""
    errors = []
    for _ in range(n_trials):
        x = CayleyDickson(np.random.randn(dim))
        y = CayleyDickson(np.random.randn(dim))
        xy = x * y

        expected = x.norm_sq() * y.norm_sq()
        actual = xy.norm_sq()

        if expected > 0:
            errors.append(abs(actual - expected) / expected)

    return np.mean(errors), np.max(errors)

def experiment_norm_tower():
    """Test norm multiplicativity up the Cayley-Dickson tower."""
    print("\n" + "="*60)
    print("EXPERIMENT: Norm Multiplicativity in the Cayley-Dickson Tower")
    print("="*60)
    print("\nTesting |x·y|² = |x|²·|y|² at each level:\n")

    names = {1: 'ℝ (Reals)', 2: 'ℂ (Complex)', 4: 'ℍ (Quaternions)',
             8: '𝕆 (Octonions)', 16: '𝕊 (Sedenions)', 32: 'CD(32)'}
    properties = {
        1: 'ordered, commutative, associative, division',
        2: 'commutative, associative, division',
        4: 'associative, division',
        8: 'alternative, division',
        16: 'NONE — not a division algebra!',
        32: 'NONE'
    }
    pyth_type = {
        1: '—',
        2: 'Pythagorean TRIPLES (S¹)',
        4: 'Pythagorean QUADRUPLES (S², null cone)',
        8: 'Pythagorean 8-TUPLES (S⁶)',
        16: 'BROKEN — zero divisors exist!',
        32: 'BROKEN'
    }

    results = {}
    for dim in [1, 2, 4, 8, 16, 32]:
        mean_err, max_err = test_norm_multiplicativity(dim)
        results[dim] = (mean_err, max_err)

        status = "✓ EXACT" if max_err < 1e-10 else "✗ BROKEN"
        print(f"  dim={dim:2d} ({names[dim]:20s}): "
              f"mean_err={mean_err:.2e}, max_err={max_err:.2e}  {status}")
        print(f"         Properties: {properties[dim]}")
        print(f"         Pythagorean: {pyth_type[dim]}\n")

    return results

# ============================================================================
# Experiment: Find Zero Divisors in Sedenions
# ============================================================================

def find_zero_divisors():
    """The sedenions (dim=16) have zero divisors: nonzero x,y with xy = 0.
    This is WHERE THE TOWER BREAKS."""
    print("="*60)
    print("EXPERIMENT: Zero Divisors in the Sedenions")
    print("="*60)
    print("\nSearching for nonzero x, y ∈ 𝕊 with x·y = 0...\n")

    # Known zero divisor pair in sedenions
    # e₃ + e₁₀ and e₅ - e₈ (using standard basis)
    # In our representation:
    x = np.zeros(16)
    x[3] = 1   # e₃
    x[10] = 1  # e₁₀

    y = np.zeros(16)
    y[5] = 1   # e₆
    y[8] = -1  # e₉

    X = CayleyDickson(x)
    Y = CayleyDickson(y)
    XY = X * Y

    print(f"  x = {X}")
    print(f"  y = {Y}")
    print(f"  x·y = {XY}")
    print(f"  |x|² = {X.norm_sq():.4f}")
    print(f"  |y|² = {Y.norm_sq():.4f}")
    print(f"  |x·y|² = {XY.norm_sq():.6f}")
    print(f"  |x|²·|y|² = {X.norm_sq() * Y.norm_sq():.4f}")

    # Check how close to zero
    if XY.norm_sq() < 1e-10:
        print(f"\n  ✓ FOUND ZERO DIVISOR! |x·y|² ≈ 0 but |x|²·|y|² = {X.norm_sq()*Y.norm_sq()}")
        print("  This PROVES the sedenions are not a division algebra!")
    else:
        print(f"\n  This pair gives |x·y|² = {XY.norm_sq():.6f}, searching more...")
        # Try random search
        for trial in range(10000):
            x = np.zeros(16)
            y = np.zeros(16)
            # Random sparse elements
            idx1 = np.random.choice(16, 2, replace=False)
            idx2 = np.random.choice(16, 2, replace=False)
            x[idx1] = np.random.choice([-1, 1], 2)
            y[idx2] = np.random.choice([-1, 1], 2)

            X = CayleyDickson(x)
            Y = CayleyDickson(y)
            XY = X * Y

            if X.norm_sq() > 0 and Y.norm_sq() > 0 and XY.norm_sq() < 1e-10:
                print(f"  ✓ FOUND ZERO DIVISOR at trial {trial}!")
                print(f"    x indices: {idx1}, y indices: {idx2}")
                print(f"    |x·y|² = {XY.norm_sq():.2e}")
                break

    print("\n  CONCLUSION: The Cayley-Dickson tower has exactly 4 levels")
    print("  of division algebras: ℝ, ℂ, ℍ, 𝕆. At level 5 (sedenions),")
    print("  zero divisors appear, breaking the norm multiplicativity")
    print("  that powers ALL Pythagorean-type identities.\n")

# ============================================================================
# Visualization: The Tower
# ============================================================================

def plot_cayley_dickson_tower():
    """Visualize the Cayley-Dickson tower with properties at each level."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 18))
    ax.set_xlim(0, 14)
    ax.set_ylim(-1, 20)
    ax.axis('off')
    ax.set_title("The Cayley-Dickson Tower: Inside-Out from the Bedrock\n"
                 "Each level doubles the dimension, loses one algebraic property",
                 fontsize=14, fontweight='bold', pad=20)

    levels = [
        (1, "ℝ — Real Numbers", "#2ecc71", "dim=1",
         "ordered · commutative · associative · division",
         "No Pythagorean structure\n1-square: just |a|² = a²",
         "The ground truth. All measurements are real."),
        (2, "ℂ — Complex Numbers", "#3498db", "dim=2",
         "commutative · associative · division",
         "2-SQUARE IDENTITY → Pythagorean TRIPLES\n"
         "(a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)²",
         "Gaussian integers ℤ[i] parametrize\nALL Pythagorean triples.\n"
         "Stereographic S¹ ↔ ℝ lives here."),
        (3, "ℍ — Quaternions", "#e74c3c", "dim=4",
         "associative · division",
         "4-SQUARE IDENTITY → Pythagorean QUADRUPLES\n"
         "Euler (1748): product of two sums of 4 squares = sum of 4 squares",
         "Hurwitz integers parametrize null cone points.\n"
         "Hopf fibration S³→S² lives here.\n"
         "LIGHT'S MOMENTUM is encoded here."),
        (4, "𝕆 — Octonions", "#f39c12", "dim=8",
         "alternative · division",
         "8-SQUARE IDENTITY → Pythagorean 8-TUPLES\n"
         "Degen (1818): product of two sums of 8 squares = sum of 8 squares",
         "Hopf fibration S⁷→S⁴ lives here.\n"
         "Connection to exceptional Lie groups G₂, F₄.\n"
         "String theory uses this level."),
        (5, "𝕊 — Sedenions", "#95a5a6", "dim=16",
         "⚠ ZERO DIVISORS — NOT a division algebra!",
         "16-square: Pfister's theorem gives an identity\n"
         "BUT norm is NOT multiplicative!",
         "THE TOWER BREAKS HERE.\n"
         "No more Pythagorean-type identities.\n"
         "Bott periodicity explains why: π₇(S⁴) = ℤ⊕ℤ₁₂"),
    ]

    for idx, (level, name, color, dim, props, identity, significance) in enumerate(levels):
        y = 18 - idx * 3.8

        # Main box
        box = FancyBboxPatch((1, y-0.8), 12, 2.8,
                             boxstyle="round,pad=0.2",
                             facecolor=color, alpha=0.15,
                             edgecolor=color, linewidth=2)
        ax.add_patch(box)

        # Level label
        ax.text(1.5, y+1.5, f"Level {level}", fontsize=10, fontweight='bold',
                color=color)
        ax.text(1.5, y+1.0, name, fontsize=12, fontweight='bold')
        ax.text(12.5, y+1.5, dim, fontsize=9, ha='right', color='gray')

        # Properties
        ax.text(1.5, y+0.4, f"Properties: {props}", fontsize=8,
                color='#555555', style='italic')

        # Identity
        ax.text(1.5, y-0.2, identity, fontsize=7, color='#333333',
                family='monospace')

        # Significance
        ax.text(8.5, y-0.2, significance, fontsize=7, color=color,
                ha='left', va='top')

        # Arrow between levels
        if idx < len(levels) - 1:
            ax.annotate('', xy=(7, y-0.8), xytext=(7, y-1.5),
                       arrowprops=dict(arrowstyle='->', color='gray',
                                      lw=2, ls='--'))
            ax.text(7.5, y-1.15, "Cayley-Dickson\nconstruction", fontsize=7,
                    color='gray', ha='left', va='center')

    # Bottom annotation
    ax.text(7, 0.3,
            "The Monster Tower sits ABOVE all of this.\n"
            "Its singularity classes are controlled by the division algebra structure below.\n"
            "The 4 division algebras ↔ the 4 Hopf fibrations ↔ the 4 levels of the inside-out tower.",
            fontsize=9, ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='orange',
                     alpha=0.8, pad=0.5))

    plt.savefig('/workspace/request-project/MonsterBelow/cayley_dickson_tower.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved cayley_dickson_tower.png")

# ============================================================================
# Visualization: Norm Multiplicativity Error
# ============================================================================

def plot_norm_errors(results):
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title("Norm Multiplicativity Error Across the Cayley-Dickson Tower\n"
                 "|x·y|² vs |x|²·|y|²", fontsize=13, fontweight='bold')

    dims = list(results.keys())
    means = [results[d][0] for d in dims]
    maxes = [results[d][1] for d in dims]

    names = {1: 'ℝ', 2: 'ℂ', 4: 'ℍ', 8: '𝕆', 16: '𝕊', 32: 'CD(32)'}
    labels = [f'{names[d]}\n(dim={d})' for d in dims]

    colors = ['#2ecc71', '#3498db', '#e74c3c', '#f39c12', '#95a5a6', '#7f8c8d']

    bars = ax.bar(range(len(dims)), [max(m, 1e-16) for m in maxes],
                  color=colors, alpha=0.7, edgecolor='black')
    ax.set_xticks(range(len(dims)))
    ax.set_xticklabels(labels)
    ax.set_ylabel('Maximum Relative Error', fontsize=11)
    ax.set_yscale('log')

    # Annotate
    for i, (dim, maxe) in enumerate(zip(dims, maxes)):
        if maxe < 1e-10:
            ax.text(i, max(maxe, 1e-16) * 2, '✓ EXACT', ha='center',
                    fontsize=9, color='green', fontweight='bold')
        else:
            ax.text(i, maxe * 2, f'✗ {maxe:.1e}', ha='center',
                    fontsize=9, color='red', fontweight='bold')

    ax.axhline(y=1e-10, color='green', linestyle='--', alpha=0.5, label='Machine precision')
    ax.legend()
    ax.grid(True, axis='y', alpha=0.3)

    # Annotation
    ax.annotate('← Division Algebras →', xy=(0.3, 0.02), xycoords='axes fraction',
               fontsize=10, color='green', fontweight='bold')
    ax.annotate('← Broken →', xy=(0.75, 0.02), xycoords='axes fraction',
               fontsize=10, color='red', fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/MonsterBelow/norm_multiplicativity.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved norm_multiplicativity.png")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  The Cayley-Dickson Tower: Division Algebras Explorer   ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    results = experiment_norm_tower()
    find_zero_divisors()

    print("Generating visualizations...")
    plot_cayley_dickson_tower()
    plot_norm_errors(results)

    print("\n" + "="*60)
    print("META-ORACLE SYNTHESIS")
    print("="*60)
    print("""
    The Cayley-Dickson tower reveals that the mathematics "below"
    the Monster Tower has EXACTLY 4 levels (ℝ, ℂ, ℍ, 𝕆):

    • ℝ: The ground truth (measurements)
    • ℂ: Pythagorean triples (rational points on circles)
    • ℍ: Light's momentum (null cone of Minkowski space)
    • 𝕆: String theory (exceptional geometry)

    Below ℝ there is nothing. Above 𝕆 the tower breaks.

    The "inside-out" journey through inverse stereographic projection
    descends from the Monster Tower through these 4 levels:

    Monster Tower → Null Cone → Pythagorean Triples → Gaussian Integers → ℝ

    Each transition is a PROJECTION (stereographic or Hopf),
    and each projection LOSES exactly one algebraic property
    while GAINING arithmetic structure.

    This is the meta-oracle's revelation: the bedrock of all
    geometric singularity theory is the simple fact that
    THERE ARE EXACTLY 4 REAL DIVISION ALGEBRAS.
    """)
