"""
Coherent Paradox Systems: Interactive Demo

Demonstrates the key properties of Belnap's four-valued logic and
Coherent Paradox Systems, including:
- Truth table computation
- CPS construction
- Self-soundness verification
- Paradox-Soundness Duality
"""

from enum import Enum
from typing import List, Dict, Tuple, Optional
from itertools import product


class BelnapVal(Enum):
    """Four-valued truth space."""
    T = "T"  # True only
    F = "F"  # False only
    B = "B"  # Both true and false (dialetheia)
    N = "N"  # Neither true nor false (gap)

    def is_true(self) -> bool:
        return self in (BelnapVal.T, BelnapVal.B)

    def is_false(self) -> bool:
        return self in (BelnapVal.F, BelnapVal.B)

    def neg(self) -> 'BelnapVal':
        return {
            BelnapVal.T: BelnapVal.F,
            BelnapVal.F: BelnapVal.T,
            BelnapVal.B: BelnapVal.B,
            BelnapVal.N: BelnapVal.N,
        }[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        table = {
            (BelnapVal.T, BelnapVal.T): BelnapVal.T,
            (BelnapVal.T, BelnapVal.F): BelnapVal.F,
            (BelnapVal.T, BelnapVal.B): BelnapVal.B,
            (BelnapVal.T, BelnapVal.N): BelnapVal.N,
            (BelnapVal.F, BelnapVal.T): BelnapVal.F,
            (BelnapVal.F, BelnapVal.F): BelnapVal.F,
            (BelnapVal.F, BelnapVal.B): BelnapVal.F,
            (BelnapVal.F, BelnapVal.N): BelnapVal.F,
            (BelnapVal.B, BelnapVal.T): BelnapVal.B,
            (BelnapVal.B, BelnapVal.F): BelnapVal.F,
            (BelnapVal.B, BelnapVal.B): BelnapVal.B,
            (BelnapVal.B, BelnapVal.N): BelnapVal.F,
            (BelnapVal.N, BelnapVal.T): BelnapVal.N,
            (BelnapVal.N, BelnapVal.F): BelnapVal.F,
            (BelnapVal.N, BelnapVal.B): BelnapVal.F,
            (BelnapVal.N, BelnapVal.N): BelnapVal.N,
        }
        return table[(self, other)]

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        table = {
            (BelnapVal.T, BelnapVal.T): BelnapVal.T,
            (BelnapVal.T, BelnapVal.F): BelnapVal.T,
            (BelnapVal.T, BelnapVal.B): BelnapVal.T,
            (BelnapVal.T, BelnapVal.N): BelnapVal.T,
            (BelnapVal.F, BelnapVal.T): BelnapVal.T,
            (BelnapVal.F, BelnapVal.F): BelnapVal.F,
            (BelnapVal.F, BelnapVal.B): BelnapVal.B,
            (BelnapVal.F, BelnapVal.N): BelnapVal.N,
            (BelnapVal.B, BelnapVal.T): BelnapVal.T,
            (BelnapVal.B, BelnapVal.F): BelnapVal.B,
            (BelnapVal.B, BelnapVal.B): BelnapVal.B,
            (BelnapVal.B, BelnapVal.N): BelnapVal.T,
            (BelnapVal.N, BelnapVal.T): BelnapVal.T,
            (BelnapVal.N, BelnapVal.F): BelnapVal.N,
            (BelnapVal.N, BelnapVal.B): BelnapVal.T,
            (BelnapVal.N, BelnapVal.N): BelnapVal.N,
        }
        return table[(self, other)]


class CPS:
    """Coherent Paradox System on n sentences."""

    def __init__(self, truth_values: List[BelnapVal]):
        self.n = len(truth_values)
        self.truth = truth_values

    @property
    def dialectheia_degree(self) -> int:
        return sum(1 for v in self.truth if v == BelnapVal.B)

    @property
    def true_degree(self) -> int:
        return sum(1 for v in self.truth if v == BelnapVal.T)

    @property
    def false_degree(self) -> int:
        return sum(1 for v in self.truth if v == BelnapVal.F)

    @property
    def gap_degree(self) -> int:
        return sum(1 for v in self.truth if v == BelnapVal.N)

    def is_coherent(self) -> bool:
        """Check CPS axioms: has B, T, and F sentences."""
        return (any(v == BelnapVal.B for v in self.truth) and
                any(v == BelnapVal.T for v in self.truth) and
                any(v == BelnapVal.F for v in self.truth))

    def is_self_sound(self, provable: List[int]) -> bool:
        """Check self-soundness for a provable set."""
        return all(self.truth[i].is_true() for i in provable)

    def max_sound_provable_set(self) -> List[int]:
        """Return the maximal sound provable set (T ∨ B sentences)."""
        return [i for i in range(self.n) if self.truth[i].is_true()]


def print_truth_tables():
    """Print the FDE truth tables."""
    vals = list(BelnapVal)

    print("=" * 60)
    print("BELNAP FOUR-VALUED LOGIC TRUTH TABLES")
    print("=" * 60)

    print("\nNegation:")
    print(f"  {'v':>3} | {'¬v':>3}")
    print(f"  {'-'*3}-+-{'-'*3}")
    for v in vals:
        print(f"  {v.value:>3} | {v.neg().value:>3}")

    print("\nConjunction (∧):")
    print(f"  {'∧':>3} | " + " | ".join(f"{v.value:>3}" for v in vals))
    print(f"  {'-'*3}-+-" + "-+-".join(f"{'-'*3}" for _ in vals))
    for v1 in vals:
        row = " | ".join(f"{v1.conj(v2).value:>3}" for v2 in vals)
        print(f"  {v1.value:>3} | {row}")

    print("\nDisjunction (∨):")
    print(f"  {'∨':>3} | " + " | ".join(f"{v.value:>3}" for v in vals))
    print(f"  {'-'*3}-+-" + "-+-".join(f"{'-'*3}" for _ in vals))
    for v1 in vals:
        row = " | ".join(f"{v1.disj(v2).value:>3}" for v2 in vals)
        print(f"  {v1.value:>3} | {row}")


def demo_negation_fixed_points():
    """Demonstrate negation fixed points."""
    print("\n" + "=" * 60)
    print("NEGATION FIXED POINTS (Paradox Enablers)")
    print("=" * 60)

    for v in BelnapVal:
        is_fixed = v.neg() == v
        mark = " ← FIXED POINT (paradox-enabling)" if is_fixed else ""
        print(f"  neg({v.value}) = {v.neg().value}{mark}")


def demo_minimal_cps():
    """Demonstrate the minimal CPS on 3 elements."""
    print("\n" + "=" * 60)
    print("MINIMAL COHERENT PARADOX SYSTEM (3 sentences)")
    print("=" * 60)

    cps = CPS([BelnapVal.B, BelnapVal.T, BelnapVal.F])

    print("\nSentences:")
    labels = ["Liar ('This sentence is false')",
              "Tautology ('2 + 2 = 4')",
              "Absurdity ('0 = 1')"]
    for i in range(3):
        print(f"  s{i}: {labels[i]:40s} → truth = {cps.truth[i].value}")

    print(f"\nCoherent: {cps.is_coherent()}")
    print(f"Dialectheia degree: {cps.dialectheia_degree}")
    print(f"True degree: {cps.true_degree}")
    print(f"False degree: {cps.false_degree}")
    print(f"Gap degree: {cps.gap_degree}")

    # Value partition
    total = cps.true_degree + cps.false_degree + cps.dialectheia_degree + cps.gap_degree
    print(f"\nValue Partition: {cps.true_degree} + {cps.false_degree} + "
          f"{cps.dialectheia_degree} + {cps.gap_degree} = {total} = n ✓")

    # Self-soundness
    max_provable = cps.max_sound_provable_set()
    print(f"\nMaximal sound provable set: {max_provable}")
    print(f"  Contains Liar (s0, B-valued): {0 in max_provable}")
    print(f"  Contains Tautology (s1, T-valued): {1 in max_provable}")
    print(f"  Self-sound: {cps.is_self_sound(max_provable)}")

    # Paradox-Soundness Duality
    print(f"\nParadox-Soundness Duality:")
    print(f"  |max provable set| = {len(max_provable)}")
    print(f"  trueDegree + dialetheiaDegree = {cps.true_degree} + {cps.dialectheia_degree} "
          f"= {cps.true_degree + cps.dialectheia_degree} ✓")


def demo_explosion_failure():
    """Demonstrate that explosion fails in FDE."""
    print("\n" + "=" * 60)
    print("EXPLOSION FAILURE: B ∧ ¬B ≠ T")
    print("=" * 60)

    B = BelnapVal.B
    result = B.conj(B.neg())
    print(f"  B ∧ ¬B = B ∧ B = {result.value}")
    print(f"  Result is T? {result == BelnapVal.T}")
    print(f"  → Contradiction does NOT yield everything!")

    print("\n  Classical comparison:")
    T = BelnapVal.T
    print(f"  T ∧ ¬T = T ∧ F = {T.conj(T.neg()).value}")
    print(f"  F ∧ ¬F = F ∧ T = {BelnapVal.F.conj(BelnapVal.F.neg()).value}")


def demo_excluded_middle_failure():
    """Demonstrate excluded middle failure."""
    print("\n" + "=" * 60)
    print("EXCLUDED MIDDLE FAILURE")
    print("=" * 60)

    for v in BelnapVal:
        result = v.disj(v.neg())
        is_true = result.is_true()
        mark = "" if is_true else " ← EXCLUDED MIDDLE FAILS"
        print(f"  {v.value} ∨ ¬{v.value} = {v.value} ∨ {v.neg().value} = "
              f"{result.value} (at-least-true: {is_true}){mark}")


def demo_larger_cps():
    """Demonstrate a larger CPS with multiple dialetheias."""
    print("\n" + "=" * 60)
    print("LARGER CPS (6 sentences, 2 dialetheias)")
    print("=" * 60)

    cps = CPS([BelnapVal.B, BelnapVal.B, BelnapVal.T, BelnapVal.T, BelnapVal.F, BelnapVal.N])

    print("\nSentences:")
    labels = ["Liar₁", "Liar₂", "Theorem₁", "Theorem₂", "Falsehood", "Unknown"]
    for i in range(6):
        print(f"  s{i}: {labels[i]:15s} → truth = {cps.truth[i].value}")

    print(f"\nDegrees: B={cps.dialectheia_degree}, T={cps.true_degree}, "
          f"F={cps.false_degree}, N={cps.gap_degree}")
    print(f"Partition: {cps.true_degree}+{cps.false_degree}+"
          f"{cps.dialectheia_degree}+{cps.gap_degree} = "
          f"{cps.true_degree + cps.false_degree + cps.dialectheia_degree + cps.gap_degree}")

    max_provable = cps.max_sound_provable_set()
    print(f"\nMax sound provable set: {max_provable} (size {len(max_provable)})")
    print(f"trueDegree + dialetheiaDegree = {cps.true_degree + cps.dialectheia_degree}")
    print(f"Bounds: 1 ≤ {cps.dialectheia_degree} ≤ {cps.n - 2} = n-2 ✓")


def demo_flexible_conjecture():
    """Test the flexible CPS conjecture for small n."""
    print("\n" + "=" * 60)
    print("FLEXIBLE CPS CONJECTURE TEST")
    print("=" * 60)

    for n in range(3, 8):
        valid_k = list(range(1, n - 1))
        results = []
        for k in valid_k:
            # Construct: k B's, then 1 T, then 1 F, then N's
            truth = ([BelnapVal.B] * k +
                     [BelnapVal.T] +
                     [BelnapVal.F] +
                     [BelnapVal.N] * (n - k - 2))
            cps = CPS(truth)
            ok = cps.is_coherent() and cps.dialectheia_degree == k
            results.append((k, ok))

        status = "✓" if all(ok for _, ok in results) else "✗"
        k_results = ", ".join(f"k={k}:{'✓' if ok else '✗'}" for k, ok in results)
        print(f"  n={n}: {k_results}  [{status}]")


if __name__ == "__main__":
    print_truth_tables()
    demo_negation_fixed_points()
    demo_minimal_cps()
    demo_explosion_failure()
    demo_excluded_middle_failure()
    demo_larger_cps()
    demo_flexible_conjecture()
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


"""
Visualization: Paradox-Soundness Duality
Shows how dialectheia degree affects the maximal sound provable set.
"""

import matplotlib.pyplot as plt
import numpy as np


def make_duality_figure():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Paradox-Soundness Duality in Coherent Paradox Systems',
                 fontsize=15, fontweight='bold')

    # Left: Stacked bar chart of value partition
    n_values = [3, 4, 5, 6, 7, 8]
    for idx, n in enumerate(n_values):
        k_values = list(range(1, n - 1))
        for k in k_values:
            t_deg = 1
            f_deg = 1
            b_deg = k
            n_deg = n - k - 2

            x = idx * 1.5 + (k - 1) * 0.15
            ax1.bar(x, t_deg, 0.12, color='#2196F3', alpha=0.8)
            ax1.bar(x, f_deg, 0.12, bottom=t_deg, color='#F44336', alpha=0.8)
            ax1.bar(x, b_deg, 0.12, bottom=t_deg+f_deg, color='#9C27B0', alpha=0.8)
            if n_deg > 0:
                ax1.bar(x, n_deg, 0.12, bottom=t_deg+f_deg+b_deg, color='#9E9E9E', alpha=0.8)

    ax1.set_xlabel('n (sentence count)', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title('Value Partition for Various CPS', fontsize=13)
    ax1.set_xticks([i * 1.5 for i in range(len(n_values))])
    ax1.set_xticklabels([f'n={n}' for n in n_values])

    import matplotlib.patches as mpatches
    patches = [mpatches.Patch(color=c, label=l)
               for c, l in [('#2196F3', 'T'), ('#F44336', 'F'),
                             ('#9C27B0', 'B'), ('#9E9E9E', 'N')]]
    ax1.legend(handles=patches, loc='upper left')

    # Right: Duality plot
    ns = list(range(3, 15))
    for n in ns:
        ks = list(range(1, n - 1))
        max_provable = [k + 1 for k in ks]  # trueDeg=1, so max = 1 + k
        ax2.scatter([n]*len(ks), max_provable, c=['#9C27B0'],
                    s=30 + 10*np.array(ks), alpha=0.7)

    # Boundary lines
    ax2.plot(ns, [1]*len(ns), 'b--', alpha=0.5, label='Min (k=0, classical)')
    ax2.plot(ns, [n-1 for n in ns], 'r--', alpha=0.5, label='Max (k=n-2)')
    ax2.fill_between(ns, [2]*len(ns), [n-1 for n in ns],
                     alpha=0.1, color='purple')

    ax2.set_xlabel('n (sentence count)', fontsize=12)
    ax2.set_ylabel('Max sound provable set size', fontsize=12)
    ax2.set_title('Paradox-Soundness Duality:\nMore paradoxes → larger provable set',
                  fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_xlim(2.5, 14.5)

    plt.tight_layout()
    plt.savefig('cps_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved cps_duality.png")


if __name__ == "__main__":
    make_duality_figure()


"""
Visualization: Belnap Four-Valued Logic Truth Tables
Self-contained matplotlib visualization.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_truth_table_figure():
    vals = ['T', 'F', 'B', 'N']
    colors = {'T': '#2196F3', 'F': '#F44336', 'B': '#9C27B0', 'N': '#9E9E9E'}

    neg_table = {'T': 'F', 'F': 'T', 'B': 'B', 'N': 'N'}

    conj_table = {
        ('T','T'): 'T', ('T','F'): 'F', ('T','B'): 'B', ('T','N'): 'N',
        ('F','T'): 'F', ('F','F'): 'F', ('F','B'): 'F', ('F','N'): 'F',
        ('B','T'): 'B', ('B','F'): 'F', ('B','B'): 'B', ('B','N'): 'F',
        ('N','T'): 'N', ('N','F'): 'F', ('N','B'): 'F', ('N','N'): 'N',
    }

    disj_table = {
        ('T','T'): 'T', ('T','F'): 'T', ('T','B'): 'T', ('T','N'): 'T',
        ('F','T'): 'T', ('F','F'): 'F', ('F','B'): 'B', ('F','N'): 'N',
        ('B','T'): 'T', ('B','F'): 'B', ('B','B'): 'B', ('B','N'): 'T',
        ('N','T'): 'T', ('N','F'): 'N', ('N','B'): 'T', ('N','N'): 'N',
    }

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Belnap Four-Valued Logic (FDE) Truth Tables', fontsize=16, fontweight='bold')

    # Negation
    ax = axes[0]
    ax.set_title('Negation (¬)', fontsize=14)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['v', '¬v'], fontsize=12)
    ax.set_yticks(range(4))
    ax.set_yticklabels(['' for _ in range(4)])
    ax.invert_yaxis()

    for i, v in enumerate(vals):
        nv = neg_table[v]
        ax.add_patch(plt.Rectangle((-0.4, i-0.4), 0.8, 0.8, facecolor=colors[v], alpha=0.7))
        ax.text(0, i, v, ha='center', va='center', fontsize=14, fontweight='bold', color='white')
        ax.add_patch(plt.Rectangle((0.6, i-0.4), 0.8, 0.8, facecolor=colors[nv], alpha=0.7))
        ax.text(1, i, nv, ha='center', va='center', fontsize=14, fontweight='bold', color='white')
        if v == nv:
            ax.annotate('fixed!', xy=(1.5, i), fontsize=10, color='red', fontweight='bold')

    ax.set_frame_on(False)
    ax.tick_params(left=False, bottom=False)

    # Conjunction
    ax = axes[1]
    ax.set_title('Conjunction (∧)', fontsize=14)
    data = np.zeros((4, 4), dtype=int)
    for i, v1 in enumerate(vals):
        for j, v2 in enumerate(vals):
            result = conj_table[(v1, v2)]
            data[i, j] = vals.index(result)

    color_map = np.array([[colors[conj_table[(v1, v2)]] for v2 in vals] for v1 in vals])
    for i in range(4):
        for j in range(4):
            result = conj_table[(vals[i], vals[j])]
            ax.add_patch(plt.Rectangle((j-0.4, i-0.4), 0.8, 0.8, facecolor=colors[result], alpha=0.7))
            ax.text(j, i, result, ha='center', va='center', fontsize=13, fontweight='bold', color='white')

    ax.set_xticks(range(4))
    ax.set_xticklabels(vals, fontsize=12)
    ax.set_yticks(range(4))
    ax.set_yticklabels(vals, fontsize=12)
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.invert_yaxis()
    ax.set_frame_on(False)
    ax.tick_params(left=False, bottom=False)

    # Disjunction
    ax = axes[2]
    ax.set_title('Disjunction (∨)', fontsize=14)
    for i in range(4):
        for j in range(4):
            result = disj_table[(vals[i], vals[j])]
            ax.add_patch(plt.Rectangle((j-0.4, i-0.4), 0.8, 0.8, facecolor=colors[result], alpha=0.7))
            ax.text(j, i, result, ha='center', va='center', fontsize=13, fontweight='bold', color='white')

    ax.set_xticks(range(4))
    ax.set_xticklabels(vals, fontsize=12)
    ax.set_yticks(range(4))
    ax.set_yticklabels(vals, fontsize=12)
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.invert_yaxis()
    ax.set_frame_on(False)
    ax.tick_params(left=False, bottom=False)

    # Legend
    patches = [mpatches.Patch(color=colors[v], label=f'{v}: {desc}')
               for v, desc in [('T', 'True'), ('F', 'False'),
                               ('B', 'Both (dialetheia)'), ('N', 'Neither (gap)')]]
    fig.legend(handles=patches, loc='lower center', ncol=4, fontsize=11)

    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    plt.savefig('truth_tables.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved truth_tables.png")


if __name__ == "__main__":
    make_truth_table_figure()
