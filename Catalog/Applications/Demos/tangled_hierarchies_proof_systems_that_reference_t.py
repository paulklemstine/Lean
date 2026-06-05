#!/usr/bin/env python3
"""
Tangled Hierarchies: Interactive Demonstration

Demonstrates the key concepts from the formalized theory of self-referential
proof systems, including modal depth computation, k-soundness checking,
and the construction of canonical GL frames.
"""

from dataclasses import dataclass
from typing import Optional
from enum import Enum


# ============================================================
# Modal Formulas
# ============================================================

class FormulaType(Enum):
    VAR = "var"
    BOT = "bot"
    IMP = "imp"
    BOX = "box"


@dataclass
class Formula:
    """Modal formula in the language of provability logic."""
    kind: FormulaType
    var_name: Optional[str] = None
    left: Optional['Formula'] = None
    right: Optional['Formula'] = None
    inner: Optional['Formula'] = None

    def __repr__(self):
        if self.kind == FormulaType.VAR:
            return self.var_name
        elif self.kind == FormulaType.BOT:
            return "⊥"
        elif self.kind == FormulaType.IMP:
            return f"({self.left} → {self.right})"
        elif self.kind == FormulaType.BOX:
            return f"□{self.inner}"


def var(name: str) -> Formula:
    return Formula(FormulaType.VAR, var_name=name)

def bot() -> Formula:
    return Formula(FormulaType.BOT)

def imp(a: Formula, b: Formula) -> Formula:
    return Formula(FormulaType.IMP, left=a, right=b)

def box(a: Formula) -> Formula:
    return Formula(FormulaType.BOX, inner=a)

def neg(a: Formula) -> Formula:
    return imp(a, bot())

def con() -> Formula:
    """Consistency formula: ¬□⊥"""
    return neg(box(bot()))


# ============================================================
# Modal Depth
# ============================================================

def modal_depth(phi: Formula) -> int:
    """Compute the modal depth of a formula."""
    if phi.kind == FormulaType.VAR:
        return 0
    elif phi.kind == FormulaType.BOT:
        return 0
    elif phi.kind == FormulaType.IMP:
        return max(modal_depth(phi.left), modal_depth(phi.right))
    elif phi.kind == FormulaType.BOX:
        return modal_depth(phi.inner) + 1


def iterated_con(n: int) -> Formula:
    """The n-th iterated consistency formula."""
    if n == 0:
        return bot()
    else:
        inner = iterated_con(n - 1)
        return imp(box(inner), inner)


# ============================================================
# GL Frames and Forcing
# ============================================================

@dataclass
class GLFrame:
    """A finite GL frame (W, R) with W = {0, ..., n-1}."""
    n: int  # number of worlds
    R: list[list[bool]]  # adjacency matrix

    def successors(self, w: int) -> list[int]:
        return [v for v in range(self.n) if self.R[w][v]]

    def is_transitive(self) -> bool:
        for u in range(self.n):
            for v in range(self.n):
                for w in range(self.n):
                    if self.R[u][v] and self.R[v][w] and not self.R[u][w]:
                        return False
        return True

    def is_irreflexive(self) -> bool:
        return all(not self.R[w][w] for w in range(self.n))


def canonical_gl_frame(n: int) -> GLFrame:
    """The canonical GL frame on n+1 worlds: i R j iff i < j."""
    size = n + 1
    R = [[i < j for j in range(size)] for i in range(size)]
    return GLFrame(size, R)


def forces(frame: GLFrame, V: dict[str, set[int]], w: int, phi: Formula) -> bool:
    """Check if world w forces formula phi in the given frame with valuation V."""
    if phi.kind == FormulaType.VAR:
        return w in V.get(phi.var_name, set())
    elif phi.kind == FormulaType.BOT:
        return False
    elif phi.kind == FormulaType.IMP:
        return not forces(frame, V, w, phi.left) or forces(frame, V, w, phi.right)
    elif phi.kind == FormulaType.BOX:
        return all(forces(frame, V, v, phi.inner) for v in frame.successors(w))


def is_k_sound(frame: GLFrame, V: dict[str, set[int]], w: int, k: int,
               variables: list[str]) -> bool:
    """Check if world w is k-sound (approximately, by sampling formulas)."""
    formulas = generate_formulas(k, variables)
    for phi in formulas:
        if modal_depth(phi) <= k:
            if forces(frame, V, w, box(phi)) and not forces(frame, V, w, phi):
                return False
    return True


def generate_formulas(max_depth: int, variables: list[str]) -> list[Formula]:
    """Generate a sample of formulas up to the given modal depth."""
    result = [bot()] + [var(v) for v in variables]
    if max_depth == 0:
        return result

    prev = generate_formulas(max_depth - 1, variables)

    # Add boxes of previous formulas
    for phi in prev:
        result.append(box(phi))

    # Add some implications
    for phi in prev[:5]:
        for psi in prev[:5]:
            result.append(imp(phi, psi))

    return result


# ============================================================
# Demonstrations
# ============================================================

def demo_modal_depth():
    """Demonstrate modal depth computation."""
    print("=" * 60)
    print("DEMO 1: Modal Depth of Formulas")
    print("=" * 60)

    p = var("p")
    formulas = [
        ("p", p),
        ("⊥", bot()),
        ("□p", box(p)),
        ("□⊥ → ⊥ (consistency)", con()),
        ("□(□⊥ → ⊥)", box(con())),
    ]

    for name, phi in formulas:
        print(f"  d({name}) = {modal_depth(phi)}")

    print("\nIterated consistency formulas:")
    for n in range(6):
        phi = iterated_con(n)
        print(f"  Con_{n} = {phi}")
        print(f"  d(Con_{n}) = {modal_depth(phi)}")
    print()


def demo_canonical_frame():
    """Demonstrate the canonical GL frame."""
    print("=" * 60)
    print("DEMO 2: Canonical GL Frame")
    print("=" * 60)

    n = 4
    frame = canonical_gl_frame(n)
    print(f"Canonical frame on {n+1} worlds (0, 1, 2, 3, 4):")
    print(f"  Transitive: {frame.is_transitive()}")
    print(f"  Irreflexive: {frame.is_irreflexive()}")

    for w in range(frame.n):
        succs = frame.successors(w)
        print(f"  World {w} sees: {succs}")

    # Maximal chain
    chain = list(range(n + 1))
    print(f"  Maximal chain: {' → '.join(map(str, chain))}")
    print(f"  Chain length: {n}")
    print()


def demo_forcing():
    """Demonstrate the forcing relation."""
    print("=" * 60)
    print("DEMO 3: Forcing Relation and Soundness")
    print("=" * 60)

    n = 3
    frame = canonical_gl_frame(n)
    V = {"p": {1, 3}}  # p is true at worlds 1 and 3

    p = var("p")
    formulas = [
        ("p", p),
        ("□p", box(p)),
        ("□⊥", box(bot())),
        ("□⊥ → ⊥", con()),
        ("□(□⊥ → ⊥)", box(con())),
    ]

    print(f"Frame: canonical({n}), V(p) = {{1, 3}}")
    for w in range(frame.n):
        print(f"\n  World {w}:")
        for name, phi in formulas:
            val = forces(frame, V, w, phi)
            print(f"    {w} ⊩ {name}: {val}")
    print()


def demo_k_soundness():
    """Demonstrate k-soundness checking."""
    print("=" * 60)
    print("DEMO 4: k-Soundness Hierarchy")
    print("=" * 60)

    n = 4
    frame = canonical_gl_frame(n)
    V = {"p": {2, 4}}

    variables = ["p"]
    print(f"Frame: canonical({n}), V(p) = {{2, 4}}")

    for w in range(frame.n):
        print(f"\n  World {w} (successors: {frame.successors(w)}):")
        for k in range(4):
            sound = is_k_sound(frame, V, w, k, variables)
            print(f"    {k}-sound: {sound}")
    print()


def demo_tangling():
    """Demonstrate the tangling phenomenon."""
    print("=" * 60)
    print("DEMO 5: The Tangling Phenomenon")
    print("=" * 60)

    n = 3
    frame = canonical_gl_frame(n)
    V: dict[str, set[int]] = {}

    con_formula = con()  # □⊥ → ⊥
    box_con = box(con_formula)  # □(□⊥ → ⊥)

    print(f"Frame: canonical({n})")
    for w in range(frame.n):
        con_val = forces(frame, V, w, con_formula)
        box_con_val = forces(frame, V, w, box_con)
        consistent = not forces(frame, V, w, bot())

        print(f"\n  World {w}:")
        print(f"    Consistent: {consistent}")
        print(f"    {w} ⊩ □⊥ → ⊥ (sound for ⊥): {con_val}")
        print(f"    {w} ⊩ □(□⊥ → ⊥) (proves own soundness): {box_con_val}")

        if con_val and consistent and not box_con_val:
            print(f"    *** TANGLING: World {w} IS sound but CANNOT PROVE its soundness ***")
        if con_val and consistent and box_con_val:
            print(f"    *** IMPOSSIBLE by 2nd incompleteness theorem ***")
    print()


def demo_reflective_hierarchy():
    """Demonstrate reflective hierarchies."""
    print("=" * 60)
    print("DEMO 6: Reflective Hierarchy")
    print("=" * 60)

    n = 5
    frame = canonical_gl_frame(n)
    V: dict[str, set[int]] = {}

    print(f"Frame: canonical({n})")
    print(f"Hierarchy: 0 → 1 → 2 → 3 → 4 → 5")
    print(f"Graded soundness: world i is (5-i)-sound\n")

    for i in range(n + 1):
        level = n - i
        succs = frame.successors(i)
        isolated = len(succs) == 0
        con_val = forces(frame, V, i, con())

        print(f"  World {i}: {level}-sound, successors={succs}")
        if isolated:
            print(f"    (isolated — □φ vacuously true for all φ)")
        print(f"    Satisfies □⊥ → ⊥: {con_val}")

    print(f"\n  World 0 cannot prove □(□⊥ → ⊥) — hierarchy incompleteness!")
    print()


if __name__ == "__main__":
    demo_modal_depth()
    demo_canonical_frame()
    demo_forcing()
    demo_k_soundness()
    demo_tangling()
    demo_reflective_hierarchy()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Tangling Hierarchy in GL Frames

Produces a figure showing the canonical GL frame, the k-soundness
levels at each world, and the tangling gap.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_canonical_frame(ax, n=5):
    """Draw the canonical GL frame on n+1 worlds."""
    ax.set_title(f"Canonical GL Frame (n={n})", fontsize=14, fontweight='bold')

    # Position worlds in a line
    positions = {i: (i * 1.5, 0) for i in range(n + 1)}

    # Draw edges (i → j for i < j)
    for i in range(n + 1):
        for j in range(i + 1, n + 1):
            x1, y1 = positions[i]
            x2, y2 = positions[j]
            # Only draw direct successor edges for clarity
            if j == i + 1:
                ax.annotate('', xy=(x2 - 0.2, y2), xytext=(x1 + 0.2, y1),
                           arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    # Draw worlds
    for i in range(n + 1):
        x, y = positions[i]
        consistent = i < n  # last world is isolated
        color = '#4CAF50' if consistent else '#FF5722'
        ax.add_patch(plt.Circle((x, y), 0.18, color=color, zorder=3))
        ax.text(x, y, str(i), ha='center', va='center', fontsize=12,
                fontweight='bold', color='white', zorder=4)

    # Labels
    ax.text(n * 0.75, -0.8, "World i accesses world j iff i < j",
            ha='center', fontsize=10, style='italic')

    ax.set_xlim(-0.5, n * 1.5 + 0.5)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')


def draw_k_soundness_heatmap(ax, n=5):
    """Draw a heatmap of k-soundness levels."""
    ax.set_title("k-Soundness Levels", fontsize=14, fontweight='bold')

    # In the canonical frame, world i is sound for formulas whose
    # soundness doesn't require looking beyond the frame.
    # World n (isolated) is NOT sound for anything (vacuous box forces ⊥).
    # Other worlds are sound up to depth related to their position.

    max_k = n
    data = np.zeros((max_k + 1, n + 1))

    for world in range(n + 1):
        for k in range(max_k + 1):
            # Approximate: world i is roughly (n-i)-sound
            if world == n:
                # Isolated world: not sound (vacuous box)
                data[k][world] = 0
            elif k <= n - world - 1:
                data[k][world] = 1
            else:
                data[k][world] = 0.3  # uncertain

    im = ax.imshow(data, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1)
    ax.set_xlabel("World", fontsize=11)
    ax.set_ylabel("k (soundness level)", fontsize=11)
    ax.set_xticks(range(n + 1))
    ax.set_yticks(range(max_k + 1))

    # Add text annotations
    for k in range(max_k + 1):
        for w in range(n + 1):
            val = data[k][w]
            text = "✓" if val > 0.8 else ("?" if val > 0.2 else "✗")
            ax.text(w, k, text, ha='center', va='center', fontsize=10,
                    color='black' if val > 0.5 else 'white')


def draw_tangling_gap(ax):
    """Draw the tangling gap visualization."""
    ax.set_title("The Tangling Gap", fontsize=14, fontweight='bold')

    levels = range(8)
    external = [1] * 8  # External soundness at all levels
    internal = [1 if k < 5 else 0 for k in levels]  # Internal proof up to some level

    ax.bar([x - 0.15 for x in levels], external, 0.3, label='Externally Sound',
           color='#4CAF50', alpha=0.8)
    ax.bar([x + 0.15 for x in levels], internal, 0.3, label='Can Prove Soundness',
           color='#2196F3', alpha=0.8)

    ax.set_xlabel("Soundness Level k", fontsize=11)
    ax.set_ylabel("Holds?", fontsize=11)
    ax.set_xticks(list(levels))
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['No', 'Yes'])
    ax.legend(loc='upper right', fontsize=9)

    # Arrow showing the gap
    ax.annotate('Tangling\nGap', xy=(5, 0.5), fontsize=11, ha='center',
                color='red', fontweight='bold')


def draw_hierarchy(ax):
    """Draw the reflective hierarchy."""
    ax.set_title("Reflective Hierarchy", fontsize=14, fontweight='bold')

    n = 6
    for i in range(n):
        y = n - 1 - i
        level = n - 1 - i
        color = plt.cm.viridis(level / (n - 1))

        # Draw world
        circle = plt.Circle((2, y * 0.8), 0.25, color=color, zorder=3)
        ax.add_patch(circle)
        ax.text(2, y * 0.8, f"w_{i}", ha='center', va='center',
                fontsize=10, color='white', fontweight='bold', zorder=4)

        # Label with soundness level
        ax.text(3.5, y * 0.8, f"{level}-sound", ha='left', va='center',
                fontsize=10)

        # Arrow to next
        if i < n - 1:
            ax.annotate('', xy=(2, (y - 1) * 0.8 + 0.25),
                       xytext=(2, y * 0.8 - 0.25),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.text(2, -1.2, "Each level certifies the one below",
            ha='center', fontsize=10, style='italic')
    ax.text(2, -1.6, "No level certifies itself",
            ha='center', fontsize=10, style='italic', color='red')

    ax.set_xlim(0, 5)
    ax.set_ylim(-2, (n - 1) * 0.8 + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Tangled Hierarchies: Self-Referential Proof Systems",
                 fontsize=16, fontweight='bold', y=0.98)

    draw_canonical_frame(axes[0, 0])
    draw_k_soundness_heatmap(axes[0, 1])
    draw_tangling_gap(axes[1, 0])
    draw_hierarchy(axes[1, 1])

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig("tangling_hierarchy.png", dpi=150, bbox_inches='tight')
    plt.savefig("tangling_hierarchy.pdf", bbox_inches='tight')
    print("Saved: tangling_hierarchy.png, tangling_hierarchy.pdf")


if __name__ == "__main__":
    main()
