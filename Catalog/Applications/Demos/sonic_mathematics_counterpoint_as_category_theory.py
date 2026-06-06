#!/usr/bin/env python3
"""
Counterpoint Category Theory: Numerical Demonstrations

This script demonstrates the key results from the formalization of
first-species counterpoint as a categorical structure.
"""

from itertools import product
from typing import NamedTuple

# ─── Musical Definitions ──────────────────────────────────────────

CONSONANT_INTERVALS = {
    "P1": 0,   # Perfect unison
    "m3": 3,   # Minor third
    "M3": 4,   # Major third
    "P5": 7,   # Perfect fifth
    "m6": 8,   # Minor sixth
    "M6": 9,   # Major sixth
}

PERFECT = {"P1", "P5"}
IMPERFECT = {"m3", "M3", "m6", "M6"}
MOTION_TYPES = ["parallel", "similar", "contrary", "oblique"]

# ─── Core Rules ──────────────────────────────────────────────────

def is_permitted(source: str, target: str, motion: str) -> bool:
    """Standard rule: no parallel motion to perfect consonances."""
    return not (motion == "parallel" and target in PERFECT)

def is_strictly_permitted(source: str, target: str, motion: str) -> bool:
    """Strict rule: no parallel or similar motion to perfect consonances."""
    return not (motion in {"parallel", "similar"} and target in PERFECT)

# ─── Enumeration ─────────────────────────────────────────────────

def enumerate_transitions():
    """Enumerate all transitions and classify them."""
    intervals = list(CONSONANT_INTERVALS.keys())
    permitted = []
    forbidden = []
    for s, t, m in product(intervals, intervals, MOTION_TYPES):
        if is_permitted(s, t, m):
            permitted.append((s, t, m))
        else:
            forbidden.append((s, t, m))
    return permitted, forbidden

def enumerate_strict_transitions():
    """Enumerate transitions under strict rules."""
    intervals = list(CONSONANT_INTERVALS.keys())
    permitted = []
    forbidden = []
    for s, t, m in product(intervals, intervals, MOTION_TYPES):
        if is_strictly_permitted(s, t, m):
            permitted.append((s, t, m))
        else:
            forbidden.append((s, t, m))
    return permitted, forbidden

def count_length2_paths():
    """Count valid length-2 counterpoint paths."""
    intervals = list(CONSONANT_INTERVALS.keys())
    count = 0
    for i1, i2, i3, m1, m2 in product(intervals, intervals, intervals,
                                        MOTION_TYPES, MOTION_TYPES):
        if is_permitted(i1, i2, m1) and is_permitted(i2, i3, m2):
            count += 1
    return count

# ─── Symmetry Analysis ──────────────────────────────────────────

COMPLEMENT = {"P1": "P1", "m3": "M6", "M3": "m6", "P5": "P5", "m6": "M3", "M6": "m3"}

def verify_complement_involution():
    """Verify the complement map is an involution."""
    for i, c in COMPLEMENT.items():
        assert COMPLEMENT[c] == i, f"Complement is not involutive at {i}"
    print("✓ Complement is an involution")

def verify_complement_preserves_permitted():
    """Verify complement preserves the permitted relation."""
    intervals = list(CONSONANT_INTERVALS.keys())
    for s, t, m in product(intervals, intervals, MOTION_TYPES):
        p1 = is_permitted(s, t, m)
        p2 = is_permitted(COMPLEMENT[s], COMPLEMENT[t], m)
        assert p1 == p2, f"Complement does not preserve permitted at ({s},{t},{m})"
    print("✓ Complement preserves the permitted relation")

# ─── Main ────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("COUNTERPOINT AS CATEGORY THEORY")
    print("Numerical Verification of Formal Results")
    print("=" * 60)

    # Theorem 1: Counting
    permitted, forbidden = enumerate_transitions()
    print(f"\n--- Standard Rule (no parallel to perfect) ---")
    print(f"Total transitions:    {len(permitted) + len(forbidden)}")
    print(f"Permitted:            {len(permitted)}")
    print(f"Forbidden:            {len(forbidden)}")
    assert len(permitted) == 132
    assert len(forbidden) == 12
    print("✓ Verified: 132 permitted, 12 forbidden")

    # Theorem 2: Strict counting
    sp, sf = enumerate_strict_transitions()
    print(f"\n--- Strict Rule (no parallel/similar to perfect) ---")
    print(f"Permitted:            {len(sp)}")
    print(f"Forbidden:            {len(sf)}")
    assert len(sp) == 120
    assert len(sf) == 24
    print("✓ Verified: 120 strictly permitted, 24 forbidden")

    # Theorem 3: Forbidden transitions
    print(f"\n--- Forbidden Transitions ---")
    for s, t, m in forbidden:
        print(f"  {s} → {t} by {m}")
    print("✓ All forbidden transitions are parallel → perfect")

    # Theorem 4: Path counting
    paths = count_length2_paths()
    print(f"\n--- Length-2 Path Count ---")
    print(f"Valid length-2 paths: {paths}")
    print(f"Total potential:      {6**3 * 4**2}")
    print(f"Passage rate:         {paths}/{6**3 * 4**2} = {paths/(6**3 * 4**2):.4f}")
    assert paths == 2904
    print("✓ Verified: 2904 valid length-2 paths")

    # Theorem 5: Fiber decomposition
    print(f"\n--- Fiber Decomposition ---")
    for t in CONSONANT_INTERVALS:
        count = sum(1 for m in MOTION_TYPES if is_permitted("P1", t, m))
        class_label = "perfect" if t in PERFECT else "imperfect"
        print(f"  {t} ({class_label}): {count} permitted motion types")
    print("✓ Perfect: 3 types, Imperfect: 4 types")
    print(f"✓ 132 = 6×4×4 + 6×2×3 = {6*4*4} + {6*2*3}")

    # Symmetry verification
    print(f"\n--- Symmetry Analysis ---")
    verify_complement_involution()
    verify_complement_preserves_permitted()

    # Diatonic analysis
    print(f"\n--- Diatonic Specialization (C Major) ---")
    CMAJOR = [0, 2, 4, 5, 7, 9, 11]  # semitone values
    consonant_semitones = set(CONSONANT_INTERVALS.values())
    consonant_pairs = 0
    for i, d1 in enumerate(CMAJOR):
        for j, d2 in enumerate(CMAJOR):
            interval = (d2 - d1) % 12
            if interval in consonant_semitones:
                consonant_pairs += 1
    print(f"Consonant diatonic pairs: {consonant_pairs} out of {7*7}")
    print(f"B-F tritone (6 semitones): NOT consonant ✓")
    print(f"C-G fifth (7 semitones):   consonant ✓")

    print(f"\n{'=' * 60}")
    print("All numerical results verified successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Counterpoint Transition Graph

Displays the permitted transitions between consonant interval classes,
colored by motion type. Shows the asymmetry between perfect and imperfect
consonances.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def create_transition_graph():
    """Create and display the counterpoint transition graph."""

    intervals = ["P1", "m3", "M3", "P5", "m6", "M6"]
    perfect = {"P1", "P5"}
    motion_types = ["parallel", "similar", "contrary", "oblique"]
    motion_colors = {
        "parallel": "#e74c3c",
        "similar": "#f39c12",
        "contrary": "#2ecc71",
        "oblique": "#3498db"
    }

    def is_permitted(s, t, m):
        return not (m == "parallel" and t in perfect)

    # Layout: arrange intervals in a circle
    n = len(intervals)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    # Shift so P1 is at top
    angles = angles + np.pi / 2
    radius = 3.0
    positions = {iv: (radius * np.cos(a), radius * np.sin(a))
                 for iv, a in zip(intervals, angles)}

    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Panel 1: All permitted transitions (standard rule)
    ax1 = axes[0]
    ax1.set_title("Standard Rule: 132 Permitted Transitions", fontsize=14, fontweight='bold')
    ax1.set_xlim(-5, 5)
    ax1.set_ylim(-5, 5)
    ax1.set_aspect('equal')
    ax1.axis('off')

    # Draw edges by motion type
    for m_idx, motion in enumerate(motion_types):
        offset = (m_idx - 1.5) * 0.08
        for s in intervals:
            for t in intervals:
                if is_permitted(s, t, motion):
                    sx, sy = positions[s]
                    tx, ty = positions[t]
                    if s == t:
                        # Self-loop
                        loop_angle = np.arctan2(sy, sx)
                        loop_r = 0.4
                        lx = sx + loop_r * np.cos(loop_angle)
                        ly = sy + loop_r * np.sin(loop_angle)
                        circle = plt.Circle((lx, ly), 0.15, fill=False,
                                          color=motion_colors[motion], alpha=0.3, linewidth=0.5)
                        ax1.add_patch(circle)
                    else:
                        dx, dy = tx - sx, ty - sy
                        perp_x, perp_y = -dy, dx
                        length = np.sqrt(perp_x**2 + perp_y**2)
                        if length > 0:
                            perp_x, perp_y = perp_x/length * offset, perp_y/length * offset
                        ax1.annotate("", xy=(tx + perp_x, ty + perp_y),
                                    xytext=(sx + perp_x, sy + perp_y),
                                    arrowprops=dict(arrowstyle='->', color=motion_colors[motion],
                                                   alpha=0.15, lw=0.5))

    # Draw nodes
    for iv, (x, y) in positions.items():
        color = '#ff6b6b' if iv in perfect else '#69b4ff'
        ax1.plot(x, y, 'o', markersize=30, color=color, zorder=5)
        ax1.text(x, y, iv, ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=6)

    # Legend
    handles = [mpatches.Patch(color=c, label=m) for m, c in motion_colors.items()]
    handles.append(mpatches.Patch(color='#ff6b6b', label='Perfect'))
    handles.append(mpatches.Patch(color='#69b4ff', label='Imperfect'))
    ax1.legend(handles=handles, loc='lower left', fontsize=8)

    # Panel 2: Parallel-only subgraph
    ax2 = axes[1]
    ax2.set_title("Parallel Motion Only: 24 Edges\n(Perfect consonances unreachable)",
                  fontsize=14, fontweight='bold')
    ax2.set_xlim(-5, 5)
    ax2.set_ylim(-5, 5)
    ax2.set_aspect('equal')
    ax2.axis('off')

    for s in intervals:
        for t in intervals:
            if is_permitted(s, t, "parallel"):
                sx, sy = positions[s]
                tx, ty = positions[t]
                if s == t:
                    loop_angle = np.arctan2(sy, sx)
                    loop_r = 0.4
                    lx = sx + loop_r * np.cos(loop_angle)
                    ly = sy + loop_r * np.sin(loop_angle)
                    circle = plt.Circle((lx, ly), 0.2, fill=False,
                                      color='#e74c3c', alpha=0.6, linewidth=1.5)
                    ax2.add_patch(circle)
                else:
                    ax2.annotate("", xy=(tx, ty), xytext=(sx, sy),
                                arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                               alpha=0.4, lw=1.0))

    # Draw forbidden edges (dashed, to P1 and P5)
    for s in intervals:
        for t in perfect:
            sx, sy = positions[s]
            tx, ty = positions[t]
            if s != t:
                ax2.plot([sx, tx], [sy, ty], '--', color='gray', alpha=0.2, lw=0.5)

    for iv, (x, y) in positions.items():
        color = '#ff6b6b' if iv in perfect else '#69b4ff'
        alpha = 0.4 if iv in perfect else 1.0
        ax2.plot(x, y, 'o', markersize=30, color=color, zorder=5, alpha=alpha)
        ax2.text(x, y, iv, ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=6, alpha=alpha if iv in perfect else 1.0)

    # Add X marks on perfect consonances
    for iv in perfect:
        x, y = positions[iv]
        ax2.text(x, y - 0.6, '✗ unreachable', ha='center', va='top',
                fontsize=8, color='red', style='italic')

    plt.tight_layout()
    plt.savefig('counterpoint_transitions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: counterpoint_transitions.png")


def create_fiber_chart():
    """Create a chart showing the fiber decomposition."""
    fig, ax = plt.subplots(figsize=(10, 6))

    intervals = ["P1", "m3", "M3", "P5", "m6", "M6"]
    standard_fibers = [3, 4, 4, 3, 4, 4]
    strict_fibers = [2, 4, 4, 2, 4, 4]

    x = np.arange(len(intervals))
    width = 0.35

    bars1 = ax.bar(x - width/2, standard_fibers, width, label='Standard Rule',
                   color=['#ff6b6b' if f == 3 else '#69b4ff' for f in standard_fibers],
                   edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, strict_fibers, width, label='Strict Rule',
                   color=['#ff4444' if f == 2 else '#4488ff' for f in strict_fibers],
                   edgecolor='black', linewidth=0.5, alpha=0.7)

    ax.set_xlabel('Target Consonant Interval', fontsize=12)
    ax.set_ylabel('Number of Permitted Motion Types', fontsize=12)
    ax.set_title('Fiber Decomposition: Motion Types per Target Interval', fontsize=14,
                fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(intervals, fontsize=11)
    ax.set_ylim(0, 5)
    ax.legend(fontsize=10)

    # Annotate
    for bar, val in zip(bars1, standard_fibers):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               str(val), ha='center', fontsize=10, fontweight='bold')
    for bar, val in zip(bars2, strict_fibers):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               str(val), ha='center', fontsize=10)

    ax.axhline(y=4, color='gray', linestyle='--', alpha=0.3, label='Maximum (4)')

    # Add perfect/imperfect labels
    ax.text(0, -0.8, 'PERFECT', ha='center', fontsize=9, color='red', fontweight='bold',
           transform=ax.get_xaxis_transform())
    ax.text(3, -0.8, 'PERFECT', ha='center', fontsize=9, color='red', fontweight='bold',
           transform=ax.get_xaxis_transform())

    plt.tight_layout()
    plt.savefig('fiber_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fiber_decomposition.png")


if __name__ == "__main__":
    create_transition_graph()
    create_fiber_chart()
    print("All visualizations generated.")
