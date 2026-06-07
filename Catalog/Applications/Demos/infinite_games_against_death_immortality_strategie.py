#!/usr/bin/env python3
"""
Mortality Games: Ordinal Survival Against Transfinite Adversaries
=================================================================
Demonstration of key concepts from the formal verification.

This demo illustrates:
1. Finite game tree evaluation (minimax)
2. The omega survival phenomenon
3. Cantor normal form decomposition
4. The absorption principle
"""

from dataclasses import dataclass
from typing import List, Optional, Tuple
import math


# ============================================================
# 1. Ordinal Arithmetic (finite approximation)
# ============================================================

@dataclass
class Ordinal:
    """Represents ordinals below ω² as ω·a + b."""
    omega_coeff: int  # coefficient of ω
    finite_part: int  # finite remainder

    def __post_init__(self):
        assert self.omega_coeff >= 0 and self.finite_part >= 0

    @classmethod
    def finite(cls, n: int) -> 'Ordinal':
        return cls(0, n)

    @classmethod
    def omega(cls) -> 'Ordinal':
        return cls(1, 0)

    @classmethod
    def omega_times(cls, k: int) -> 'Ordinal':
        return cls(k, 0)

    @classmethod
    def omega_sq(cls) -> 'Ordinal':
        """ω² represented as a sentinel."""
        return cls(999999, 0)  # sentinel for ω²

    def __lt__(self, other: 'Ordinal') -> bool:
        if self.omega_coeff != other.omega_coeff:
            return self.omega_coeff < other.omega_coeff
        return self.finite_part < other.finite_part

    def __le__(self, other: 'Ordinal') -> bool:
        return self == other or self < other

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Ordinal):
            return False
        return self.omega_coeff == other.omega_coeff and self.finite_part == other.finite_part

    def __repr__(self) -> str:
        if self.omega_coeff == 0:
            return str(self.finite_part)
        elif self.omega_coeff == 1 and self.finite_part == 0:
            return "ω"
        elif self.finite_part == 0:
            return f"ω·{self.omega_coeff}"
        elif self.omega_coeff == 1:
            return f"ω+{self.finite_part}"
        else:
            return f"ω·{self.omega_coeff}+{self.finite_part}"

    def __add__(self, other: 'Ordinal') -> 'Ordinal':
        """Ordinal addition (left addition absorbs finite parts)."""
        if other.omega_coeff > 0:
            # n + (ω·a + b) = ω·a + b when self is finite
            if self.omega_coeff == 0:
                return other
            else:
                return Ordinal(self.omega_coeff + other.omega_coeff, other.finite_part)
        else:
            return Ordinal(self.omega_coeff, self.finite_part + other.finite_part)

    def is_finite(self) -> bool:
        return self.omega_coeff == 0

    def is_transfinite(self) -> bool:
        return self.omega_coeff > 0


# ============================================================
# 2. Game Trees
# ============================================================

@dataclass
class GameTree:
    """A game tree for a Mortality Game."""
    mortal_choices: List['GameTree']  # Mortal's available moves
    eternity_responses: Optional[List[List['GameTree']]] = None  # For each Mortal choice, Eternity's responses

    @classmethod
    def terminal(cls) -> 'GameTree':
        """Terminal node: Mortal loses immediately."""
        return cls(mortal_choices=[])

    @classmethod
    def mortal_node(cls, children: List['GameTree']) -> 'GameTree':
        """Mortal picks one of the children."""
        return cls(mortal_choices=children)

    def game_value(self, depth: int = 0) -> int:
        """Compute the finite game value (depth of minimax tree)."""
        if not self.mortal_choices:
            return 0
        return 1 + max(min_child.game_value(depth + 1)
                       for min_child in self.mortal_choices)


def compute_survival_ordinal_finite(values: List[int]) -> Ordinal:
    """Given a list of finite game values, compute the survival ordinal."""
    if not values:
        return Ordinal.finite(0)
    max_val = max(values)
    if max_val < len(values):  # bounded
        return Ordinal.finite(max_val)
    return Ordinal.omega()  # unbounded → ω


# ============================================================
# 3. Demonstrations
# ============================================================

def demo_omega_survival():
    """Demonstrate the Omega Survival Theorem."""
    print("=" * 60)
    print("DEMO 1: Omega Survival Theorem")
    print("=" * 60)
    print()
    print("Mortal has access to games of value 1, 2, 3, 4, ...")
    print("Each game n has value ≥ n.")
    print()

    values = list(range(1, 21))
    print(f"First 20 game values: {values}")
    print(f"Max of first 20: {max(values)}")
    print(f"But there's no upper bound!")
    print()
    print(f"Survival ordinal = sup {{1, 2, 3, ...}} = ω")
    print(f"Computed: {compute_survival_ordinal_finite(values)}")
    print()
    print("Key insight: finite + finite + ... (unbounded) = ω")
    print()


def demo_mortality_dichotomy():
    """Demonstrate the Mortality Dichotomy."""
    print("=" * 60)
    print("DEMO 2: Mortality Dichotomy")
    print("=" * 60)
    print()
    print("Every ordinal is either finite or ≥ ω. No in-between!")
    print()

    test_ordinals = [
        Ordinal.finite(0),
        Ordinal.finite(5),
        Ordinal.finite(42),
        Ordinal.omega(),
        Ordinal(1, 3),  # ω + 3
        Ordinal(2, 0),  # ω · 2
        Ordinal(5, 7),  # ω · 5 + 7
    ]

    for o in test_ordinals:
        if o.is_finite():
            print(f"  {str(o):>12} → FINITE (Mortal dies in ≤ {o.finite_part} rounds)")
        else:
            print(f"  {str(o):>12} → TRANSFINITE (Mortal achieves immortality!)")
    print()


def demo_absorption():
    """Demonstrate the Absorption Principle."""
    print("=" * 60)
    print("DEMO 3: Finite Absorption Principle")
    print("=" * 60)
    print()
    print("Adding a finite number to ω is absorbed:")
    print()

    for n in [0, 1, 5, 100, 1000000]:
        result = Ordinal.finite(n) + Ordinal.omega()
        print(f"  {n} + ω = {result}")

    print()
    print("Multiplying a finite number by ω (on the right) is absorbed:")
    print()
    for k in [1, 2, 3, 5, 100]:
        # k · ω = ω for k ≥ 1
        print(f"  {k} · ω = ω")

    print()
    print("But LEFT multiplication is NOT absorbed:")
    print()
    for k in [1, 2, 3, 5]:
        print(f"  ω · {k} = {Ordinal.omega_times(k)}")
    print()


def demo_cantor_normal_form():
    """Demonstrate Cantor Normal Form decomposition."""
    print("=" * 60)
    print("DEMO 4: Cantor Normal Form of Game Ordinals")
    print("=" * 60)
    print()
    print("Every ordinal below ω² has a unique Cantor normal form ω·a + b:")
    print()

    examples = [
        (0, 0), (0, 1), (0, 5), (1, 0), (1, 3),
        (2, 0), (2, 7), (3, 0), (5, 2), (10, 0),
    ]

    for a, b in examples:
        o = Ordinal(a, b)
        print(f"  {str(o):>12} = ω·{a} + {b}  "
              f"({a} macro-rounds of ω, plus {b} finite rounds)")
    print()
    print("Game interpretation:")
    print("  a = number of 'transfinite phases' Mortal can force")
    print("  b = residual finite rounds after the last phase")
    print()


def demo_omega_squared():
    """Demonstrate the Omega-Squared Escalation."""
    print("=" * 60)
    print("DEMO 5: Omega-Squared Escalation")
    print("=" * 60)
    print()
    print("With k-bounded nondeterminism, Mortal's survival:")
    print()

    for k in range(8):
        o = Ordinal.omega_times(k)
        print(f"  k = {k}: survival = ω · {k} = {o}")

    print()
    print("  k → ∞: survival = sup {{ω·k : k ∈ ℕ}} = ω² !")
    print()
    print("Unbounded nondeterminism achieves ω² = ω · ω")
    print()


def demo_game_tree():
    """Demonstrate game tree evaluation."""
    print("=" * 60)
    print("DEMO 6: Game Tree Evaluation")
    print("=" * 60)
    print()

    # Build a small game tree
    leaf = GameTree.terminal()
    depth1 = GameTree.mortal_node([leaf])
    depth2 = GameTree.mortal_node([depth1, leaf])
    depth3 = GameTree.mortal_node([depth2, depth1])
    depth4 = GameTree.mortal_node([depth3, depth2, leaf])

    trees = [leaf, depth1, depth2, depth3, depth4]
    names = ["Terminal", "Depth-1", "Depth-2 (choice)", "Depth-3 (choice)", "Depth-4 (3 choices)"]

    for name, tree in zip(names, trees):
        v = tree.game_value()
        print(f"  {name:>25}: game value = {v}")

    print()
    print("Mortal always picks the branch with highest value (minimax).")
    print()


if __name__ == "__main__":
    demo_omega_survival()
    demo_mortality_dichotomy()
    demo_absorption()
    demo_cantor_normal_form()
    demo_omega_squared()
    demo_game_tree()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Survival Ordinal Landscape
==========================================
Plots the key relationships in mortality game theory.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_omega_survival():
    """Plot the omega survival phenomenon: sup of finite values = ω."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: finite game values approaching ω
    ax = axes[0]
    n_values = np.arange(1, 21)
    ax.bar(n_values, n_values, color='steelblue', alpha=0.7, label='Game value')
    ax.axhline(y=20, color='red', linestyle='--', linewidth=2, label='ω (limit)')
    ax.set_xlabel('Game index n', fontsize=12)
    ax.set_ylabel('Game value', fontsize=12)
    ax.set_title('Omega Survival: Unbounded Finite Values → ω', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(0, 25)
    ax.annotate('ω = sup{1,2,3,...}', xy=(15, 20.5), fontsize=11,
                color='red', fontweight='bold')

    # Right: The mortality dichotomy
    ax = axes[1]
    finite_ordinals = list(range(8))
    transfinite_start = [20, 21, 22, 23, 40, 41]
    labels_f = [str(i) for i in finite_ordinals]
    labels_t = ['ω', 'ω+1', 'ω+2', 'ω+3', 'ω·2', 'ω·2+1']

    ax.barh(range(len(finite_ordinals)), [1]*len(finite_ordinals),
            color='coral', alpha=0.7, label='Finite (Mortal dies)')
    ax.barh(range(len(finite_ordinals), len(finite_ordinals)+len(transfinite_start)),
            [1]*len(transfinite_start),
            color='forestgreen', alpha=0.7, label='Transfinite (Mortal survives)')

    all_labels = labels_f + labels_t
    ax.set_yticks(range(len(all_labels)))
    ax.set_yticklabels(all_labels, fontsize=10)
    ax.set_xlabel('Exists?', fontsize=12)
    ax.set_title('Mortality Dichotomy: No Gap Between Finite and ω', fontsize=13)
    ax.legend(fontsize=11, loc='lower right')

    # Draw the gap
    gap_y = len(finite_ordinals) - 0.5
    ax.axhline(y=gap_y, color='black', linestyle=':', linewidth=2)
    ax.annotate('← THE GAP →\nNo ordinals here!', xy=(0.3, gap_y + 0.15),
                fontsize=10, fontweight='bold', ha='center',
                bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig('survival_ordinals.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_ordinals.png")


def plot_absorption():
    """Plot the absorption principle."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Show n + ω = ω for various n
    n_values = [0, 1, 2, 5, 10, 50, 100]
    y_positions = range(len(n_values))

    # Each bar shows n (blue) + ω (green) = ω (total)
    omega_repr = 20  # represent ω as 20 for visualization

    for i, n in enumerate(n_values):
        # Blue part: finite n
        ax.barh(i, n, color='steelblue', alpha=0.7, height=0.6)
        # Green part: ω (always the same)
        ax.barh(i, omega_repr, left=n, color='forestgreen', alpha=0.7, height=0.6)
        # Result annotation
        ax.text(n + omega_repr + 1, i, f'{n} + ω = ω', va='center',
                fontsize=11, fontweight='bold')

    ax.set_yticks(y_positions)
    ax.set_yticklabels([f'n = {n}' for n in n_values], fontsize=11)
    ax.set_xlabel('Ordinal magnitude', fontsize=12)
    ax.set_title('Finite Absorption: n + ω = ω for all finite n', fontsize=14)

    blue_patch = mpatches.Patch(color='steelblue', alpha=0.7, label='Finite part (n)')
    green_patch = mpatches.Patch(color='forestgreen', alpha=0.7, label='Transfinite part (ω)')
    ax.legend(handles=[blue_patch, green_patch], fontsize=11)

    plt.tight_layout()
    plt.savefig('absorption_principle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: absorption_principle.png")


def plot_escalation():
    """Plot the ω² escalation."""
    fig, ax = plt.subplots(figsize=(10, 6))

    k_values = range(8)
    # ω·k represented as stacked blocks
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, 8))

    for k in k_values:
        for j in range(k):
            ax.bar(k, 1, bottom=j, color=colors[j], alpha=0.8,
                   edgecolor='white', linewidth=0.5)
        ax.text(k, k + 0.3, f'ω·{k}', ha='center', fontsize=10, fontweight='bold')

    # Add ω² arrow
    ax.annotate('→ ω²', xy=(7.5, 7.5), fontsize=14, fontweight='bold',
                color='red', ha='center')

    ax.set_xlabel('Nondeterminism level k', fontsize=12)
    ax.set_ylabel('Survival ordinal (units of ω)', fontsize=12)
    ax.set_title('Omega-Squared Escalation: sup{ω·k : k ∈ ℕ} = ω²', fontsize=14)
    ax.set_xticks(list(k_values))
    ax.set_xticklabels([str(k) for k in k_values])

    plt.tight_layout()
    plt.savefig('omega_squared_escalation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: omega_squared_escalation.png")


if __name__ == "__main__":
    plot_omega_survival()
    plot_absorption()
    plot_escalation()
    print("All visualizations generated.")
