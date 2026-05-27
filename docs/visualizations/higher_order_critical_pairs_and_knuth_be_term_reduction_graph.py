#!/usr/bin/env python3
"""
Visualization: Term Reduction Graph

Shows how terms reduce under a rewrite system, illustrating the
diamond property of confluent rewriting.

Uses matplotlib to create a reduction graph.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def draw_reduction_graph():
    """Draw a sample reduction graph showing confluence."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 6)
    ax.axis('off')
    ax.set_title('Confluent Reduction Graph\n'
                 'Higher-Order Term Rewriting Modulo β',
                 fontsize=14, fontweight='bold')

    # Node positions
    nodes = {
        't':     (0, 5),
        's1':    (-3, 3),
        's2':    (3, 3),
        'u1':    (-4, 1),
        'u2':    (-1, 1),
        'u3':    (2, 1),
        'u4':    (4, 1),
        'w1':    (-2, -1),
        'w2':    (2, -1),
        'nf':    (0, -3),
    }

    labels = {
        't':  'map f (map g (map h xs))',
        's1': 'map (f∘g) (map h xs)',
        's2': 'map f (map (g∘h) xs)',
        'u1': 'map ((f∘g)∘h) xs',
        'u2': 'map (f∘g) (map h xs)',
        'u3': 'map f (map (g∘h) xs)',
        'u4': 'map (f∘(g∘h)) xs',
        'w1': 'map ((f∘g)∘h) xs',
        'w2': 'map (f∘(g∘h)) xs',
        'nf': 'map (f∘g∘h) xs  [NF]',
    }

    # Edges (directed)
    edges = [
        ('t', 's1', '#2196F3'),
        ('t', 's2', '#F44336'),
        ('s1', 'u1', '#2196F3'),
        ('s1', 'u2', '#9E9E9E'),
        ('s2', 'u3', '#9E9E9E'),
        ('s2', 'u4', '#F44336'),
        ('u1', 'w1', '#2196F3'),
        ('u2', 'w1', '#9E9E9E'),
        ('u3', 'w2', '#9E9E9E'),
        ('u4', 'w2', '#F44336'),
        ('w1', 'nf', '#4CAF50'),
        ('w2', 'nf', '#4CAF50'),
    ]

    # Draw edges
    for src, dst, color in edges:
        x1, y1 = nodes[src]
        x2, y2 = nodes[dst]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5,
                                   connectionstyle='arc3,rad=0.1'))

    # Draw nodes
    for name, (x, y) in nodes.items():
        if name == 'nf':
            color = '#E8F5E9'
            ec = '#4CAF50'
        elif name == 't':
            color = '#E3F2FD'
            ec = '#2196F3'
        else:
            color = '#FFF9C4'
            ec = '#FFC107'

        bbox = dict(boxstyle='round,pad=0.4', facecolor=color,
                    edgecolor=ec, alpha=0.9, linewidth=1.5)
        ax.text(x, y, labels[name], ha='center', va='center',
                fontsize=7, bbox=bbox, fontweight='bold' if name in ('t', 'nf') else 'normal')

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='#2196F3', lw=2, label='Left reduction path'),
        Line2D([0], [0], color='#F44336', lw=2, label='Right reduction path'),
        Line2D([0], [0], color='#4CAF50', lw=2, label='Confluence (join)'),
        Line2D([0], [0], color='#9E9E9E', lw=2, label='Alternative paths'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=9)

    # Annotation
    ax.text(0, -5, 'Newman\'s Lemma: Local confluence + termination → unique normal forms',
            ha='center', fontsize=10, style='italic', color='#666666')

    plt.tight_layout()
    plt.savefig('term_reduction_graph.png', dpi=150, bbox_inches='tight')
    print("Saved: term_reduction_graph.png")


if __name__ == "__main__":
    draw_reduction_graph()
