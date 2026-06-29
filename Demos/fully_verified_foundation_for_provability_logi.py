#!/usr/bin/env python3
"""
Provability Logic GL — Demonstration

Demonstrates the Tangling Dichotomy and related results
by constructing concrete GL frames and computing:
- Tangling depth at each world
- Soundness status
- Forced reflection levels
- The tangling dichotomy in action
"""

from typing import Dict, List, Set, Tuple


def is_gl_frame(worlds: List[str], edges: List[Tuple[str, str]]) -> Tuple[bool, str]:
    """Check if (worlds, edges) forms a valid GL frame."""
    adj: Dict[str, Set[str]] = {w: set() for w in worlds}
    for u, v in edges:
        adj[u].add(v)

    # Check transitivity
    for w in worlds:
        for v in adj[w]:
            for u in adj[v]:
                if u not in adj[w]:
                    return False, f"Not transitive: R({w},{v}) and R({v},{u}) but not R({w},{u})"

    # Check irreflexivity (necessary for converse well-foundedness)
    for w in worlds:
        if w in adj[w]:
            return False, f"Not irreflexive: R({w},{w})"

    # Check acyclicity (equivalent to converse well-foundedness for finite frames)
    visited: Set[str] = set()
    in_stack: Set[str] = set()

    def has_cycle(w: str) -> bool:
        visited.add(w)
        in_stack.add(w)
        for v in adj[w]:
            if v in in_stack:
                return True
            if v not in visited and has_cycle(v):
                return True
        in_stack.discard(w)
        return False

    for w in worlds:
        if w not in visited:
            if has_cycle(w):
                return False, "Contains a cycle (violates converse well-foundedness)"

    return True, "Valid GL frame"


def compute_tangling_depth(worlds: List[str], edges: List[Tuple[str, str]]) -> Dict[str, int]:
    """Compute the tangling depth of each world (longest R-chain from w)."""
    adj: Dict[str, Set[str]] = {w: set() for w in worlds}
    for u, v in edges:
        adj[u].add(v)

    memo: Dict[str, int] = {}

    def depth(w: str) -> int:
        if w in memo:
            return memo[w]
        if not adj[w]:
            memo[w] = 0
        else:
            memo[w] = 1 + max(depth(v) for v in adj[w])
        return memo[w]

    for w in worlds:
        depth(w)
    return memo


def demonstrate_tangling_dichotomy(
    name: str,
    worlds: List[str],
    edges: List[Tuple[str, str]],
    sound_worlds: List[str],
) -> None:
    """Demonstrate the tangling dichotomy on a specific frame."""
    print(f"\n{'='*60}")
    print(f"Frame: {name}")
    print(f"{'='*60}")

    valid, msg = is_gl_frame(worlds, edges)
    print(f"GL Frame check: {msg}")
    if not valid:
        return

    adj: Dict[str, Set[str]] = {w: set() for w in worlds}
    for u, v in edges:
        adj[u].add(v)

    depths = compute_tangling_depth(worlds, edges)

    print(f"\nWorlds: {worlds}")
    print(f"Edges: {edges}")
    print(f"Tangling depths: {depths}")

    print(f"\n--- Tangling Dichotomy Analysis ---")
    for w in sound_worlds:
        successors = adj[w]
        has_no_succ = len(successors) == 0
        # A sound world with successors cannot internalize soundness
        if has_no_succ:
            print(f"  {w}: SOUND, no successors → Fate 1 (Isolation)")
            print(f"       Trivial provability: □φ holds vacuously for all φ")
        else:
            print(f"  {w}: SOUND, successors = {successors} → Fate 2 (Blindness)")
            print(f"       Cannot internalize soundness (¬□(□⊥→⊥))")
            print(f"       Tangling depth = {depths[w]}")

    # Check soundness heritability
    print(f"\n--- Soundness Heritability Check ---")
    for w in sound_worlds:
        for v in adj[w]:
            if v in sound_worlds:
                print(f"  WARNING: {w}→{v}, both marked sound!")
                print(f"  This contradicts soundness_not_hereditary")
                print(f"  (unless {w} has no successors)")
            else:
                print(f"  {w}→{v}: successor {v} is NOT sound ✓")
                print(f"  (consistent with soundness decay)")


# Example 1: Simple 3-world chain
demonstrate_tangling_dichotomy(
    "Linear Chain (3 worlds)",
    worlds=["w0", "w1", "w2"],
    edges=[("w0", "w1"), ("w0", "w2"), ("w1", "w2")],
    sound_worlds=["w0"],
)

# Example 2: Binary tree structure
demonstrate_tangling_dichotomy(
    "Binary Tree (depth 2)",
    worlds=["root", "L", "R", "LL", "LR", "RL", "RR"],
    edges=[
        ("root", "L"), ("root", "R"),
        ("root", "LL"), ("root", "LR"), ("root", "RL"), ("root", "RR"),
        ("L", "LL"), ("L", "LR"),
        ("R", "RL"), ("R", "RR"),
    ],
    sound_worlds=["root"],
)

# Example 3: Diamond frame
demonstrate_tangling_dichotomy(
    "Diamond Frame",
    worlds=["top", "left", "right", "bottom"],
    edges=[
        ("top", "left"), ("top", "right"), ("top", "bottom"),
        ("left", "bottom"), ("right", "bottom"),
    ],
    sound_worlds=["top"],
)

# Example 4: Isolated world (trivial provability)
demonstrate_tangling_dichotomy(
    "Isolated World",
    worlds=["alone"],
    edges=[],
    sound_worlds=["alone"],
)

# Reflection hierarchy demonstration
print(f"\n{'='*60}")
print("Reflection Hierarchy Demonstration")
print(f"{'='*60}")

worlds = [f"w{i}" for i in range(6)]
edges = [(f"w{i}", f"w{j}") for i in range(6) for j in range(i+1, 6)]
depths = compute_tangling_depth(worlds, edges)

print(f"Chain of 6 worlds: w0 → w1 → ... → w5")
print(f"Tangling depths: {depths}")
print(f"\nReflection levels forced at each world:")
for w in worlds:
    d = depths[w]
    if d == 0:
        print(f"  {w} (depth {d}): Forces □φ vacuously (no successors)")
        print(f"       Forces ALL reflection levels trivially")
    else:
        print(f"  {w} (depth {d}): Forces reflection levels 0..{d-1}")
        print(f"       Cannot force level {d} (would require deeper frame)")

# Demonstrate computational complexity
print(f"\n{'='*60}")
print("Tangling Depth Computation Complexity")
print(f"{'='*60}")

for n in [10, 50, 100, 500]:
    worlds_n = list(range(n))
    edges_n = [(i, j) for i in range(n) for j in range(i+1, n)]
    adj_n: Dict[int, Set[int]] = {w: set() for w in worlds_n}
    for u, v in edges_n:
        adj_n[u].add(v)

    memo_n: Dict[int, int] = {}
    def depth_n(w: int) -> int:
        if w in memo_n:
            return memo_n[w]
        if not adj_n[w]:
            memo_n[w] = 0
        else:
            memo_n[w] = 1 + max(depth_n(v) for v in adj_n[w])
        return memo_n[w]

    for w in worlds_n:
        depth_n(w)

    max_depth = max(memo_n.values())
    print(f"  n={n:4d} worlds, complete DAG: max tangling depth = {max_depth}")


#!/usr/bin/env python3
"""
Visualization: GL Frame with Tangling Depth

Creates a visualization of a GL frame showing:
- Worlds as nodes colored by tangling depth
- Accessibility relation as directed edges
- Sound worlds highlighted
- The tangling dichotomy classification
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, List, Set, Tuple


def compute_tangling_depth_viz(
    worlds: List[str], edges: List[Tuple[str, str]]
) -> Dict[str, int]:
    adj: Dict[str, Set[str]] = {w: set() for w in worlds}
    for u, v in edges:
        adj[u].add(v)
    memo: Dict[str, int] = {}
    def depth(w: str) -> int:
        if w in memo:
            return memo[w]
        if not adj[w]:
            memo[w] = 0
        else:
            memo[w] = 1 + max(depth(v) for v in adj[w])
        return memo[w]
    for w in worlds:
        depth(w)
    return memo


def layout_by_depth(
    worlds: List[str], depths: Dict[str, int]
) -> Dict[str, Tuple[float, float]]:
    max_d = max(depths.values()) if depths else 0
    levels: Dict[int, List[str]] = {}
    for w in worlds:
        d = depths[w]
        levels.setdefault(d, []).append(w)
    positions: Dict[str, Tuple[float, float]] = {}
    for d, ws in levels.items():
        y = max_d - d
        n = len(ws)
        for i, w in enumerate(ws):
            x = (i - (n - 1) / 2) * 2
            positions[w] = (x, y * 2)
    return positions


def visualize_gl_frame(
    worlds: List[str],
    edges: List[Tuple[str, str]],
    sound_worlds: Set[str],
    title: str = "GL Frame with Tangling Depth",
    filename: str = "gl_frame.png",
) -> None:
    depths = compute_tangling_depth_viz(worlds, edges)
    positions = layout_by_depth(worlds, depths)
    max_depth = max(depths.values()) if depths else 0

    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Color map: depth 0 = light, max depth = dark
    cmap = plt.cm.YlOrRd

    # Draw edges
    adj: Dict[str, Set[str]] = {w: set() for w in worlds}
    for u, v in edges:
        adj[u].add(v)

    # Only draw direct edges (not transitive closure)
    direct_edges: List[Tuple[str, str]] = []
    for u, v in edges:
        is_direct = True
        for mid in adj[u]:
            if mid != v and v in adj.get(mid, set()):
                is_direct = False
                break
        if is_direct:
            direct_edges.append((u, v))

    for u, v in direct_edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        dx, dy = x2 - x1, y2 - y1
        ax.annotate(
            "", xy=(x2, y2), xytext=(x1, y1),
            arrowprops=dict(
                arrowstyle="-|>",
                color="gray",
                lw=1.5,
                connectionstyle="arc3,rad=0.1",
            ),
        )

    # Draw nodes
    for w in worlds:
        x, y = positions[w]
        d = depths[w]
        color_val = d / max(max_depth, 1)
        color = cmap(color_val)

        is_sound = w in sound_worlds
        edge_color = "blue" if is_sound else "black"
        edge_width = 3 if is_sound else 1.5

        circle = plt.Circle(
            (x, y), 0.4, color=color, ec=edge_color, lw=edge_width, zorder=5
        )
        ax.add_patch(circle)

        # Label
        fate = ""
        if is_sound:
            if not adj[w]:
                fate = "\n(Isolated)"
            else:
                fate = "\n(Blind)"

        ax.text(
            x, y, f"{w}\nd={d}{fate}",
            ha="center", va="center", fontsize=8, fontweight="bold", zorder=6,
        )

    # Legend
    patches = [
        mpatches.Patch(facecolor=cmap(0.0), edgecolor="black", label="Depth 0 (leaf)"),
        mpatches.Patch(facecolor=cmap(0.5), edgecolor="black", label=f"Depth {max_depth//2}"),
        mpatches.Patch(facecolor=cmap(1.0), edgecolor="black", label=f"Depth {max_depth} (root)"),
        mpatches.Patch(facecolor="white", edgecolor="blue", linewidth=2, label="Sound world"),
    ]
    ax.legend(handles=patches, loc="upper right", fontsize=9)

    ax.set_title(title, fontsize=14, fontweight="bold")
    ax.set_xlim(
        min(x for x, y in positions.values()) - 1,
        max(x for x, y in positions.values()) + 1,
    )
    ax.set_ylim(
        min(y for x, y in positions.values()) - 1,
        max(y for x, y in positions.values()) + 1,
    )
    ax.set_aspect("equal")
    ax.axis("off")

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"Saved: {filename}")


# Frame 1: 5-world chain
worlds1 = ["w0", "w1", "w2", "w3", "w4"]
edges1 = [(f"w{i}", f"w{j}") for i in range(5) for j in range(i+1, 5)]
visualize_gl_frame(worlds1, edges1, {"w0"}, "Linear Chain GL Frame", "gl_frame_chain.png")

# Frame 2: Diamond
worlds2 = ["top", "left", "right", "bottom"]
edges2 = [
    ("top", "left"), ("top", "right"), ("top", "bottom"),
    ("left", "bottom"), ("right", "bottom"),
]
visualize_gl_frame(worlds2, edges2, {"top"}, "Diamond GL Frame", "gl_frame_diamond.png")

# Frame 3: Wide tree
worlds3 = ["root", "a", "b", "c", "a1", "a2", "b1", "c1", "c2", "c3"]
edges3 = [
    ("root", "a"), ("root", "b"), ("root", "c"),
    ("a", "a1"), ("a", "a2"),
    ("b", "b1"),
    ("c", "c1"), ("c", "c2"), ("c", "c3"),
    # Transitive closure
    ("root", "a1"), ("root", "a2"), ("root", "b1"),
    ("root", "c1"), ("root", "c2"), ("root", "c3"),
]
visualize_gl_frame(worlds3, edges3, {"root"}, "Tree GL Frame", "gl_frame_tree.png")


#!/usr/bin/env python3
"""
Visualization: The Reflection Hierarchy

Shows the infinite tower of reflection principles and how each level
implies the one below, creating the tangled hierarchy structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_reflection_hierarchy(max_level: int = 8, filename: str = "reflection_hierarchy.png"):
    """Draw the reflection hierarchy as a tower of levels."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 10))

    # Left panel: The reflection tower
    ax = ax1
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, max_level + 1))

    for i in range(max_level + 1):
        y = i * 1.2
        width = 4
        height = 0.8

        rect = mpatches.FancyBboxPatch(
            (-width/2, y), width, height,
            boxstyle="round,pad=0.1",
            facecolor=colors[i],
            edgecolor="black",
            linewidth=1.5,
        )
        ax.add_patch(rect)

        if i == 0:
            label = "φ"
        elif i == 1:
            label = "□φ → φ"
        elif i == 2:
            label = "□(□φ→φ) → (□φ→φ)"
        elif i <= 4:
            label = f"Rf_{i}(φ)"
        else:
            label = f"Rf_{i}(φ)"

        ax.text(0, y + height/2, label, ha="center", va="center",
                fontsize=10 if i <= 2 else 9, fontweight="bold", color="white")

        # Arrow from level i+1 to level i
        if i > 0:
            ax.annotate(
                "", xy=(width/2 + 0.3, y + height/2),
                xytext=(width/2 + 0.3, y - 0.4 + height/2),
                arrowprops=dict(arrowstyle="-|>", color="red", lw=2),
            )
            ax.text(width/2 + 0.7, y + 0.1, "Löb", fontsize=7, color="red",
                    ha="left", va="center")

    # Dots at top
    ax.text(0, (max_level + 1) * 1.2, "⋮", ha="center", va="center", fontsize=20)

    ax.set_xlim(-3.5, 4.5)
    ax.set_ylim(-0.5, (max_level + 2) * 1.2)
    ax.set_title("Reflection Hierarchy\n(Each level implies all below via Löb)",
                 fontsize=13, fontweight="bold")
    ax.axis("off")

    # Right panel: Tangling depth vs reflection levels
    ax = ax2
    n_worlds = 6
    x = np.arange(n_worlds)
    depths = list(range(n_worlds - 1, -1, -1))

    bars = ax.bar(x, depths, color=[colors[d] for d in depths],
                  edgecolor="black", linewidth=1.5)

    ax.set_xlabel("World", fontsize=12)
    ax.set_ylabel("Tangling Depth = Reflection Levels Forced", fontsize=12)
    ax.set_title("Tangling Depth in a 6-World Chain\n(Deeper worlds force more reflection levels)",
                 fontsize=13, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels([f"w{i}" for i in range(n_worlds)], fontsize=10)

    for i, d in enumerate(depths):
        classification = "Sound\n(Blind)" if i == 0 else ("Unsound" if d > 0 else "Leaf\n(Isolated)")
        ax.text(i, d + 0.1, f"d={d}\n{classification}",
                ha="center", va="bottom", fontsize=8, fontweight="bold")

    ax.set_ylim(0, max(depths) + 2)
    ax.grid(axis="y", alpha=0.3)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"Saved: {filename}")


def draw_soundness_decay(filename: str = "soundness_decay.png"):
    """Visualize how soundness decays along accessibility chains."""
    fig, ax = plt.subplots(figsize=(14, 6))

    chain_length = 8
    x = np.arange(chain_length)

    # Soundness "probability" decays (illustrative)
    soundness = [1.0]  # Root is sound
    for i in range(1, chain_length):
        soundness.append(0)  # No successor of a sound world can be sound

    colors = ["#2196F3" if s > 0 else "#F44336" for s in soundness]

    bars = ax.bar(x, [1]*chain_length, color=colors, edgecolor="black", linewidth=1.5,
                  alpha=0.7)

    # Draw arrows
    for i in range(chain_length - 1):
        ax.annotate(
            "", xy=(i + 0.9, 0.5), xytext=(i + 0.1, 0.5),
            arrowprops=dict(arrowstyle="-|>", color="gray", lw=2),
        )

    # Labels
    for i in range(chain_length):
        label = "SOUND" if soundness[i] > 0 else "UNSOUND"
        color = "white"
        ax.text(i, 0.5, f"w{i}\n{label}", ha="center", va="center",
                fontsize=9, fontweight="bold", color=color)

    ax.set_title("Soundness Cascade: Sound World Forces Unsound Successors",
                 fontsize=14, fontweight="bold")
    ax.set_xlabel("Worlds along R-chain", fontsize=12)
    ax.set_ylabel("")
    ax.set_ylim(0, 1.3)
    ax.set_yticks([])

    # Legend
    patches = [
        mpatches.Patch(color="#2196F3", alpha=0.7, label="Sound (□φ→φ for all φ)"),
        mpatches.Patch(color="#F44336", alpha=0.7, label="Unsound (∃φ: □φ ∧ ¬φ)"),
    ]
    ax.legend(handles=patches, loc="upper right", fontsize=10)

    # Annotation
    ax.annotate(
        "Theorem: If w₀ is sound and has successors,\n"
        "then ∃ unsound successor\n"
        "(soundness_not_hereditary)",
        xy=(1, 0.9), xytext=(3, 1.15),
        fontsize=10, fontstyle="italic",
        arrowprops=dict(arrowstyle="->", color="black"),
        bbox=dict(boxstyle="round,pad=0.3", facecolor="lightyellow"),
    )

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"Saved: {filename}")


draw_reflection_hierarchy()
draw_soundness_decay()
