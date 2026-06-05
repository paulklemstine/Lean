#!/usr/bin/env python3
"""
Demo: Tangled Hierarchies in Self-Referential Proof Systems

Demonstrates the key mathematical structures using concrete examples:
1. GL frames and Kripke semantics
2. Löb's theorem and the incompleteness cascade
3. The tangling depth hierarchy
4. The incompleteness-soundness trade-off
"""

from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass


@dataclass
class GLFrame:
    """A GL frame: worlds with a transitive, converse well-founded accessibility relation."""
    worlds: List[str]
    edges: List[Tuple[str, str]]  # (w, v) means wRv

    def successors(self, w: str) -> Set[str]:
        return {v for (u, v) in self.edges if u == w}

    def is_transitive(self) -> bool:
        for (u, v) in self.edges:
            for (v2, w) in self.edges:
                if v == v2 and (u, w) not in self.edges:
                    return False
        return True

    def is_irreflexive(self) -> bool:
        return all(u != v for (u, v) in self.edges)

    def depth(self, w: str, visited: Optional[Set[str]] = None) -> int:
        """Compute tangling depth of a world."""
        if visited is None:
            visited = set()
        if w in visited:
            return 0  # Should not happen in a valid GL frame
        visited.add(w)
        succs = self.successors(w)
        if not succs:
            return 0
        return 1 + max(self.depth(v, visited.copy()) for v in succs)


def demo_gl_frame():
    """Demonstrate a concrete GL frame and its properties."""
    print("=" * 60)
    print("DEMO 1: GL Frame Structure")
    print("=" * 60)

    # A simple GL frame: w0 -> w1 -> w2, with transitive closure
    frame = GLFrame(
        worlds=["w0", "w1", "w2"],
        edges=[("w0", "w1"), ("w0", "w2"), ("w1", "w2")]
    )

    print(f"Worlds: {frame.worlds}")
    print(f"Edges: {frame.edges}")
    print(f"Transitive: {frame.is_transitive()}")
    print(f"Irreflexive: {frame.is_irreflexive()}")

    for w in frame.worlds:
        d = frame.depth(w)
        succs = frame.successors(w)
        print(f"  depth({w}) = {d}, successors = {succs}")

    print()
    print("Key insight: depth strictly decreases along edges.")
    print(f"  w0 -> w1: depth {frame.depth('w0')} > {frame.depth('w1')}")
    print(f"  w1 -> w2: depth {frame.depth('w1')} > {frame.depth('w2')}")
    print()


def demo_loeb_theorem():
    """Demonstrate Löb's theorem with a concrete evaluation."""
    print("=" * 60)
    print("DEMO 2: Löb's Theorem and Gödel's Second Incompleteness")
    print("=" * 60)

    # In our GL frame, define a valuation and check forcing
    frame = GLFrame(
        worlds=["std", "w1", "w2"],
        edges=[("std", "w1"), ("std", "w2"), ("w1", "w2")]
    )

    # Check: does 'std' force □⊥?
    # □⊥ at std means: for all v with std R v, v forces ⊥
    # This is False (w1 does not force ⊥)
    print("Frame: std -> w1 -> w2, std -> w2")
    print()
    print("Does 'std' force □⊥? NO")
    print("  Because w1 is accessible from std, but w1 does not force ⊥.")
    print()

    # Check: does 'std' force □⊥ → ⊥?
    # This means: if std forces □⊥, then std forces ⊥
    # Since std does NOT force □⊥, this is vacuously true
    print("Does 'std' force □⊥ → ⊥ (= consistency)? YES (vacuously)")
    print("  std does not force □⊥, so the implication holds.")
    print()

    # Check: does 'std' force □(□⊥ → ⊥)?
    # This means: for all v with std R v, v forces □⊥ → ⊥
    # v = w1: does w1 force □⊥ → ⊥?
    #   w1 forces □⊥ iff all successors of w1 force ⊥
    #   w2 is the only successor, and w2 has no successors → w2 forces □⊥ (vacuously!)
    #   So w1 forces □⊥. Does w1 force ⊥? NO.
    #   So w1 does NOT force □⊥ → ⊥.
    print("Does 'std' force □(□⊥ → ⊥) (= provability of consistency)? NO")
    print("  w1 forces □⊥ (vacuously, via w2), but w1 does NOT force ⊥.")
    print("  So w1 does not force □⊥ → ⊥, and std cannot prove consistency.")
    print()
    print("This is Gödel's Second Incompleteness Theorem!")
    print("The system (std) is consistent but cannot prove its own consistency.")
    print()

    # Dead-end analysis
    print("Dead-end paradox: w2 has no successors.")
    print("  w2 forces □φ for ALL φ (vacuously)!")
    print("  In particular, w2 forces □⊥.")
    print("  If w2 were 'sound' (□⊥ → ⊥), then w2 would force ⊥.")
    print("  So dead-end worlds CANNOT be both sound and consistent.")
    print()


def demo_tangling_hierarchy():
    """Demonstrate the tangling hierarchy with increasing depth."""
    print("=" * 60)
    print("DEMO 3: The Tangling Hierarchy")
    print("=" * 60)

    # Build a deeper frame
    n = 5
    worlds = [f"w{i}" for i in range(n)]
    edges = [(f"w{i}", f"w{j}") for i in range(n) for j in range(i+1, n)]
    frame = GLFrame(worlds=worlds, edges=edges)

    print(f"Frame with {n} worlds: w0 -> w1 -> ... -> w{n-1}")
    print(f"(Transitively closed)")
    print()

    for w in worlds:
        d = frame.depth(w)
        succs = frame.successors(w)
        print(f"  {w}: depth = {d}, successors = {succs}")

    print()
    print("The tangling hierarchy:")
    print("  Level 0 (w4): Dead end. Vacuously proves everything.")
    print("  Level 1 (w3): Can reason about level 0. Cannot prove Con_0.")
    print("  Level 2 (w2): Can reason about levels 0-1. Cannot prove Con_1.")
    print("  ...")
    print(f"  Level {n-1} (w0): Can reason about all lower levels.")
    print()
    print("At each level, the system cannot prove the consistency")
    print("of the level below — creating an unavoidable 'tangle'.")
    print()


def demo_soundness_tradeoff():
    """Demonstrate the incompleteness-soundness trade-off."""
    print("=" * 60)
    print("DEMO 4: The Incompleteness-Soundness Trade-off")
    print("=" * 60)

    print("In a provability lattice with a Gödel element g:")
    print("  g ⊓ □g = ⊥  (g and '□g' are contradictory)")
    print("  g ⊔ □g = ⊤  (either g or □g holds)")
    print()
    print("Theorem: Extensiveness (a ≤ □a) and soundness (□a ≤ a)")
    print("         CANNOT BOTH HOLD in a nontrivial lattice.")
    print()
    print("Proof sketch:")
    print("  1. If both hold, then □a = a for all a (□ is the identity).")
    print("  2. Then g ⊓ g = g = ⊥ (from self_refuting with □g = g).")
    print("  3. And g ⊔ g = g = ⊤ (from self_affirming with □g = g).")
    print("  4. So ⊥ = ⊤, contradicting nontriviality.")
    print()
    print("This means every nontrivial proof system must sacrifice either:")
    print("  - Soundness: some provable statements are false, OR")
    print("  - Completeness: some true statements are unprovable.")
    print()
    print("This is the deep structural reason why tangled hierarchies")
    print("are UNAVOIDABLE in self-referential systems.")
    print()


if __name__ == "__main__":
    demo_gl_frame()
    demo_loeb_theorem()
    demo_tangling_hierarchy()
    demo_soundness_tradeoff()


#!/usr/bin/env python3
"""
Visualization: Tangled Hierarchy Depth in GL Frames

Produces a visualization of a GL frame showing:
- World nodes colored by tangling depth
- Accessibility edges
- Annotations showing which consistency levels hold
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, List, Set, Tuple


def compute_depth(worlds: List[str], edges: Set[Tuple[str, str]]) -> Dict[str, int]:
    """Compute tangling depth for each world."""
    successors = {w: set() for w in worlds}
    for (u, v) in edges:
        successors[u].add(v)

    depths: Dict[str, int] = {}
    remaining = set(worlds)

    while remaining:
        leaves = {w for w in remaining
                  if not successors[w].intersection(remaining)}
        if not leaves:
            break
        for w in leaves:
            if not successors[w]:
                depths[w] = 0
            else:
                depths[w] = 1 + max(depths.get(v, 0) for v in successors[w])
        remaining -= leaves

    return depths


def plot_gl_frame(
    worlds: List[str],
    edges: Set[Tuple[str, str]],
    title: str = "GL Frame: Tangled Hierarchy",
    filename: str = "tangled_hierarchy.png"
):
    """Plot a GL frame with depth coloring."""
    depths = compute_depth(worlds, edges)
    max_depth = max(depths.values()) if depths else 0

    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Layout: arrange worlds by depth (higher depth = higher y)
    n = len(worlds)
    positions = {}
    depth_groups: Dict[int, List[str]] = {}
    for w in worlds:
        d = depths.get(w, 0)
        if d not in depth_groups:
            depth_groups[d] = []
        depth_groups[d].append(w)

    for d, group in depth_groups.items():
        for i, w in enumerate(group):
            x = (i + 0.5) / len(group)
            y = d / (max_depth + 1) * 0.8 + 0.1
            positions[w] = (x, y)

    # Draw edges
    for (u, v) in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        ax.annotate("",
                     xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="->", color="gray",
                                     alpha=0.6, lw=1.5))

    # Draw nodes
    cmap = plt.cm.RdYlGn
    for w in worlds:
        x, y = positions[w]
        d = depths.get(w, 0)
        color = cmap(d / (max_depth + 0.5)) if max_depth > 0 else cmap(0.5)

        circle = plt.Circle((x, y), 0.04, color=color, ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, w, ha='center', va='center', fontsize=9,
                fontweight='bold', zorder=6)

        # Annotate with depth
        ax.text(x, y - 0.06, f"depth={d}", ha='center', va='top',
                fontsize=7, color='gray')

    # Labels
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.axis('off')

    # Add legend
    for d in sorted(depth_groups.keys()):
        color = cmap(d / (max_depth + 0.5)) if max_depth > 0 else cmap(0.5)
        ax.plot([], [], 'o', color=color, markersize=10,
                label=f"Depth {d}")
    ax.legend(loc='upper right', fontsize=9)

    # Add explanatory text
    textstr = (
        "Tangling Hierarchy:\n"
        "• Depth 0: Dead end (vacuously proves □⊥)\n"
        "• Depth n: Can reason about depth < n\n"
        "• Each level cannot prove its\n"
        "  own consistency (Gödel II)"
    )
    props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
    ax.text(0.02, 0.98, textstr, transform=ax.transAxes, fontsize=8,
            verticalalignment='top', bbox=props)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


def plot_soundness_tradeoff(filename: str = "soundness_tradeoff.png"):
    """Plot the incompleteness-soundness trade-off."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Create a 2D plot: x = extensiveness, y = soundness
    # The diagonal line represents □ = id
    x = np.linspace(0, 1, 100)

    # Shade the impossible region
    ax.fill_between(x, x, 1, alpha=0.15, color='red',
                     label='Impossible (with Gödel element)')
    ax.fill_between(x, 0, x, alpha=0.1, color='green',
                     label='Possible region')

    # Plot the diagonal
    ax.plot(x, x, 'r--', lw=2, label='□ = id (collapse)')

    # Mark key points
    ax.plot(0.8, 0.3, 'bo', markersize=15, zorder=5)
    ax.annotate('PA\n(sound, incomplete)', (0.8, 0.3),
                textcoords="offset points", xytext=(15, -15),
                fontsize=10, ha='left')

    ax.plot(0.3, 0.9, 'gs', markersize=15, zorder=5)
    ax.annotate('Complete theory\n(unsound)', (0.3, 0.9),
                textcoords="offset points", xytext=(15, 10),
                fontsize=10, ha='left')

    ax.plot(0.5, 0.5, 'r*', markersize=20, zorder=5)
    ax.annotate('Trivial\n(⊥ = ⊤)', (0.5, 0.5),
                textcoords="offset points", xytext=(15, -15),
                fontsize=10, ha='left', color='red')

    ax.set_xlabel('Extensiveness (a ≤ □a)', fontsize=12)
    ax.set_ylabel('Soundness (□a ≤ a)', fontsize=12)
    ax.set_title('The Incompleteness-Soundness Trade-off\n'
                 '(with Gödel element in a nontrivial lattice)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='lower right')
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


if __name__ == "__main__":
    # Demo 1: Small GL frame
    worlds = ["w0", "w1", "w2", "w3"]
    edges = {("w0", "w1"), ("w0", "w2"), ("w0", "w3"),
             ("w1", "w2"), ("w1", "w3"), ("w2", "w3")}
    plot_gl_frame(worlds, edges, "GL Frame: 4-World Tangled Hierarchy")

    # Demo 2: Larger frame
    n = 6
    worlds_large = [f"w{i}" for i in range(n)]
    edges_large = {(f"w{i}", f"w{j}") for i in range(n) for j in range(i+1, n)}
    plot_gl_frame(worlds_large, edges_large,
                  f"GL Frame: {n}-World Complete Hierarchy",
                  "tangled_hierarchy_large.png")

    # Demo 3: Soundness trade-off
    plot_soundness_tradeoff()
