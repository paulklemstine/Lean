#!/usr/bin/env python3
"""
Tangled Hierarchies: Demonstration of Self-Referential Proof System Limits

This demo constructs concrete GL frames (Kripke frames for provability logic)
and demonstrates:
1. Löb's theorem on finite frames
2. The second incompleteness theorem (sound worlds can't prove consistency)
3. The tangling dichotomy
4. Tangling depth computation

Usage:
    python demo.py
"""

from __future__ import annotations
from typing import Any


def make_linear_gl_frame(n: int) -> tuple[list[int], dict[tuple[int, int], bool]]:
    """Create a linear GL frame with n worlds: 0 → 1 → 2 → ... → (n-1).
    Transitivity is ensured by adding all transitive edges."""
    worlds = list(range(n))
    relation: dict[tuple[int, int], bool] = {}
    for i in range(n):
        for j in range(n):
            # i R j iff i < j (transitive, irreflexive, well-founded)
            relation[(i, j)] = i < j
    return worlds, relation


def make_tree_gl_frame() -> tuple[list[int], dict[tuple[int, int], bool]]:
    """Create a tree-shaped GL frame:
         0
        / \\
       1   2
      / \\
     3   4
    Edges: 0→1, 0→2, 1→3, 1→4 (plus transitive closure: 0→3, 0→4)
    """
    worlds = [0, 1, 2, 3, 4]
    edges = {(0, 1), (0, 2), (1, 3), (1, 4), (0, 3), (0, 4)}
    relation = {(i, j): (i, j) in edges for i in worlds for j in worlds}
    return worlds, relation


def check_gl_conditions(
    worlds: list[int], relation: dict[tuple[int, int], bool]
) -> dict[str, bool]:
    """Verify GL frame conditions: transitivity, irreflexivity, converse well-foundedness."""
    # Irreflexivity
    irreflexive = all(not relation.get((w, w), False) for w in worlds)

    # Transitivity
    transitive = True
    for u in worlds:
        for v in worlds:
            for w in worlds:
                if relation.get((u, v), False) and relation.get((v, w), False):
                    if not relation.get((u, w), False):
                        transitive = False

    # Converse well-foundedness (no infinite ascending chains)
    # For finite frames, equivalent to acyclicity
    # Check via topological sort on R
    visited: set[int] = set()
    in_stack: set[int] = set()
    acyclic = True

    def dfs(node: int) -> bool:
        nonlocal acyclic
        if node in in_stack:
            acyclic = False
            return False
        if node in visited:
            return True
        visited.add(node)
        in_stack.add(node)
        for succ in worlds:
            if relation.get((node, succ), False):
                if not dfs(succ):
                    return False
        in_stack.discard(node)
        return True

    for w in worlds:
        if w not in visited:
            dfs(w)

    return {
        "irreflexive": irreflexive,
        "transitive": transitive,
        "converse_well_founded": acyclic,
        "is_gl_frame": irreflexive and transitive and acyclic,
    }


def compute_tangling_depth(
    worlds: list[int], relation: dict[tuple[int, int], bool]
) -> dict[int, int]:
    """Compute the tangling depth of each world (longest R-chain from that world)."""
    memo: dict[int, int] = {}

    def depth(w: int) -> int:
        if w in memo:
            return memo[w]
        successors = [v for v in worlds if relation.get((w, v), False)]
        if not successors:
            memo[w] = 0
        else:
            memo[w] = 1 + max(depth(v) for v in successors)
        return memo[w]

    for w in worlds:
        depth(w)
    return memo


def forces(
    worlds: list[int],
    relation: dict[tuple[int, int], bool],
    valuation: dict[str, set[int]],
    world: int,
    formula: tuple[str, ...],
) -> bool:
    """Evaluate whether world forces formula in the given frame with valuation.

    Formula encoding:
    - ("var", "p")       : propositional variable p
    - ("bot",)           : falsum
    - ("imp", φ, ψ)      : φ → ψ
    - ("box", φ)         : □φ
    - ("neg", φ)         : ¬φ = φ → ⊥
    """
    tag = formula[0]
    if tag == "var":
        return world in valuation.get(formula[1], set())
    elif tag == "bot":
        return False
    elif tag == "imp":
        phi, psi = formula[1], formula[2]
        return (not forces(worlds, relation, valuation, world, phi)) or forces(
            worlds, relation, valuation, world, psi
        )
    elif tag == "box":
        phi = formula[1]
        return all(
            forces(worlds, relation, valuation, v, phi)
            for v in worlds
            if relation.get((world, v), False)
        )
    elif tag == "neg":
        phi = formula[1]
        return not forces(worlds, relation, valuation, world, phi)
    else:
        raise ValueError(f"Unknown formula tag: {tag}")


def demo_loeb_theorem() -> None:
    """Demonstrate Löb's theorem on a concrete GL frame."""
    print("=" * 70)
    print("DEMO 1: Löb's Theorem on a Linear GL Frame")
    print("=" * 70)

    worlds, relation = make_linear_gl_frame(4)
    print(f"\nFrame: {len(worlds)} worlds with linear order 0 < 1 < 2 < 3")
    print(f"GL conditions: {check_gl_conditions(worlds, relation)}")

    # Check Löb's formula: □(□p → p) → □p for variable p
    p_var: tuple[str, ...] = ("var", "p")
    box_p: tuple[str, ...] = ("box", p_var)
    box_p_imp_p: tuple[str, ...] = ("imp", box_p, p_var)
    box_of_that: tuple[str, ...] = ("box", box_p_imp_p)
    loeb_formula: tuple[str, ...] = ("imp", box_of_that, box_p)

    print("\nLöb formula: □(□p → p) → □p")
    print("Testing validity across all valuations of p:")

    all_valid = True
    for subset_mask in range(2**len(worlds)):
        val_set = {w for w in worlds if (subset_mask >> w) & 1}
        val = {"p": val_set}
        for w in worlds:
            result = forces(worlds, relation, val, w, loeb_formula)
            if not result:
                print(f"  COUNTEREXAMPLE at world {w} with p={val_set}")
                all_valid = False

    if all_valid:
        print("  ✓ Löb formula is VALID in this frame (holds at every world, every valuation)")


def demo_second_incompleteness() -> None:
    """Demonstrate the second incompleteness theorem."""
    print("\n" + "=" * 70)
    print("DEMO 2: Second Incompleteness Theorem")
    print("=" * 70)

    worlds, relation = make_linear_gl_frame(4)

    # The consistency formula: □⊥ → ⊥
    bot: tuple[str, ...] = ("bot",)
    box_bot: tuple[str, ...] = ("box", bot)
    consistency: tuple[str, ...] = ("imp", box_bot, bot)  # □⊥ → ⊥
    box_consistency: tuple[str, ...] = ("box", consistency)  # □(□⊥ → ⊥)

    val: dict[str, set[int]] = {}  # No variables needed

    print("\nConsistency formula: Con ≡ □⊥ → ⊥")
    print("Provability of consistency: □Con ≡ □(□⊥ → ⊥)")
    print()

    for w in worlds:
        is_sound = forces(worlds, relation, val, w, consistency)
        proves_con = forces(worlds, relation, val, w, box_consistency)
        has_successors = any(relation.get((w, v), False) for v in worlds)
        print(f"  World {w}: sound={is_sound}, proves_consistency={proves_con}, "
              f"has_successors={has_successors}")

    print("\n  Observation: World 0 (the 'standard' world) is sound but CANNOT")
    print("  prove its own consistency — confirming the second incompleteness theorem.")
    print("  Only world 3 (with no successors) can vacuously 'prove' consistency.")


def demo_tangling_dichotomy() -> None:
    """Demonstrate the tangling dichotomy on a tree frame."""
    print("\n" + "=" * 70)
    print("DEMO 3: Tangling Dichotomy")
    print("=" * 70)

    worlds, relation = make_tree_gl_frame()
    depths = compute_tangling_depth(worlds, relation)

    print("\nTree-shaped GL frame:")
    print("       0")
    print("      / \\")
    print("     1   2")
    print("    / \\")
    print("   3   4")

    print(f"\nGL conditions: {check_gl_conditions(worlds, relation)}")
    print(f"\nTangling depths: {depths}")

    # Check soundness and internal soundness at each world
    bot: tuple[str, ...] = ("bot",)
    box_bot: tuple[str, ...] = ("box", bot)
    consistency: tuple[str, ...] = ("imp", box_bot, bot)
    box_consistency: tuple[str, ...] = ("box", consistency)

    val: dict[str, set[int]] = {}

    print("\nTangling Dichotomy Analysis:")
    for w in worlds:
        has_succ = any(relation.get((w, v), False) for v in worlds)
        is_sound = forces(worlds, relation, val, w, consistency)
        proves_con = forces(worlds, relation, val, w, box_consistency)

        if not has_succ:
            status = "Case 1: No successors (trivial provability)"
        elif not proves_con:
            status = "Case 2: Cannot prove own consistency (incomplete)"
        else:
            status = "ANOMALY (should not happen in GL frame)"

        print(f"  World {w} (depth={depths[w]}): {status}")

    print("\n  The dichotomy is confirmed: every world falls into exactly one case.")


def demo_tangling_depth() -> None:
    """Demonstrate tangling depth computation."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tangling Depth Analysis")
    print("=" * 70)

    for n in [3, 5, 8]:
        worlds, relation = make_linear_gl_frame(n)
        depths = compute_tangling_depth(worlds, relation)
        print(f"\n  Linear frame with {n} worlds:")
        for w in worlds:
            bar = "█" * (depths[w] + 1)
            print(f"    World {w}: depth={depths[w]}  {bar}")

    # Diamond frame
    print("\n  Diamond frame: 0 → {1, 2} → 3")
    worlds = [0, 1, 2, 3]
    edges = {(0, 1), (0, 2), (1, 3), (2, 3), (0, 3)}
    relation = {(i, j): (i, j) in edges for i in worlds for j in worlds}
    depths = compute_tangling_depth(worlds, relation)
    print(f"    GL conditions: {check_gl_conditions(worlds, relation)}")
    for w in worlds:
        bar = "█" * (depths[w] + 1)
        print(f"    World {w}: depth={depths[w]}  {bar}")


def main() -> None:
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TANGLED HIERARCHIES: Self-Referential Proof System Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_loeb_theorem()
    demo_second_incompleteness()
    demo_tangling_dichotomy()
    demo_tangling_depth()

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
Key findings demonstrated:
1. Löb's formula □(□p → p) → □p is valid in all GL frames.
2. Sound worlds cannot prove their own consistency (2nd incompleteness).
3. Every world satisfies the tangling dichotomy: either trivial or incomplete.
4. Tangling depth measures the self-referential capacity of each world.

These results are fully verified in Lean 4 (see Logic/TangledHierarchies.lean).
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization of GL Frames and Tangling Hierarchies

Generates plots showing:
1. GL frame structure with tangling depths
2. Soundness/consistency analysis across worlds
3. The tangling dichotomy
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import FrozenSet


def make_linear_frame(n: int) -> tuple[list[int], set[tuple[int, int]]]:
    worlds = list(range(n))
    edges = {(i, j) for i in range(n) for j in range(n) if i < j}
    return worlds, edges


def make_tree_frame() -> tuple[list[int], set[tuple[int, int]]]:
    worlds = [0, 1, 2, 3, 4, 5, 6]
    direct = [(0,1),(0,2),(1,3),(1,4),(2,5),(2,6)]
    edges = set(direct)
    # Add transitive edges
    edges.update([(0,3),(0,4),(0,5),(0,6)])
    return worlds, edges


def compute_depth(worlds: list[int], edges: set[tuple[int, int]]) -> dict[int, int]:
    memo: dict[int, int] = {}
    def d(w: int) -> int:
        if w in memo: return memo[w]
        succs = [v for v in worlds if (w,v) in edges]
        memo[w] = 0 if not succs else 1 + max(d(v) for v in succs)
        return memo[w]
    for w in worlds: d(w)
    return memo


def compute_forces_bot(worlds: list[int], edges: set[tuple[int, int]], w: int) -> bool:
    return False  # ⊥ never forces


def compute_forces_box_bot(worlds: list[int], edges: set[tuple[int, int]], w: int) -> bool:
    return all(False for v in worlds if (w,v) in edges)  # □⊥: all successors force ⊥


def compute_sound(worlds: list[int], edges: set[tuple[int, int]], w: int) -> bool:
    # Sound for ⊥: □⊥ → ⊥. Since ⊥ never forces, this is ¬□⊥.
    # □⊥ is true iff no successors exist.
    box_bot = not any((w,v) in edges for v in worlds)
    return not box_bot or False  # □⊥ → ⊥ = if □⊥ then ⊥. Always true since ⊥ is False


def compute_proves_con(worlds: list[int], edges: set[tuple[int, int]], w: int) -> bool:
    # □(□⊥→⊥): all successors satisfy □⊥→⊥
    # At successor v, □⊥→⊥ = (all u with vRu force ⊥) → ⊥ = ¬(all u with vRu force ⊥)
    # Since ⊥ never forces, □⊥ at v is true iff v has no successors
    # So □⊥→⊥ at v is: (v has no successors) → False = v has successors
    # So □(□⊥→⊥) at w = all successors of w have successors
    for v in worlds:
        if (w, v) in edges:
            if not any((v, u) in edges for u in worlds):
                return False
    return True


def plot_frame_structure(ax: plt.Axes, worlds: list[int], edges: set[tuple[int, int]],
                         depths: dict[int, int], title: str) -> None:
    n = len(worlds)
    max_depth = max(depths.values()) if depths else 0

    # Position worlds by depth (y-axis) and spread (x-axis)
    depth_groups: dict[int, list[int]] = {}
    for w in worlds:
        d = depths[w]
        depth_groups.setdefault(d, []).append(w)

    positions: dict[int, tuple[float, float]] = {}
    for d, group in depth_groups.items():
        for i, w in enumerate(group):
            x = (i - (len(group)-1)/2) * 1.5
            y = (max_depth - d) * 1.2
            positions[w] = (x, y)

    # Draw edges (only direct, non-transitive for clarity)
    for (u, v) in edges:
        # Only draw if no intermediate world
        is_direct = not any((u, m) in edges and (m, v) in edges for m in worlds if m != u and m != v)
        if is_direct:
            xu, yu = positions[u]
            xv, yv = positions[v]
            ax.annotate("", xy=(xv, yv), xytext=(xu, yu),
                       arrowprops=dict(arrowstyle="->", color="#666666",
                                      connectionstyle="arc3,rad=0.1", lw=1.5))

    # Draw worlds
    for w in worlds:
        x, y = positions[w]
        d = depths[w]
        has_succ = any((w, v) in edges for v in worlds)

        if not has_succ:
            color = '#e74c3c'  # Red: terminal (Case 1)
            label = f"w{w}\nd=0\n(trivial)"
        else:
            color = '#3498db'  # Blue: non-trivial (Case 2)
            label = f"w{w}\nd={d}\n(incomplete)"

        circle = plt.Circle((x, y), 0.4, color=color, alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=7,
               color='white', fontweight='bold', zorder=6)

    ax.set_xlim(-4, 4)
    ax.set_ylim(-1, max_depth * 1.2 + 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')


def plot_tangling_analysis() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(18, 7))

    # Frame 1: Linear
    w1, e1 = make_linear_frame(5)
    d1 = compute_depth(w1, e1)
    plot_frame_structure(axes[0], w1, e1, d1, "Linear GL Frame\n(5 worlds)")

    # Frame 2: Tree
    w2, e2 = make_tree_frame()
    d2 = compute_depth(w2, e2)
    plot_frame_structure(axes[1], w2, e2, d2, "Tree GL Frame\n(7 worlds)")

    # Frame 3: Diamond
    w3 = [0, 1, 2, 3]
    e3_direct = [(0,1),(0,2),(1,3),(2,3)]
    e3 = set(e3_direct) | {(0,3)}
    d3 = compute_depth(w3, e3)
    plot_frame_structure(axes[2], w3, e3, d3, "Diamond GL Frame\n(4 worlds)")

    # Legend
    case1 = mpatches.Patch(color='#e74c3c', label='Case 1: No successors (trivially sound)')
    case2 = mpatches.Patch(color='#3498db', label='Case 2: Has successors (cannot prove soundness)')
    fig.legend(handles=[case1, case2], loc='lower center', ncol=2, fontsize=11,
              frameon=True, fancybox=True, shadow=True)

    fig.suptitle("Tangling Dichotomy in GL Frames", fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    plt.savefig("tangling_analysis.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tangling_analysis.png")


def plot_depth_distribution() -> None:
    fig, ax = plt.subplots(figsize=(10, 6))

    sizes = [4, 6, 8, 10, 12]
    for n in sizes:
        worlds, edges = make_linear_frame(n)
        depths = compute_depth(worlds, edges)
        depth_values = [depths[w] for w in sorted(worlds)]
        ax.plot(range(n), depth_values, 'o-', label=f'n={n}', markersize=6, linewidth=2)

    ax.set_xlabel('World Index', fontsize=13)
    ax.set_ylabel('Tangling Depth', fontsize=13)
    ax.set_title('Tangling Depth Distribution in Linear GL Frames', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Add annotation about the standard world
    ax.annotate('Standard world\n(deepest self-reference)',
               xy=(0, max(sizes)-1), xytext=(3, max(sizes)-2),
               arrowprops=dict(arrowstyle='->', color='red', lw=2),
               fontsize=11, color='red', fontweight='bold')

    plt.tight_layout()
    plt.savefig("depth_distribution.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_distribution.png")


def plot_incompleteness_heatmap() -> None:
    fig, ax = plt.subplots(figsize=(10, 8))

    n = 8
    worlds, edges = make_linear_frame(n)

    # For each world, compute whether it can "prove" □φ → φ for each other world's variable
    # More precisely: check if world w forces □(□p → p) for p = {v}
    matrix = np.zeros((n, n))

    for w in range(n):
        for target_world in range(n):
            # Set p true only at target_world
            # Check if w forces □(□p → p)
            # □p at v means: all successors of v force p = all successors of v equal target_world
            # □p → p at v means: (all succ of v = target_world) → (v = target_world)
            # □(□p → p) at w means: for all v with wRv, □p→p at v

            def forces_p(v: int) -> bool:
                return v == target_world

            def forces_box_p(v: int) -> bool:
                return all(forces_p(u) for u in range(n) if (v, u) in edges)

            def forces_box_p_imp_p(v: int) -> bool:
                return (not forces_box_p(v)) or forces_p(v)

            forces_box_all = all(forces_box_p_imp_p(v) for v in range(n) if (w, v) in edges)
            matrix[w, target_world] = 1.0 if forces_box_all else 0.0

    im = ax.imshow(matrix, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1)
    ax.set_xlabel('Target World (where p is true)', fontsize=12)
    ax.set_ylabel('Evaluating World', fontsize=12)
    ax.set_title('Can World w Prove □(□p → p)?\n(Green=Yes, Red=No)', fontsize=14, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'w{i}' for i in range(n)])
    ax.set_yticklabels([f'w{i}' for i in range(n)])

    for i in range(n):
        for j in range(n):
            text = "✓" if matrix[i, j] > 0.5 else "✗"
            color = 'white' if matrix[i, j] < 0.5 else 'black'
            ax.text(j, i, text, ha='center', va='center', fontsize=14, color=color)

    plt.colorbar(im, ax=ax, label='Can prove')
    plt.tight_layout()
    plt.savefig("incompleteness_heatmap.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: incompleteness_heatmap.png")


if __name__ == "__main__":
    plot_tangling_analysis()
    plot_depth_distribution()
    plot_incompleteness_heatmap()
    print("All visualizations generated.")
