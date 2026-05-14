#!/usr/bin/env python3
"""
Pythagorean Music Theory: Visualizations

Generates publication-quality figures for the research paper.
All figures are saved as PNG and returned as base64 for JSON embedding.
"""

import math
import base64
import io
from fractions import Fraction
from typing import List, Tuple

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


# ─── Berggren tree generation (self-contained) ──────────────────────────────

def berg_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berg_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berg_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def berggren_tree(a, b, c, depth):
    result = [("root", (a, b, c), 0)]
    if depth > 0:
        for label, gen in [("A", berg_A), ("B", berg_B), ("C", berg_C)]:
            child = gen(a, b, c)
            sub = berggren_tree(*child, depth - 1)
            for path, triple, d in sub:
                result.append((label + "." + path if path != "root" else label,
                              triple, d + 1))
    return result

def leg_ratio(a, b):
    return Fraction(max(abs(a), abs(b)), min(abs(a), abs(b)))

def hyp_leg_ratio(a, b, c):
    return Fraction(abs(c), max(abs(a), abs(b)))

def interval_complexity(q):
    return q.numerator + q.denominator

def octave_reduce(x):
    while x >= 2: x /= 2
    while x < 1: x *= 2
    return x


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ─── Visualization 1: Berggren Tree with Musical Intervals ──────────────────

def viz_berggren_tree_intervals():
    """Berggren tree showing musical interval ratios at each node."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    tree = berggren_tree(3, 4, 5, 2)
    
    # Layout positions
    positions = {}
    depth_counts = {}
    for path, triple, d in tree:
        depth_counts[d] = depth_counts.get(d, 0) + 1
    
    depth_indices = {d: 0 for d in depth_counts}
    
    for path, triple, d in tree:
        idx = depth_indices[d]
        total = depth_counts[d]
        x = (idx + 0.5) / total
        y = 1 - d * 0.3
        positions[path] = (x, y)
        depth_indices[d] += 1
        
        a, b, c = triple
        lr = leg_ratio(a, b)
        hlr = hyp_leg_ratio(a, b, c)
        comp = interval_complexity(lr)
        
        color = '#2ecc71' if comp <= 12 else '#e74c3c'
        
        circle = plt.Circle((x, y), 0.035, color=color, alpha=0.8, zorder=3)
        ax.add_patch(circle)
        
        ax.text(x, y + 0.005, f"({a},{b},{c})", ha='center', va='bottom',
                fontsize=7, fontweight='bold', zorder=4)
        ax.text(x, y - 0.015, f"leg={lr}", ha='center', va='top',
                fontsize=6, color='white', zorder=4)
    
    # Draw edges
    for path, triple, d in tree:
        if d > 0:
            parent_path = ".".join(path.split(".")[:-1]) if "." in path else "root"
            if parent_path in positions:
                px, py = positions[parent_path]
                cx, cy = positions[path]
                ax.plot([px, cx], [py, cy], 'k-', alpha=0.3, lw=1, zorder=1)
    
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.15)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Tree with Musical Interval Ratios\n'
                 '(Green = Consonant, Red = Dissonant)',
                 fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    return fig


# ─── Visualization 2: Circle of Fifths Projection ───────────────────────────

def viz_circle_of_fifths():
    """Show how Pythagorean triple ratios project onto the circle of fifths."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Draw the circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', lw=2, alpha=0.3)
    
    # Standard notes on circle of fifths
    notes = ['C', 'G', 'D', 'A', 'E', 'B', 'F♯', 'C♯/D♭', 'A♭', 'E♭', 'B♭', 'F']
    for i, note in enumerate(notes):
        angle = np.pi/2 - i * 2*np.pi/12
        x, y = 1.15 * np.cos(angle), 1.15 * np.sin(angle)
        ax.text(x, y, note, ha='center', va='center', fontsize=10, fontweight='bold')
        x2, y2 = np.cos(angle), np.sin(angle)
        ax.plot(x2, y2, 'ko', markersize=5, alpha=0.5)
    
    # Plot Pythagorean triple ratios
    tree = berggren_tree(3, 4, 5, 2)
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(tree)))
    
    for idx, (path, (a, b, c), d) in enumerate(tree):
        lr = leg_ratio(a, b)
        lr_float = float(lr)
        reduced = octave_reduce(lr_float)
        
        # Map to circle: cents / 1200 * 2π
        cents = 1200 * math.log2(reduced)
        # Convert to circle of fifths position
        fifths_pos = math.log(reduced) / math.log(1.5)
        angle = np.pi/2 - fifths_pos * 2*np.pi / (math.log(2)/math.log(1.5))
        
        r_plot = 0.85 - d * 0.1
        x, y = r_plot * np.cos(angle), r_plot * np.sin(angle)
        
        ax.plot(x, y, 'o', color=colors[idx], markersize=8 + (3-d)*3,
                alpha=0.7, markeredgecolor='black', markeredgewidth=0.5)
        
        if d <= 1:
            ax.annotate(f"{lr}\n({a},{b},{c})", (x, y),
                       textcoords="offset points", xytext=(10, 10),
                       fontsize=7, alpha=0.8,
                       arrowprops=dict(arrowstyle='->', alpha=0.3))
    
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Pythagorean Triple Ratios on the Circle of Fifths\n'
                 '(Deeper nodes = smaller markers)',
                 fontsize=13, fontweight='bold')
    
    plt.tight_layout()
    return fig


# ─── Visualization 3: Consonance Complexity Spectrum ─────────────────────────

def viz_consonance_spectrum():
    """Plot interval complexity vs. tropical coordinate for all tree nodes."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    tree = berggren_tree(3, 4, 5, 4)
    
    complexities = []
    log_ratios = []
    depths = []
    labels = []
    
    for path, (a, b, c), d in tree:
        lr = leg_ratio(a, b)
        comp = interval_complexity(lr)
        log_r = math.log(float(lr))
        complexities.append(comp)
        log_ratios.append(log_r)
        depths.append(d)
        labels.append(f"{lr}")
    
    # Left: complexity vs log ratio
    scatter = ax1.scatter(log_ratios, complexities, c=depths, cmap='viridis',
                         s=50, alpha=0.7, edgecolors='black', linewidths=0.5)
    ax1.axhline(y=12, color='red', linestyle='--', alpha=0.5, label='Consonance threshold')
    ax1.set_xlabel('Tropical Coordinate: log(leg ratio)', fontsize=11)
    ax1.set_ylabel('Interval Complexity', fontsize=11)
    ax1.set_title('Consonance vs. Tropical Position', fontsize=13, fontweight='bold')
    ax1.legend()
    plt.colorbar(scatter, ax=ax1, label='Tree Depth')
    
    # Right: complexity distribution by depth
    depth_data = {}
    for comp, d in zip(complexities, depths):
        if d not in depth_data:
            depth_data[d] = []
        depth_data[d].append(comp)
    
    bp_data = [depth_data[d] for d in sorted(depth_data.keys())]
    bp = ax2.boxplot(bp_data, labels=[str(d) for d in sorted(depth_data.keys())],
                    patch_artist=True)
    
    colors_box = plt.cm.viridis(np.linspace(0.2, 0.9, len(bp_data)))
    for patch, color in zip(bp['boxes'], colors_box):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    
    ax2.axhline(y=12, color='red', linestyle='--', alpha=0.5, label='Consonance threshold')
    ax2.set_xlabel('Berggren Tree Depth', fontsize=11)
    ax2.set_ylabel('Interval Complexity', fontsize=11)
    ax2.set_title('Complexity Distribution by Depth', fontsize=13, fontweight='bold')
    ax2.legend()
    
    plt.tight_layout()
    return fig


# ─── Visualization 4: Tropical Interval Space ───────────────────────────────

def viz_tropical_space():
    """Visualize the tropical (logarithmic) interval space."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    
    tree = berggren_tree(3, 4, 5, 3)
    
    for path, (a, b, c), d in tree:
        lr = leg_ratio(a, b)
        hlr = hyp_leg_ratio(a, b, c)
        
        x = math.log(float(lr))
        y = math.log(float(hlr))
        
        color = plt.cm.Set1(d / 4)
        size = 100 / (d + 1)
        
        ax.scatter(x, y, c=[color], s=size, alpha=0.7,
                  edgecolors='black', linewidths=0.5, zorder=3)
        
        if d <= 1:
            ax.annotate(f"({a},{b},{c})\n{lr}, {hlr}",
                       (x, y), textcoords="offset points", xytext=(5, 5),
                       fontsize=7, alpha=0.8)
    
    # Mark special ratios
    special = {
        'log(4/3)': math.log(4/3),
        'log(3/2)': math.log(3/2),
        'log(2)': math.log(2),
    }
    for name, val in special.items():
        ax.axvline(x=val, color='gray', linestyle=':', alpha=0.3)
        ax.text(val, ax.get_ylim()[1] * 0.95, name, rotation=90,
               va='top', fontsize=8, alpha=0.5)
    
    ax.set_xlabel('log(leg ratio) — Tropical Leg Coordinate', fontsize=11)
    ax.set_ylabel('log(hyp/leg ratio) — Tropical Hypotenuse Coordinate', fontsize=11)
    ax.set_title('Tropical Interval Space of Pythagorean Triples\n'
                 '(Multiplicative ratios → additive coordinates)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    return fig


# ─── Visualization 5: Temperament Error Chart ───────────────────────────────

def viz_temperament_errors():
    """Compare just intonation ratios from triples with equal temperament."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    tree = berggren_tree(3, 4, 5, 2)
    
    ratios = []
    for _, (a, b, c), _ in tree:
        lr = leg_ratio(a, b)
        hlr = hyp_leg_ratio(a, b, c)
        for r in [lr, hlr]:
            reduced = octave_reduce(float(r))
            ratios.append((r, reduced))
    
    # Remove duplicates
    seen = set()
    unique_ratios = []
    for r, red in ratios:
        if r not in seen:
            seen.add(r)
            unique_ratios.append((r, red))
    
    unique_ratios.sort(key=lambda x: x[1])
    
    just_cents = [1200 * math.log2(red) for _, red in unique_ratios]
    et_cents = [round(jc / 100) * 100 for jc in just_cents]
    errors = [jc - ec for jc, ec in zip(just_cents, et_cents)]
    labels = [str(r) for r, _ in unique_ratios]
    
    colors = ['#2ecc71' if abs(e) < 15 else '#e74c3c' for e in errors]
    
    bars = ax.barh(range(len(errors)), errors, color=colors, alpha=0.7,
                   edgecolor='black', linewidth=0.5)
    
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=8)
    ax.axvline(x=0, color='black', linewidth=1)
    ax.set_xlabel('Temperament Error (cents)', fontsize=11)
    ax.set_ylabel('Just Ratio', fontsize=11)
    ax.set_title('Just Intonation vs. 12-TET: Temperament Errors\n'
                 '(Green ≤ 15¢, Red > 15¢)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, axis='x', alpha=0.3)
    
    plt.tight_layout()
    return fig


# ─── Generate All Visualizations ────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    
    figs = {
        'berggren_tree': viz_berggren_tree_intervals(),
        'circle_of_fifths': viz_circle_of_fifths(),
        'consonance_spectrum': viz_consonance_spectrum(),
        'tropical_space': viz_tropical_space(),
        'temperament_errors': viz_temperament_errors(),
    }
    
    for name, fig in figs.items():
        filename = f"{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                   facecolor='white', edgecolor='none')
        print(f"  Saved {filename}")
        plt.close(fig)
    
    print("All visualizations generated.")
