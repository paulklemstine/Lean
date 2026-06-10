#!/usr/bin/env python3
"""
Tangled Hierarchies: Proof Systems That Reference Their Own Soundness
=====================================================================

Demonstration of GL frame semantics, Löb's theorem, and the tangling dichotomy
through concrete finite examples.
"""

from dataclasses import dataclass
from typing import Callable


@dataclass
class GLFrame:
    """A GL frame: a set of worlds with transitive, converse well-founded R."""
    worlds: list[int]
    edges: list[tuple[int, int]]  # (w, v) means R(w, v)

    def R(self, w: int, v: int) -> bool:
        return (w, v) in self._edge_set

    def __post_init__(self):
        self._edge_set = set(self.edges)

    def successors(self, w: int) -> list[int]:
        return [v for v in self.worlds if self.R(w, v)]

    def is_irreflexive(self) -> bool:
        return all(not self.R(w, w) for w in self.worlds)

    def is_transitive(self) -> bool:
        for u in self.worlds:
            for v in self.worlds:
                for w in self.worlds:
                    if self.R(u, v) and self.R(v, w) and not self.R(u, w):
                        return False
        return True

    def is_acyclic(self) -> bool:
        """Check converse well-foundedness (= acyclicity for finite frames)."""
        visited = set()
        in_stack = set()

        def dfs(w):
            visited.add(w)
            in_stack.add(w)
            for v in self.successors(w):
                if v in in_stack:
                    return False
                if v not in visited:
                    if not dfs(v):
                        return False
            in_stack.discard(w)
            return True

        for w in self.worlds:
            if w not in visited:
                if not dfs(w):
                    return False
        return True

    def is_gl_frame(self) -> bool:
        return self.is_irreflexive() and self.is_transitive() and self.is_acyclic()

    def rdepth(self, w: int) -> int:
        succs = self.successors(w)
        if not succs:
            return 0
        return 1 + max(self.rdepth(v) for v in succs)


# Modal formula representation
class MFormula:
    pass

class Var(MFormula):
    def __init__(self, name: str):
        self.name = name
    def __repr__(self): return self.name

class Bot(MFormula):
    def __repr__(self): return "⊥"

class Imp(MFormula):
    def __init__(self, left: MFormula, right: MFormula):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} → {self.right})"

class Box(MFormula):
    def __init__(self, inner: MFormula):
        self.inner = inner
    def __repr__(self): return f"□{self.inner}"

def Neg(phi): return Imp(phi, Bot())
def Top(): return Neg(Bot())
def Con(): return Neg(Box(Bot()))


def forces(frame: GLFrame, V: Callable, w: int, phi: MFormula) -> bool:
    """Model checking: does world w force formula phi?"""
    if isinstance(phi, Var):
        return V(phi.name, w)
    elif isinstance(phi, Bot):
        return False
    elif isinstance(phi, Imp):
        return (not forces(frame, V, w, phi.left)) or forces(frame, V, w, phi.right)
    elif isinstance(phi, Box):
        return all(forces(frame, V, v, phi.inner) for v in frame.successors(w))
    raise ValueError(f"Unknown formula type: {type(phi)}")


def is_world_sound(frame: GLFrame, V: Callable, w: int, formulas: list[MFormula]) -> bool:
    """Check if world w is sound for the given formulas."""
    return all(
        forces(frame, V, w, Imp(Box(phi), phi))
        for phi in formulas
    )


# ============================================================
# Demo 1: Three-World Frame
# ============================================================
print("=" * 60)
print("Demo 1: Three-World GL Frame")
print("=" * 60)

three_frame = GLFrame(
    worlds=[0, 1, 2],
    edges=[(0, 1), (0, 2), (1, 2)]
)

print(f"Worlds: {three_frame.worlds}")
print(f"Edges: {three_frame.edges}")
print(f"Is GL frame: {three_frame.is_gl_frame()}")
print(f"Depths: {[three_frame.rdepth(w) for w in three_frame.worlds]}")

# Valuation: all variables false everywhere
V_false = lambda name, w: False
# Valuation: p true at world 2 only
V_p_at_2 = lambda name, w: (name == "p" and w == 2)

p = Var("p")
bot = Bot()

print("\n--- Vacuous provability at world 2 ---")
print(f"World 2 ⊩ □p:  {forces(three_frame, V_p_at_2, 2, Box(p))}")
print(f"World 2 ⊩ □⊥:  {forces(three_frame, V_false, 2, Box(bot))}")
print(f"World 2 ⊩ □p → p (with p true at 2): {forces(three_frame, V_p_at_2, 2, Imp(Box(p), p))}")
print(f"World 2 ⊩ □p → p (with p false at 2): {forces(three_frame, V_false, 2, Imp(Box(p), p))}")

print("\n--- Second incompleteness at world 0 ---")
con = Con()
box_con = Box(Imp(Box(bot), bot))
print(f"World 0 ⊩ Con:     {forces(three_frame, V_false, 0, con)}")
print(f"World 0 ⊩ □Con:    {forces(three_frame, V_false, 0, box_con)}")
print(f"World 0 ⊩ □⊥:     {forces(three_frame, V_false, 0, Box(bot))}")
print(f"World 0 ⊩ □⊥ → ⊥: {forces(three_frame, V_false, 0, Imp(Box(bot), bot))}")

# Löb's theorem demo
loeb_formula = Imp(Box(Imp(Box(bot), bot)), Box(bot))
print(f"\nWorld 0 ⊩ □(□⊥→⊥) → □⊥ (Löb): {forces(three_frame, V_false, 0, loeb_formula)}")
print(f"World 1 ⊩ □(□⊥→⊥) → □⊥ (Löb): {forces(three_frame, V_false, 1, loeb_formula)}")
print(f"World 2 ⊩ □(□⊥→⊥) → □⊥ (Löb): {forces(three_frame, V_false, 2, loeb_formula)}")


# ============================================================
# Demo 2: Tangling Dichotomy
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Tangling Dichotomy")
print("=" * 60)

# Check: for each world, is it terminal or tangled?
for w in three_frame.worlds:
    succs = three_frame.successors(w)
    if not succs:
        print(f"World {w}: TERMINAL (case 1) - no successors, vacuously proves everything")
    else:
        # Try to find unprovable soundness formula
        box_sound = Box(Imp(Box(bot), bot))
        can_prove = forces(three_frame, V_false, w, box_sound)
        print(f"World {w}: TANGLED (case 2) - successors={succs}, "
              f"can prove □(□⊥→⊥)={can_prove}")


# ============================================================
# Demo 3: Iterated Consistency Hierarchy
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Iterated Consistency Hierarchy")
print("=" * 60)

# Build a deeper frame to show the hierarchy
deep_frame = GLFrame(
    worlds=list(range(6)),
    edges=[(i, j) for i in range(6) for j in range(i+1, 6)]
)

print(f"6-world chain: worlds={deep_frame.worlds}")
print(f"Is GL frame: {deep_frame.is_gl_frame()}")
print(f"Depths: {[deep_frame.rdepth(w) for w in deep_frame.worlds]}")

def iter_con(n: int) -> MFormula:
    """Build Con^n formula."""
    if n == 0:
        return Top()
    return Neg(Box(Neg(iter_con(n - 1))))

print("\nIterated consistency at world 0:")
for n in range(6):
    formula = iter_con(n)
    result = forces(deep_frame, V_false, 0, formula)
    print(f"  World 0 ⊩ Con^{n}: {result}")

print("\nIterated consistency at world 3:")
for n in range(6):
    formula = iter_con(n)
    result = forces(deep_frame, V_false, 3, formula)
    print(f"  World 3 ⊩ Con^{n}: {result}")


# ============================================================
# Demo 4: Disjoint Union
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Disjoint Union of GL Frames")
print("=" * 60)

frame_A = GLFrame(worlds=[0, 1], edges=[(0, 1)])
frame_B = GLFrame(worlds=[10, 11, 12], edges=[(10, 11), (10, 12), (11, 12)])

# Simulate disjoint union
union_frame = GLFrame(
    worlds=frame_A.worlds + frame_B.worlds,
    edges=frame_A.edges + frame_B.edges  # No cross-edges
)

print(f"Frame A: worlds={frame_A.worlds}, edges={frame_A.edges}")
print(f"Frame B: worlds={frame_B.worlds}, edges={frame_B.edges}")
print(f"Union: worlds={union_frame.worlds}, edges={union_frame.edges}")
print(f"Union is GL frame: {union_frame.is_gl_frame()}")
print(f"Union depths: {[(w, union_frame.rdepth(w)) for w in union_frame.worlds]}")

# Show independence: world 0 cannot reason about world 10
print(f"\nCross-accessibility R(0, 10): {union_frame.R(0, 10)}")
print(f"Cross-accessibility R(10, 0): {union_frame.R(10, 0)}")
print("Independent systems remain independent in the union!")


print("\n" + "=" * 60)
print("All demos completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: GL Frame Structure and Tangling Hierarchy
========================================================

Generates a visualization of GL frames showing:
1. World accessibility structure
2. Tangling depth coloring
3. Iterated consistency satisfaction
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_gl_frame():
    """Draw a 6-world GL frame with tangling analysis."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Frame data
    n_worlds = 6
    worlds = list(range(n_worlds))
    edges = [(i, j) for i in range(n_worlds) for j in range(i + 1, n_worlds)]

    # Positions: arrange in a line
    positions = {w: (w * 1.5, 0) for w in worlds}
    depths = {w: n_worlds - 1 - w for w in worlds}

    # --- Panel 1: Frame Structure ---
    ax = axes[0]
    ax.set_title("GL Frame Structure\n(6-world chain)", fontsize=13, fontweight='bold')

    # Draw edges
    for (u, v) in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        # Only draw direct edges (not transitive closure) for clarity
        if v == u + 1:
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="->", color="steelblue",
                                       lw=2, connectionstyle="arc3,rad=0.1"))

    # Draw worlds
    cmap = plt.cm.YlOrRd
    for w in worlds:
        x, y = positions[w]
        color = cmap(depths[w] / max(depths.values()))
        circle = plt.Circle((x, y), 0.3, color=color, ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, f"w{w}", ha='center', va='center', fontsize=11,
                fontweight='bold', zorder=6)
        ax.text(x, y - 0.5, f"depth={depths[w]}", ha='center', va='top',
                fontsize=9, color='gray')

    ax.set_xlim(-0.8, (n_worlds - 1) * 1.5 + 0.8)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=cmap(0.0), label='Depth 0 (terminal)'),
        mpatches.Patch(facecolor=cmap(0.5), label='Depth 2-3'),
        mpatches.Patch(facecolor=cmap(1.0), label='Depth 5 (deepest)'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=8)

    # --- Panel 2: Tangling Dichotomy ---
    ax = axes[1]
    ax.set_title("Tangling Dichotomy\n(sound world classification)", fontsize=13, fontweight='bold')

    categories = []
    for w in worlds:
        succs = [v for v in worlds if (w, v) in set(edges)]
        if not succs:
            categories.append("TERMINAL")
        else:
            categories.append("TANGLED")

    colors = {'TERMINAL': '#2ecc71', 'TANGLED': '#e74c3c'}
    bar_colors = [colors[c] for c in categories]

    bars = ax.barh([f"World {w}" for w in worlds], [depths[w] for w in worlds],
                   color=bar_colors, edgecolor='black', linewidth=1)

    ax.set_xlabel("R-Depth", fontsize=11)
    ax.set_xlim(0, 6)

    # Add category labels
    for i, (bar, cat) in enumerate(zip(bars, categories)):
        ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height() / 2,
                cat, ha='left', va='center', fontsize=9, fontweight='bold',
                color=colors[cat])

    legend_elements = [
        mpatches.Patch(facecolor='#2ecc71', label='Terminal (vacuously sound)'),
        mpatches.Patch(facecolor='#e74c3c', label='Tangled (has blind spots)'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=8)

    # --- Panel 3: Iterated Consistency ---
    ax = axes[2]
    ax.set_title("Iterated Consistency Hierarchy\nCon^n satisfaction", fontsize=13, fontweight='bold')

    # Compute which Con^n each world satisfies
    # In the linear chain, world w satisfies Con^n iff n ≤ n_worlds - 1 - w
    # (because Con^n requires a chain of n accessible successors)
    matrix = np.zeros((n_worlds, n_worlds))
    for w in worlds:
        for n in range(n_worlds):
            # World w satisfies Con^n iff there's a chain of length n from w
            matrix[w, n] = 1.0 if n <= depths[w] else 0.0

    im = ax.imshow(matrix, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1,
                   interpolation='nearest')
    ax.set_xticks(range(n_worlds))
    ax.set_xticklabels([f"Con^{n}" for n in range(n_worlds)], fontsize=9)
    ax.set_yticks(range(n_worlds))
    ax.set_yticklabels([f"World {w}" for w in worlds], fontsize=9)
    ax.set_xlabel("Consistency Level", fontsize=11)
    ax.set_ylabel("World", fontsize=11)

    # Add text annotations
    for w in worlds:
        for n in range(n_worlds):
            val = "✓" if matrix[w, n] else "✗"
            color = 'white' if matrix[w, n] else 'black'
            ax.text(n, w, val, ha='center', va='center', fontsize=12,
                    fontweight='bold', color=color)

    plt.tight_layout()
    plt.savefig("gl_frame_analysis.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gl_frame_analysis.png")


if __name__ == "__main__":
    draw_gl_frame()
