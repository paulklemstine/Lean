#!/usr/bin/env python3
"""
Visualization: Critical Pair Analysis
=======================================

Visualizes the critical pair between rules 7 and 8, showing how two
reduction paths diverge and then reconverge modulo AC-equivalence.

This script is fully self-contained and does not import any local modules.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def main():
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Title
    ax.text(5, 8.5, 'Critical Pair: Rules 7 + 8', fontsize=18,
            fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#ecf0f1', edgecolor='#2c3e50', linewidth=2))

    # Source term
    ax.text(5, 7, '⟨a•v, w⊕u⟩', fontsize=16, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='#f39c12', edgecolor='#e67e22', linewidth=2),
            fontfamily='monospace', fontweight='bold')

    # Arrows from source
    ax.annotate('', xy=(2, 5.8), xytext=(4, 6.7),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2.5))
    ax.annotate('', xy=(8, 5.8), xytext=(6, 6.7),
                arrowprops=dict(arrowstyle='->', color='#2980b9', lw=2.5))

    ax.text(2.5, 6.5, 'Rule 7\n(distribute\nover ⊕)', fontsize=9, ha='center',
            color='#e74c3c', fontweight='bold')
    ax.text(7.5, 6.5, 'Rule 8\n(extract\nscalar)', fontsize=9, ha='center',
            color='#2980b9', fontweight='bold')

    # Left path
    ax.text(2, 5.5, '⟨a•v, w⟩ + ⟨a•v, u⟩', fontsize=12, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8', edgecolor='#e74c3c'),
            fontfamily='monospace')

    ax.annotate('', xy=(2, 3.8), xytext=(2, 5),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2))
    ax.text(0.5, 4.4, 'Rule 8\n×2', fontsize=9, ha='center', color='#e74c3c', fontweight='bold')

    ax.text(2, 3.5, 'a·⟨v,w⟩ + a·⟨v,u⟩', fontsize=14, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='#f5b7b1', edgecolor='#c0392b', linewidth=2),
            fontfamily='monospace', fontweight='bold')

    # Right path
    ax.text(8, 5.5, 'a · ⟨v, w⊕u⟩', fontsize=12, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#d4e6f1', edgecolor='#2980b9'),
            fontfamily='monospace')

    ax.annotate('', xy=(8, 3.8), xytext=(8, 5),
                arrowprops=dict(arrowstyle='->', color='#2980b9', lw=2))
    ax.text(9.5, 4.4, 'Rule 7', fontsize=9, ha='center', color='#2980b9', fontweight='bold')

    ax.text(8, 3.5, 'a · (⟨v,w⟩ + ⟨v,u⟩)', fontsize=14, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='#a9cce3', edgecolor='#2471a3', linewidth=2),
            fontfamily='monospace', fontweight='bold')

    # AC-equivalence connection
    ax.annotate('', xy=(6, 3.5), xytext=(4, 3.5),
                arrowprops=dict(arrowstyle='<->', color='#27ae60', lw=3,
                               connectionstyle='arc3,rad=0'))

    ax.text(5, 2.5, 'AC-Equivalent!\na·(x+y) ≡ a·x + a·y', fontsize=14,
            ha='center', va='center', fontweight='bold', color='#27ae60',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#d5f5e3', edgecolor='#27ae60', linewidth=2))

    # Bottom note
    ax.text(5, 1, 'Both normal forms represent the same algebraic quantity.\n'
                   'Extended ACEq includes scalMul-over-scalAdd distributivity.',
            fontsize=11, ha='center', va='center', style='italic', color='#7f8c8d',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='white', edgecolor='#bdc3c7'))

    # Legend
    legend_elements = [
        patches.Patch(facecolor='#fadbd8', edgecolor='#e74c3c', label='Path via Rule 7 first'),
        patches.Patch(facecolor='#d4e6f1', edgecolor='#2980b9', label='Path via Rule 8 first'),
        patches.Patch(facecolor='#d5f5e3', edgecolor='#27ae60', label='AC-equivalent junction'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10, framealpha=0.9)

    plt.savefig('viz_critical_pairs.png', dpi=150, bbox_inches='tight')
    print("Saved viz_critical_pairs.png")


if __name__ == "__main__":
    main()
