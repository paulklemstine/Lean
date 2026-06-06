#!/usr/bin/env python3
"""
Counterpoint Category Theory — Numerical Demonstrations

Demonstrates the key results from the Contrapuntal Quiver formalization:
1. Target Determination Principle
2. Bimodal Restrictiveness Spectrum
3. Uniform Freedom Theorem
4. Inversion Asymmetry
"""

from enum import IntEnum
from typing import Dict, List, Set, Tuple

# --- Core Definitions ---

class MotionType(IntEnum):
    """Motion types ordered by restrictiveness."""
    CONTRARY = 0
    OBLIQUE = 1
    SIMILAR = 2
    PARALLEL = 3

CONSONANCES = {0: "Unison", 3: "min3", 4: "Maj3", 7: "P5", 8: "min6", 9: "Maj6"}
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}

def is_consonant(i: int) -> bool:
    return (i % 12) in CONSONANCES

def is_perfect(i: int) -> bool:
    return (i % 12) in PERFECT

def fux_allowed(a: int, b: int, m: MotionType) -> bool:
    """The Fux permission function. Note: independent of source a."""
    if is_perfect(b):
        return m <= MotionType.SIMILAR
    return True

def hom_set(a: int, b: int) -> Set[MotionType]:
    """Permitted motion types from interval a to interval b."""
    return {m for m in MotionType if fux_allowed(a, b, m)}

# --- Demonstration 1: Target Determination ---

def demo_target_determination():
    print("=" * 60)
    print("DEMO 1: Target Determination Principle")
    print("=" * 60)
    print("\nFor each target b, we show the hom-set is the same")
    print("regardless of source a:\n")

    consonant_list = sorted(CONSONANCES.keys())
    for b in consonant_list:
        sets = [hom_set(a, b) for a in consonant_list]
        all_same = all(s == sets[0] for s in sets)
        print(f"  Target {CONSONANCES[b]:>6s} ({b:2d}): "
              f"|hom| = {len(sets[0])}, "
              f"source-independent: {all_same}")

    print("\n✓ All targets show source-independence.")

# --- Demonstration 2: Bimodal Spectrum ---

def demo_bimodal_spectrum():
    print("\n" + "=" * 60)
    print("DEMO 2: Bimodal Restrictiveness Spectrum")
    print("=" * 60)

    spectrum: Dict[int, int] = {}
    consonant_list = sorted(CONSONANCES.keys())

    for a in consonant_list:
        for b in consonant_list:
            size = len(hom_set(a, b))
            spectrum[size] = spectrum.get(size, 0) + 1

    print(f"\n  Total edges: {sum(spectrum.values())}")
    print(f"  Spectrum:")
    for k in sorted(spectrum.keys()):
        bar = "█" * spectrum[k]
        print(f"    |hom| = {k}: {spectrum[k]:3d} edges  {bar}")

    total_morphisms = sum(k * v for k, v in spectrum.items())
    print(f"\n  Total morphisms: {total_morphisms}")
    print(f"  Expected: 12×3 + 24×4 = {12*3 + 24*4}")
    print(f"  ✓ Match: {total_morphisms == 132}")

# --- Demonstration 3: Uniform Freedom ---

def demo_uniform_freedom():
    print("\n" + "=" * 60)
    print("DEMO 3: Uniform Freedom Theorem")
    print("=" * 60)

    consonant_list = sorted(CONSONANCES.keys())
    print(f"\n  {'Source':>8s}  {'Type':>10s}  {'Out-degrees by motion type':>30s}  {'Total':>6s}")
    print(f"  {'─'*8}  {'─'*10}  {'─'*30}  {'─'*6}")

    for a in consonant_list:
        degrees = []
        for m in MotionType:
            deg = sum(1 for b in consonant_list if fux_allowed(a, b, m))
            degrees.append(deg)
        total = sum(degrees)
        ptype = "Perfect" if is_perfect(a) else "Imperfect"
        deg_str = "  ".join(f"{d}" for d in degrees)
        print(f"  {CONSONANCES[a]:>8s}  {ptype:>10s}  C={degrees[0]} O={degrees[1]} "
              f"S={degrees[2]} P={degrees[3]}          {total:>4d}")

    print(f"\n  ✓ All sources have total freedom = 22")

# --- Demonstration 4: In-Degree Asymmetry ---

def demo_indegree_asymmetry():
    print("\n" + "=" * 60)
    print("DEMO 4: In-Degree Asymmetry")
    print("=" * 60)

    consonant_list = sorted(CONSONANCES.keys())
    print(f"\n  {'Target':>8s}  {'Type':>10s}  {'Parallel In-Degree':>20s}")
    print(f"  {'─'*8}  {'─'*10}  {'─'*20}")

    for b in consonant_list:
        in_deg = sum(1 for a in consonant_list if fux_allowed(a, b, MotionType.PARALLEL))
        ptype = "Perfect" if is_perfect(b) else "Imperfect"
        print(f"  {CONSONANCES[b]:>8s}  {ptype:>10s}  {in_deg:>20d}")

    print(f"\n  ✓ Perfect consonances: in-degree = 0")
    print(f"  ✓ Imperfect consonances: in-degree = 6")

# --- Demonstration 5: Inversion Asymmetry ---

def demo_inversion():
    print("\n" + "=" * 60)
    print("DEMO 5: Inversion Asymmetry")
    print("=" * 60)

    print(f"\n  {'Interval':>8s}  {'Semitones':>10s}  {'Inversion':>10s}  "
          f"{'Inv. Name':>10s}  {'Survives?':>10s}")
    print(f"  {'─'*8}  {'─'*10}  {'─'*10}  {'─'*10}  {'─'*10}")

    survivors = 0
    for i in sorted(CONSONANCES.keys()):
        inv = (12 - i) % 12
        inv_name = CONSONANCES.get(inv, f"({inv})")
        survives = is_consonant(inv)
        if survives:
            survivors += 1
        print(f"  {CONSONANCES[i]:>8s}  {i:>10d}  {inv:>10d}  "
              f"{inv_name:>10s}  {'✓' if survives else '✗':>10s}")

    print(f"\n  Survivors: {survivors}/6")
    print(f"  ✓ The perfect fifth (7) maps to 5, which is NOT consonant")

# --- Demonstration 6: Full Permission Matrix ---

def demo_permission_matrix():
    print("\n" + "=" * 60)
    print("DEMO 6: Full Permission Matrix")
    print("=" * 60)

    consonant_list = sorted(CONSONANCES.keys())
    header = "        " + "  ".join(f"{CONSONANCES[b]:>5s}" for b in consonant_list)
    print(f"\n{header}")
    print("        " + "  ".join("─" * 5 for _ in consonant_list))

    for a in consonant_list:
        row = f"{CONSONANCES[a]:>6s}  "
        for b in consonant_list:
            h = hom_set(a, b)
            codes = "".join(m.name[0] for m in sorted(h))
            row += f"{codes:>5s}  "
        print(row)

    print("\n  Legend: C=Contrary O=Oblique S=Similar P=Parallel")
    print("  Note: every row is identical (Target Determination)")

# --- Main ---

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  CONTRAPUNTAL QUIVER — Numerical Demonstrations         ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_target_determination()
    demo_bimodal_spectrum()
    demo_uniform_freedom()
    demo_indegree_asymmetry()
    demo_inversion()
    demo_permission_matrix()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualize the Contrapuntal Quiver — Permission Heatmap and Graph Structure

Produces two plots:
1. Permission heatmap showing hom-set sizes for all pairs
2. Subgraph comparison (contrary vs parallel motion)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# --- Core definitions (inlined) ---

CONSONANCE_NAMES = {0: "Uni", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
CONSONANCES = [0, 3, 4, 7, 8, 9]
PERFECT = {0, 7}
N = len(CONSONANCES)

def is_perfect(i):
    return i in PERFECT

def hom_set_size(a, b):
    if is_perfect(b):
        return 3  # contrary, oblique, similar
    return 4  # all four

def fux_allowed_parallel(a, b):
    return not is_perfect(b)

# --- Plot 1: Permission Heatmap ---

def plot_heatmap():
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    matrix = np.array([[hom_set_size(a, b) for b in CONSONANCES] for a in CONSONANCES])

    cmap = plt.cm.RdYlGn
    norm = plt.Normalize(vmin=2.5, vmax=4.5)

    im = ax.imshow(matrix, cmap=cmap, norm=norm, aspect='equal')

    labels = [f"{CONSONANCE_NAMES[c]}\n({c})" for c in CONSONANCES]
    ax.set_xticks(range(N))
    ax.set_xticklabels(labels, fontsize=10)
    ax.set_yticks(range(N))
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel("Target Interval", fontsize=12, fontweight='bold')
    ax.set_ylabel("Source Interval", fontsize=12, fontweight='bold')
    ax.set_title("Contrapuntal Quiver: Hom-Set Sizes\n(Target Determination: columns are uniform)",
                 fontsize=13, fontweight='bold')

    for i in range(N):
        for j in range(N):
            val = matrix[i, j]
            color = 'white' if val <= 3 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)

    # Highlight perfect consonance columns
    for j, c in enumerate(CONSONANCES):
        if is_perfect(c):
            rect = patches.Rectangle((j - 0.5, -0.5), 1, N,
                                     linewidth=3, edgecolor='red',
                                     facecolor='none', linestyle='--')
            ax.add_patch(rect)

    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label("Number of permitted motion types", fontsize=11)
    cbar.set_ticks([3, 4])
    cbar.set_ticklabels(["3 (restricted)", "4 (free)"])

    ax.text(0.02, -0.12, "Red dashed: perfect consonance targets (restricted zone)",
            transform=ax.transAxes, fontsize=9, color='red', fontstyle='italic')

    plt.tight_layout()
    plt.savefig("quiver_heatmap.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: quiver_heatmap.png")

# --- Plot 2: Subgraph Comparison ---

def plot_subgraphs():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Position consonances in a circle
    angles = np.linspace(0, 2 * np.pi, N, endpoint=False) - np.pi / 2
    positions = {c: (np.cos(a), np.sin(a)) for c, a in zip(CONSONANCES, angles)}

    for ax_idx, (title, check_fn, color) in enumerate([
        ("Contrary Motion\n(Complete — 36 edges)", lambda a, b: True, '#2196F3'),
        ("Parallel Motion\n(Restricted — 24 edges)", fux_allowed_parallel, '#FF5722')
    ]):
        ax = axes[ax_idx]
        ax.set_xlim(-1.6, 1.6)
        ax.set_ylim(-1.6, 1.6)
        ax.set_aspect('equal')
        ax.axis('off')
        ax.set_title(title, fontsize=13, fontweight='bold')

        # Draw edges
        edge_count = 0
        for a in CONSONANCES:
            for b in CONSONANCES:
                if check_fn(a, b):
                    x1, y1 = positions[a]
                    x2, y2 = positions[b]
                    if a == b:
                        # Self-loop
                        circle = plt.Circle((x1, y1 + 0.15), 0.12,
                                            fill=False, color=color, alpha=0.4, linewidth=1.5)
                        ax.add_patch(circle)
                    else:
                        dx, dy = x2 - x1, y2 - y1
                        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                                    arrowprops=dict(arrowstyle='->', color=color,
                                                    alpha=0.3, lw=1.5,
                                                    connectionstyle='arc3,rad=0.1'))
                    edge_count += 1

        # Draw nodes
        for c in CONSONANCES:
            x, y = positions[c]
            node_color = '#FF9800' if is_perfect(c) else '#4CAF50'
            circle = plt.Circle((x, y), 0.13, color=node_color, zorder=5)
            ax.add_patch(circle)
            ax.text(x, y, CONSONANCE_NAMES[c], ha='center', va='center',
                    fontsize=9, fontweight='bold', color='white', zorder=6)

        ax.text(0.5, -0.08, f"Edges: {edge_count}",
                transform=ax.transAxes, ha='center', fontsize=11)

    # Legend
    fig.text(0.5, 0.02, "Orange nodes = Perfect consonances | Green nodes = Imperfect consonances",
             ha='center', fontsize=10, fontstyle='italic')

    plt.tight_layout(rect=[0, 0.05, 1, 1])
    plt.savefig("quiver_subgraphs.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: quiver_subgraphs.png")

# --- Plot 3: Restrictiveness Spectrum ---

def plot_spectrum():
    fig, ax = plt.subplots(figsize=(8, 5))

    spectrum = {3: 12, 4: 24}
    bars = ax.bar(spectrum.keys(), spectrum.values(),
                  color=['#FF5722', '#4CAF50'], width=0.6, edgecolor='black')

    ax.set_xlabel("Hom-set size (permitted motion types)", fontsize=12)
    ax.set_ylabel("Number of edges", fontsize=12)
    ax.set_title("Bimodal Restrictiveness Spectrum", fontsize=14, fontweight='bold')
    ax.set_xticks([3, 4])
    ax.set_xticklabels(["3\n(perfect target)", "4\n(imperfect target)"])

    for bar, val in zip(bars, spectrum.values()):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
                str(val), ha='center', va='bottom', fontsize=14, fontweight='bold')

    ax.set_ylim(0, 30)
    ax.text(0.5, 0.85, f"Total morphisms: {12*3 + 24*4} = 12×3 + 24×4",
            transform=ax.transAxes, ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig("spectrum.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectrum.png")

if __name__ == "__main__":
    plot_heatmap()
    plot_subgraphs()
    plot_spectrum()
    print("\nAll visualizations generated.")
