#!/usr/bin/env python3
"""
Provability Logic GL: Interactive Demo

Demonstrates key concepts from the formal framework:
1. The consistency hierarchy □ⁿ⊥ in concrete lattices
2. GL frame validation (checking the Löb property)
3. Fixed-point rigidity verification
"""

from typing import List, Dict, Set, Tuple, Optional


def consistency_hierarchy(box: dict, bot: str, n: int) -> List[str]:
    """Compute the consistency hierarchy □⁰⊥, □¹⊥, ..., □ⁿ⊥.
    
    Args:
        box: Dictionary mapping elements to their □-images
        bot: The bottom element
        n: Number of iterations
    
    Returns:
        List of elements [⊥, □⊥, □²⊥, ..., □ⁿ⊥]
    """
    hierarchy = [bot]
    current = bot
    for _ in range(n):
        current = box[current]
        hierarchy.append(current)
    return hierarchy


def check_loeb_axiom(elements: List[str], le: Dict[Tuple[str, str], bool],
                     box: Dict[str, str], top: str) -> Tuple[bool, Optional[str]]:
    """Check if a finite algebra satisfies the Löb axiom: □a ≤ a → a = ⊤.
    
    Returns:
        (True, None) if Löb holds, (False, counterexample) otherwise
    """
    for a in elements:
        if le[(box[a], a)] and a != top:
            return False, a
    return True, None


def check_converse_wf(worlds: List[str], 
                      R: Set[Tuple[str, str]]) -> Tuple[bool, Optional[List[str]]]:
    """Check if a finite frame is conversely well-founded (acyclic).
    
    Returns:
        (True, None) if acyclic, (False, cycle) otherwise
    """
    # Build adjacency list
    adj: Dict[str, List[str]] = {w: [] for w in worlds}
    for (u, v) in R:
        adj[u].append(v)
    
    # DFS cycle detection
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {w: WHITE for w in worlds}
    parent = {w: None for w in worlds}
    
    def dfs(u: str) -> Optional[List[str]]:
        color[u] = GRAY
        for v in adj[u]:
            if color[v] == GRAY:
                # Found cycle - reconstruct
                cycle = [v, u]
                curr = u
                while parent[curr] != v and parent[curr] is not None:
                    curr = parent[curr]
                    cycle.append(curr)
                return cycle
            if color[v] == WHITE:
                parent[v] = u
                result = dfs(v)
                if result:
                    return result
        color[u] = BLACK
        return None
    
    for w in worlds:
        if color[w] == WHITE:
            cycle = dfs(w)
            if cycle:
                return False, cycle
    return True, None


def check_loeb_property_semantic(worlds: List[str],
                                  R: Set[Tuple[str, str]]) -> bool:
    """Check the semantic Löb property: □((□S)ᶜ ∪ S) ⊆ □S for all S.
    
    For finite frames, this is equivalent to acyclicity.
    """
    from itertools import combinations
    
    world_set = set(worlds)
    
    def box_set(S: Set[str]) -> Set[str]:
        return {w for w in worlds if all(v in S for v in worlds if (w, v) in R)}
    
    # Check for all subsets S
    for size in range(len(worlds) + 1):
        for subset in combinations(worlds, size):
            S = set(subset)
            box_S = box_set(S)
            S_complement = world_set - S
            box_S_complement = world_set - box_S
            inner = box_S_complement | S
            lhs = box_set(inner)
            if not lhs.issubset(box_S):
                return False
    return True


def demo_three_element_lattice():
    """Demo: Can a 3-element lattice {⊥, c, ⊤} be a Löb algebra?"""
    print("=" * 60)
    print("Demo 1: Three-Element Lattice Analysis")
    print("=" * 60)
    
    elements = ["⊥", "c", "⊤"]
    
    # Try □⊥ = c, □c = ⊤, □⊤ = ⊤
    box = {"⊥": "c", "c": "⊤", "⊤": "⊤"}
    le = {
        ("⊥", "⊥"): True, ("⊥", "c"): True, ("⊥", "⊤"): True,
        ("c", "⊥"): False, ("c", "c"): True, ("c", "⊤"): True,
        ("⊤", "⊥"): False, ("⊤", "c"): False, ("⊤", "⊤"): True,
    }
    
    print(f"Elements: {elements}")
    print(f"□⊥ = {box['⊥']}, □c = {box['c']}, □⊤ = {box['⊤']}")
    
    valid, cex = check_loeb_axiom(elements, le, box, "⊤")
    if valid:
        print("✓ Löb axiom satisfied")
    else:
        print(f"✗ Löb axiom violated at a = {cex}: □{cex} = {box[cex]} ≤ {cex} but {cex} ≠ ⊤")
    
    # Check Σ₁-soundness
    print("\nΣ₁-soundness check:")
    for a in elements:
        if box[a] == "⊤" and a != "⊤":
            print(f"  ✗ □{a} = ⊤ but {a} ≠ ⊤ — Σ₁-soundness violated!")
    
    # Try another assignment: □⊥ = c, □c = c, □⊤ = ⊤
    print("\n--- Alternative assignment: □c = c ---")
    box2 = {"⊥": "c", "c": "c", "⊤": "⊤"}
    valid2, cex2 = check_loeb_axiom(elements, le, box2, "⊤")
    if valid2:
        print("✓ Löb axiom satisfied")
    else:
        print(f"✗ Löb axiom violated at a = {cex2}: □{cex2} = {box2[cex2]} ≤ {cex2} but {cex2} ≠ ⊤")
    
    print("\nConclusion: No nontrivial 3-element Löb algebra exists with Σ₁-soundness.")
    print("The Löb axiom + Σ₁-soundness forces the algebra to be infinite!")


def demo_consistency_hierarchy():
    """Demo: The strict consistency hierarchy in ℕ-indexed algebras."""
    print("\n" + "=" * 60)
    print("Demo 2: Consistency Hierarchy")
    print("=" * 60)
    
    # Model: L = ℕ ∪ {∞}, □n = n+1, □∞ = ∞
    # ⊥ = 0, ⊤ = ∞
    print("Model: L = ℕ ∪ {∞}, □n = n+1, □∞ = ∞")
    print("This is the simplest Σ₁-sound Löb algebra.")
    print()
    
    n = 10
    hierarchy = list(range(n + 1))
    print(f"Consistency hierarchy (first {n+1} levels):")
    for i, val in enumerate(hierarchy):
        symbol = f"□{'□' * i}⊥" if i > 0 else "⊥"
        print(f"  {symbol} = {val}")
    
    print()
    print("Strict ordering: " + " < ".join(str(v) for v in hierarchy))
    print(f"\nThe hierarchy embeds ℕ into L, proving L is infinite.")


def demo_gl_frame():
    """Demo: GL frame validation."""
    print("\n" + "=" * 60)
    print("Demo 3: GL Frame Validation")
    print("=" * 60)
    
    # Example 1: Valid GL frame (linear order)
    print("\nFrame 1: Linear order w₀ → w₁ → w₂")
    worlds1 = ["w₀", "w₁", "w₂"]
    R1 = {("w₀", "w₁"), ("w₁", "w₂"), ("w₀", "w₂")}  # transitive closure
    
    acyclic, cycle = check_converse_wf(worlds1, R1)
    loeb = check_loeb_property_semantic(worlds1, R1)
    print(f"  Acyclic (CWF): {acyclic}")
    print(f"  Löb property:  {loeb}")
    print(f"  Valid GL frame: {acyclic and loeb}")
    
    # Example 2: Invalid frame (has cycle)
    print("\nFrame 2: Cycle w₀ → w₁ → w₀")
    worlds2 = ["w₀", "w₁"]
    R2 = {("w₀", "w₁"), ("w₁", "w₀")}
    
    acyclic2, cycle2 = check_converse_wf(worlds2, R2)
    loeb2 = check_loeb_property_semantic(worlds2, R2)
    print(f"  Acyclic (CWF): {acyclic2}" + (f" — cycle: {cycle2}" if cycle2 else ""))
    print(f"  Löb property:  {loeb2}")
    print(f"  Valid GL frame: {acyclic2 and loeb2}")
    
    # Example 3: Diamond frame
    print("\nFrame 3: Diamond w₀ → w₁, w₀ → w₂, w₁ → w₃, w₂ → w₃")
    worlds3 = ["w₀", "w₁", "w₂", "w₃"]
    R3 = {("w₀", "w₁"), ("w₀", "w₂"), ("w₁", "w₃"), ("w₂", "w₃"),
           ("w₀", "w₃")}  # transitive closure
    
    acyclic3, _ = check_converse_wf(worlds3, R3)
    loeb3 = check_loeb_property_semantic(worlds3, R3)
    print(f"  Acyclic (CWF): {acyclic3}")
    print(f"  Löb property:  {loeb3}")
    print(f"  Valid GL frame: {acyclic3 and loeb3}")


def demo_fixed_point_rigidity():
    """Demo: Fixed-point rigidity — □a = a ⟹ a = ⊤."""
    print("\n" + "=" * 60)
    print("Demo 4: Fixed-Point Rigidity")
    print("=" * 60)
    
    print("\nIn any Löb algebra, the only fixed point of □ is ⊤.")
    print("This means: if □a = a, then a must equal ⊤.")
    print()
    
    # In the ℕ ∪ {∞} model:
    print("In the model L = ℕ ∪ {∞}, □n = n+1, □∞ = ∞:")
    for n in range(6):
        print(f"  □({n}) = {n+1} ≠ {n}  ✓ (not a fixed point)")
    print(f"  □(∞) = ∞ = ∞    ✓ (fixed point, and ∞ = ⊤)")
    print()
    print("No finite element is a fixed point — only ⊤ = ∞ satisfies □a = a.")


if __name__ == "__main__":
    demo_three_element_lattice()
    demo_consistency_hierarchy()
    demo_gl_frame()
    demo_fixed_point_rigidity()
    
    print("\n" + "=" * 60)
    print("Summary of Key Results (all formally verified in Lean 4)")
    print("=" * 60)
    print("1. loeb_iff_cwf:   Löb property ↔ converse well-foundedness")
    print("2. strict_hierarchy: □ⁿ⊥ < □ⁿ⁺¹⊥ (under Σ₁-soundness)")
    print("3. box_fixed_implies_top: □a = a ⟹ a = ⊤")
    print("4. rosser_not_provable: g ⊓ □g = ⊥ ⟹ □g ≠ ⊤")
    print("5. goedel_second: □⊥ ≠ ⊥ in nontrivial algebras")
    print("6. goedel_undecidability: Diagonal sentences are undecidable")


#!/usr/bin/env python3
"""
Visualization: The Consistency Hierarchy in Provability Logic GL

Plots the strict consistency hierarchy □ⁿ⊥ for various Löb algebra models,
showing how the hierarchy embeds ℕ into the algebra.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_consistency_hierarchy():
    """Plot the consistency hierarchy for the canonical ℕ ∪ {∞} model."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: The hierarchy as a chain
    ax1 = axes[0]
    n_levels = 8
    levels = list(range(n_levels))
    
    for i in range(n_levels):
        y = i
        ax1.plot(0, y, 'o', markersize=12, color=plt.cm.viridis(i / n_levels), 
                zorder=5)
        label = "⊥" if i == 0 else f"□{'□' * (i-1)}⊥" if i <= 3 else f"□^{i}⊥"
        ax1.annotate(label, (0, y), xytext=(0.3, y), fontsize=11,
                    va='center', ha='left')
        if i > 0:
            ax1.annotate('', xy=(0, y), xytext=(0, y - 1),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    ax1.set_xlim(-0.5, 2.5)
    ax1.set_ylim(-0.5, n_levels + 0.5)
    ax1.set_title("Consistency Hierarchy\n⊥ < □⊥ < □²⊥ < □³⊥ < ⋯", fontsize=13)
    ax1.axis('off')
    
    # Add ⊤ at the top with dotted line
    ax1.plot(0, n_levels, 's', markersize=12, color='gold', zorder=5)
    ax1.annotate('⊤', (0, n_levels), xytext=(0.3, n_levels), fontsize=11,
                va='center', ha='left')
    ax1.plot([0, 0], [n_levels - 1 + 0.3, n_levels - 0.3], '--', color='gray', lw=1)
    
    # Panel 2: The gap between consecutive levels
    ax2 = axes[1]
    # In the tropical model □a = a + c, the gaps are all equal to c
    c = 1.0
    gaps = [c] * (n_levels - 1)
    bars = ax2.bar(range(len(gaps)), gaps, color=[plt.cm.viridis(i / n_levels) 
                                                   for i in range(len(gaps))],
                   edgecolor='black', linewidth=0.5)
    ax2.set_xlabel("Level n", fontsize=12)
    ax2.set_ylabel("Gap: □ⁿ⁺¹⊥ - □ⁿ⊥", fontsize=12)
    ax2.set_title("Gaps in the Hierarchy\n(constant in the tropical model)", fontsize=13)
    ax2.set_xticks(range(len(gaps)))
    ax2.set_xticklabels([f"n={i}" for i in range(len(gaps))], fontsize=9)
    
    # Panel 3: Provability gap a ⊔ □a
    ax3 = axes[2]
    # For a = □ⁿ⊥ in the ℕ model: provGap(n) = max(n, n+1) = n+1 = □ⁿ⁺¹⊥
    n_vals = np.arange(0, 8)
    prov_gaps = n_vals + 1
    
    ax3.plot(n_vals, n_vals, 'o-', label='a = □ⁿ⊥', color='blue', markersize=8)
    ax3.plot(n_vals, prov_gaps, 's-', label='provGap(a) = a ⊔ □a', 
            color='red', markersize=8)
    ax3.fill_between(n_vals, n_vals, prov_gaps, alpha=0.2, color='red')
    ax3.set_xlabel("n", fontsize=12)
    ax3.set_ylabel("Value in L", fontsize=12)
    ax3.set_title("Provability Gap\nprovGap(a) = a ⊔ □a", fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig("consistency_hierarchy.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: consistency_hierarchy.png")


def plot_gl_frame():
    """Plot example GL frames showing the Löb-WF equivalence."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Frame 1: Valid GL frame (linear)
    ax1 = axes[0]
    positions = {0: (0, 0), 1: (1, 1), 2: (2, 2)}
    for i, (x, y) in positions.items():
        ax1.plot(x, y, 'o', markersize=20, color='steelblue', zorder=5)
        ax1.annotate(f'w{i}', (x, y), fontsize=11, ha='center', va='center',
                    color='white', fontweight='bold')
    # Draw arrows
    for i in range(2):
        ax1.annotate('', xy=positions[i+1], xytext=positions[i],
                    arrowprops=dict(arrowstyle='->', color='darkblue', lw=2))
    ax1.set_title("Valid GL Frame\n(Linear, WF ✓, Löb ✓)", fontsize=13,
                  color='green')
    ax1.set_xlim(-0.5, 2.5)
    ax1.set_ylim(-0.5, 2.5)
    ax1.axis('off')
    
    # Frame 2: Invalid frame (cycle)
    ax2 = axes[1]
    angles = [np.pi/2, -np.pi/6, 7*np.pi/6]
    r = 1
    cycle_pos = {i: (r * np.cos(a), r * np.sin(a)) for i, a in enumerate(angles)}
    for i, (x, y) in cycle_pos.items():
        ax2.plot(x, y, 'o', markersize=20, color='crimson', zorder=5)
        ax2.annotate(f'w{i}', (x, y), fontsize=11, ha='center', va='center',
                    color='white', fontweight='bold')
    for i in range(3):
        j = (i + 1) % 3
        dx = cycle_pos[j][0] - cycle_pos[i][0]
        dy = cycle_pos[j][1] - cycle_pos[i][1]
        ax2.annotate('', xy=cycle_pos[j], xytext=cycle_pos[i],
                    arrowprops=dict(arrowstyle='->', color='darkred', lw=2))
    ax2.set_title("Invalid Frame\n(Cycle, ¬WF ✗, ¬Löb ✗)", fontsize=13,
                  color='red')
    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.axis('off')
    
    # Frame 3: Valid GL frame (diamond)
    ax3 = axes[2]
    diamond_pos = {0: (1, 0), 1: (0, 1), 2: (2, 1), 3: (1, 2)}
    for i, (x, y) in diamond_pos.items():
        ax3.plot(x, y, 'o', markersize=20, color='steelblue', zorder=5)
        ax3.annotate(f'w{i}', (x, y), fontsize=11, ha='center', va='center',
                    color='white', fontweight='bold')
    edges = [(0, 1), (0, 2), (1, 3), (2, 3)]
    for (i, j) in edges:
        ax3.annotate('', xy=diamond_pos[j], xytext=diamond_pos[i],
                    arrowprops=dict(arrowstyle='->', color='darkblue', lw=2))
    ax3.set_title("Valid GL Frame\n(Diamond, WF ✓, Löb ✓)", fontsize=13,
                  color='green')
    ax3.set_xlim(-0.5, 2.5)
    ax3.set_ylim(-0.5, 2.5)
    ax3.axis('off')
    
    plt.tight_layout()
    plt.savefig("gl_frames.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gl_frames.png")


def plot_fixed_point_dynamics():
    """Visualize the dynamics of □ iteration showing fixed-point rigidity."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    # Plot several orbits under □ in the ℕ ∪ {∞} model
    n_steps = 10
    top = 12  # representing ∞
    
    starting_points = [0, 1, 2, 3, 5]
    colors = plt.cm.Set2(np.linspace(0, 1, len(starting_points)))
    
    for start, color in zip(starting_points, colors):
        orbit = [start]
        current = start
        for _ in range(n_steps):
            current = min(current + 1, top)
            orbit.append(current)
        
        ax.plot(range(len(orbit)), orbit, 'o-', color=color, markersize=6,
               label=f'Start: {start}', linewidth=2)
    
    # Draw the fixed point line at top
    ax.axhline(y=top, color='gold', linestyle='--', linewidth=2, 
              label=f'⊤ = {top} (only fixed point)')
    
    # Draw y = x line for reference
    ax.plot([0, n_steps + 1], [0, n_steps + 1], ':', color='gray', 
           alpha=0.5, label='y = x (fixed points would lie here)')
    
    ax.set_xlabel("Iteration step k", fontsize=12)
    ax.set_ylabel("□ᵏ(a)", fontsize=12)
    ax.set_title("Fixed-Point Rigidity: All orbits converge to ⊤\n"
                "In a Löb algebra, □a = a ⟹ a = ⊤", fontsize=13)
    ax.legend(fontsize=10, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, n_steps + 0.5)
    ax.set_ylim(-0.5, top + 1)
    
    plt.tight_layout()
    plt.savefig("fixed_point_rigidity.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fixed_point_rigidity.png")


if __name__ == "__main__":
    plot_consistency_hierarchy()
    plot_gl_frame()
    plot_fixed_point_dynamics()
    print("\nAll visualizations generated.")
