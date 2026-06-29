#!/usr/bin/env python3
"""
Transfinite Game Values: Demonstrations and Numerical Examples

This script demonstrates the key concepts from the formalization of
transfinite game values in infinite chess.
"""

from dataclasses import dataclass
from typing import Optional


# --- Ordinal Representation (Cantor Normal Form) ---

@dataclass(frozen=True)
class Ordinal:
    """Ordinal in Cantor Normal Form: sum of omega^e_i * c_i terms.
    
    Represents ordinals below epsilon_0.
    Terms are stored in decreasing order of exponents.
    """
    terms: tuple  # tuple of (exponent: Ordinal, coefficient: int)
    
    @staticmethod
    def zero() -> 'Ordinal':
        return Ordinal(terms=())
    
    @staticmethod
    def finite(n: int) -> 'Ordinal':
        if n == 0:
            return Ordinal.zero()
        return Ordinal(terms=((Ordinal.zero(), n),))
    
    @staticmethod
    def omega() -> 'Ordinal':
        return Ordinal(terms=((Ordinal.finite(1), 1),))
    
    @staticmethod
    def omega_pow(e: 'Ordinal') -> 'Ordinal':
        return Ordinal(terms=((e, 1),))
    
    def is_zero(self) -> bool:
        return len(self.terms) == 0
    
    def is_finite(self) -> bool:
        return len(self.terms) <= 1 and (
            len(self.terms) == 0 or self.terms[0][0].is_zero()
        )
    
    def to_nat(self) -> Optional[int]:
        if self.is_zero():
            return 0
        if self.is_finite():
            return self.terms[0][1]
        return None
    
    def __str__(self) -> str:
        if self.is_zero():
            return "0"
        parts = []
        for exp, coeff in self.terms:
            if exp.is_zero():
                parts.append(str(coeff))
            elif exp == Ordinal.finite(1):
                if coeff == 1:
                    parts.append("ω")
                else:
                    parts.append(f"ω·{coeff}")
            else:
                exp_str = str(exp)
                if coeff == 1:
                    parts.append(f"ω^({exp_str})")
                else:
                    parts.append(f"ω^({exp_str})·{coeff}")
        return " + ".join(parts)
    
    def __lt__(self, other: 'Ordinal') -> bool:
        """Lexicographic comparison on CNF terms."""
        for i in range(max(len(self.terms), len(other.terms))):
            if i >= len(self.terms):
                return True
            if i >= len(other.terms):
                return False
            e1, c1 = self.terms[i]
            e2, c2 = other.terms[i]
            if e1 < e2:
                return True
            if e2 < e1:
                return False
            if c1 < c2:
                return True
            if c2 < c1:
                return False
        return False


# --- Game Tree Representation ---

@dataclass
class GameNode:
    """A node in a well-founded game tree."""
    name: str
    children: list  # list of GameNode
    value: Optional[Ordinal] = None


def compute_game_value(node: GameNode) -> Ordinal:
    """Compute the game value of a node by recursion.
    
    v(node) = sup { v(child) + 1 : child in children }
    For finite games, this gives a natural number.
    """
    if not node.children:
        node.value = Ordinal.zero()
        return node.value
    
    max_child_val = -1
    for child in node.children:
        child_val = compute_game_value(child)
        n = child_val.to_nat()
        if n is not None:
            max_child_val = max(max_child_val, n)
    
    node.value = Ordinal.finite(max_child_val + 1)
    return node.value


# --- Demo 1: Chain Game ---

def demo_chain_game():
    """Demonstrate game values for the chain game."""
    print("=" * 60)
    print("DEMO 1: Chain Game (Finite Values)")
    print("=" * 60)
    print()
    print("Chain game C_n: positions {0, 1, ..., n}")
    print("Move: k → k-1 (for k > 0)")
    print("Position 0 is terminal (checkmate)")
    print()
    
    for n in range(6):
        # Build chain game
        nodes = [GameNode(name=str(i), children=[]) for i in range(n + 1)]
        for i in range(1, n + 1):
            nodes[i].children = [nodes[i - 1]]
        
        val = compute_game_value(nodes[n])
        print(f"  C_{n}: game value at position {n} = {val}")
    
    print()
    print("Theorem (chainGame_value): v(k) = k for all k ≤ n")
    print()


# --- Demo 2: The ω^n Hierarchy ---

def demo_omega_hierarchy():
    """Demonstrate the ω^n hierarchy."""
    print("=" * 60)
    print("DEMO 2: The ω^n Hierarchy")
    print("=" * 60)
    print()
    
    ordinals = [
        ("ω^0", Ordinal.finite(1)),
        ("ω^1", Ordinal.omega()),
        ("ω^2", Ordinal.omega_pow(Ordinal.finite(2))),
        ("ω^3", Ordinal.omega_pow(Ordinal.finite(3))),
        ("ω^4", Ordinal.omega_pow(Ordinal.finite(4))),
        ("ω^ω", Ordinal.omega_pow(Ordinal.omega())),
    ]
    
    print("The hierarchy of transfinite game values:")
    print()
    for name, ordinal in ordinals:
        print(f"  {name} = {ordinal}")
    
    print()
    print("Theorem (omega_pow_strictMono): ω^n < ω^(n+1) for all n")
    print("Theorem (omega_pow_omega_eq_iSup): ω^ω = sup_n ω^n")
    print()
    
    print("Separation results:")
    for n in range(1, 5):
        for m in range(1, 4):
            print(f"  ω^{n} · {m} < ω^{n+1}")
    print()


# --- Demo 3: The Omega Tower and ε₀ ---

def demo_omega_tower():
    """Demonstrate the omega tower converging to ε₀."""
    print("=" * 60)
    print("DEMO 3: The Omega Tower → ε₀")
    print("=" * 60)
    print()
    
    tower = [
        Ordinal.finite(1),
        Ordinal.omega(),
        Ordinal.omega_pow(Ordinal.omega()),
        Ordinal.omega_pow(Ordinal.omega_pow(Ordinal.omega())),
        Ordinal.omega_pow(Ordinal.omega_pow(Ordinal.omega_pow(Ordinal.omega()))),
    ]
    
    print("omegaTower(n) = iterated ω-exponentiation:")
    print()
    for i, t in enumerate(tower):
        print(f"  omegaTower({i}) = {t}")
    print(f"  omegaTower(5) = ω^(ω^(ω^(ω^ω)))  [too deep to display]")
    print(f"  ...")
    print(f"  ε₀ = sup_n omegaTower(n)")
    print()
    print("Theorem (omega_pow_epsilon0): ω^(ε₀) = ε₀")
    print("This is the smallest ordinal with this fixed-point property.")
    print()
    
    print("Key properties of ε₀:")
    print("  1. ε₀ is strictly above every omegaTower(n)")
    print("  2. ε₀ is the proof-theoretic ordinal of Peano Arithmetic")
    print("  3. ε₀ is a fixed point of ordinal exponentiation: ω^(ε₀) = ε₀")
    print("  4. Every ordinal below ε₀ has a finite Cantor normal form")
    print()


# --- Demo 4: Game Value Cofinality ---

def demo_cofinality():
    """Demonstrate the cofinality theorem."""
    print("=" * 60)
    print("DEMO 4: Cofinality and Limit Values")
    print("=" * 60)
    print()
    
    print("The cofinality theorem states:")
    print("  If ∀ β < α, ∃ move to position with value ≥ β,")
    print("  then the game value ≥ α.")
    print()
    
    print("Example: A game with value ω")
    print("  From position p, moves go to positions with values 0, 1, 2, 3, ...")
    print("  For each n, the move to position with value n exists.")
    print("  No single move reaches value ω (all successors are finite).")
    print("  But the supremum is ω — this is why ω is a limit ordinal.")
    print()
    
    print("Example: A game with value ω²")
    print("  From position p, moves reach values ω·0, ω·1, ω·2, ω·3, ...")
    print("  Each ω·n < ω² (separation theorem).")
    print("  But sup_n ω·n = ω², demonstrating two-level cofinality.")
    print()


# --- Demo 5: The Bridge Theorem ---

def demo_bridge():
    """Demonstrate the bridge between well-orders and games."""
    print("=" * 60)
    print("DEMO 5: Bridge Theorem — Well-Orders ↔ Game Trees")
    print("=" * 60)
    print()
    
    print("The Bridge Theorem: wfRank(a) = gameValue(a)")
    print()
    print("This identity says that two apparently different concepts")
    print("are actually the same:")
    print()
    print("  ORDER THEORY                  GAME THEORY")
    print("  ──────────────                ───────────")
    print("  Well-founded relation    ←→   Game tree")
    print("  Ordinal rank             ←→   Game value")
    print("  Minimal element          ←→   Terminal position")
    print("  Descending chain         ←→   Play sequence")
    print("  Well-foundedness         ←→   Every play terminates")
    print()
    print("Example: The ordinal ω as a well-order")
    print("  Positions: 0, 1, 2, 3, ... (natural numbers)")
    print("  Relation: m < n")
    print("  Rank of n = n (matches game value)")
    print("  Rank of the whole order = ω")
    print()


def main():
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TRANSFINITE GAME VALUES IN INFINITE CHESS              ║")
    print("║  Demonstrations and Numerical Examples                  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_chain_game()
    demo_omega_hierarchy()
    demo_omega_tower()
    demo_cofinality()
    demo_bridge()
    
    print("=" * 60)
    print("SUMMARY OF FORMALIZED RESULTS")
    print("=" * 60)
    print()
    print("Theorems proved in Lean 4 (no sorry):")
    print("  1. ordinalGame_gameValue — ordinal game has correct values")
    print("  2. exists_game_value — every ordinal is a game value")
    print("  3. chainGame_value — finite chain has value k at position k")
    print("  4. omega_pow_strictMono — ω^n is strictly increasing")
    print("  5. omega_pow_omega_eq_iSup — ω^ω = sup_n ω^n")
    print("  6. omega_pow_epsilon0 — ω^(ε₀) = ε₀")
    print("  7. omegaTower_strictMono — omega tower is increasing")
    print("  8. gameValue_cofinal — cofinality characterization")
    print("  9. gameValue_limit_characterization — limit values")
    print(" 10. wfRank_eq_gameValue — bridge theorem")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The ω^n Hierarchy of Transfinite Game Values

Generates a plot showing the ordinal hierarchy ω^0, ω^1, ω^2, ..., ω^ω
and how each level contains the previous ones.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def ordinal_label(n: int) -> str:
    """Pretty label for ω^n."""
    if n == 0:
        return "1"
    if n == 1:
        return "ω"
    return f"ω^{n}"


def draw_hierarchy():
    """Draw the ω^n hierarchy as nested boxes with game tree snippets."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    
    # --- Left panel: Nested hierarchy ---
    ax1.set_xlim(-0.5, 8)
    ax1.set_ylim(-0.5, 7)
    ax1.set_aspect('equal')
    ax1.set_title("The ω^n Hierarchy: Nested Complexity Levels", fontsize=14, fontweight='bold')
    ax1.axis('off')
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 7))
    
    for i in range(6, -1, -1):
        x = 0.3 * (6 - i)
        y = 0.3 * (6 - i)
        w = 7.4 - 0.6 * (6 - i)
        h = 6.4 - 0.6 * (6 - i)
        
        rect = mpatches.FancyBboxPatch(
            (x, y), w, h,
            boxstyle="round,pad=0.1",
            facecolor=(*colors[i][:3], 0.15),
            edgecolor=colors[i],
            linewidth=2
        )
        ax1.add_patch(rect)
        
        if i <= 5:
            label = ordinal_label(i)
        else:
            label = "ω^ω"
        
        ax1.text(x + 0.15, y + h - 0.3, label,
                fontsize=12 if i < 6 else 14,
                fontweight='bold',
                color=colors[i],
                verticalalignment='top')
    
    # Add descriptive text
    ax1.text(3.7, 0.7, "Game values grow\ntransfinitely:\neach level strictly\ncontains all\nprevious levels",
            fontsize=10, ha='center', va='center',
            style='italic', color='gray')
    
    # --- Right panel: Strict separation ---
    ax2.set_title("Separation: ω^n · m < ω^(n+1)", fontsize=14, fontweight='bold')
    
    n_levels = 5
    bar_data = {}
    
    for n in range(n_levels):
        for m in range(1, 5):
            bar_data[(n, m)] = n + np.log(m + 1) / np.log(5)
    
    x_pos = []
    heights = []
    colors_bar = []
    labels = []
    
    idx = 0
    for n in range(n_levels):
        for m in range(1, 5):
            x_pos.append(idx)
            heights.append(bar_data[(n, m)])
            colors_bar.append(plt.cm.Set2(n / n_levels))
            labels.append(f"ω^{n}·{m}")
            idx += 1
        # Add separator
        x_pos.append(idx)
        heights.append(n + 1)
        colors_bar.append('red')
        labels.append(f"ω^{n+1}")
        idx += 1
    
    bars = ax2.bar(x_pos, heights, color=colors_bar, edgecolor='black', linewidth=0.5)
    
    # Mark the ω^(n+1) boundaries
    for i, (x, h, c) in enumerate(zip(x_pos, heights, colors_bar)):
        if c == 'red':
            ax2.axhline(y=h, color='red', linestyle='--', alpha=0.3)
    
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
    ax2.set_ylabel("Relative ordinal magnitude (log scale)", fontsize=10)
    ax2.set_xlabel("Game value (in Cantor Normal Form)", fontsize=10)
    
    plt.tight_layout()
    plt.savefig("hierarchy_visualization.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hierarchy_visualization.png")


def draw_omega_tower():
    """Draw the omega tower converging to ε₀."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # The omega tower grows hyper-exponentially; use log-log-... scale
    n_values = list(range(8))
    
    # Use a symbolic height (log of tower height)
    heights = [0, 1, 2, 3, 4, 5, 6, 7]
    
    tower_labels = [
        "1", "ω", "ω^ω", "ω^(ω^ω)", "ω^(ω^(ω^ω))",
        "ω↑↑5", "ω↑↑6", "ω↑↑7"
    ]
    
    colors = plt.cm.inferno(np.linspace(0.2, 0.85, len(n_values)))
    
    bars = ax.bar(n_values, [2**h for h in heights], color=colors,
                  edgecolor='black', linewidth=0.5)
    
    ax.set_yscale('log', base=2)
    ax.set_xlabel("Tower level n", fontsize=12)
    ax.set_ylabel("omegaTower(n) (symbolic log scale)", fontsize=12)
    ax.set_title("The Omega Tower: Convergence to ε₀", fontsize=14, fontweight='bold')
    ax.set_xticks(n_values)
    ax.set_xticklabels([f"n={i}\n{tower_labels[i]}" for i in n_values],
                       fontsize=8)
    
    # Add ε₀ line
    ax.axhline(y=2**8.5, color='red', linestyle='--', linewidth=2, label='ε₀ = sup')
    ax.text(7.5, 2**8.5, 'ε₀', fontsize=14, color='red', fontweight='bold',
           verticalalignment='bottom')
    
    ax.legend(fontsize=11)
    
    plt.tight_layout()
    plt.savefig("omega_tower_visualization.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: omega_tower_visualization.png")


if __name__ == "__main__":
    draw_hierarchy()
    draw_omega_tower()
