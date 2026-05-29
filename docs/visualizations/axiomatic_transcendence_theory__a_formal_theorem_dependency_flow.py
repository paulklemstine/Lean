#!/usr/bin/env python3
"""
Visualization: Schanuel Theorem Dependency Flow

Creates a diagram showing the logical flow from definitions through lemmas
to the main theorems, illustrating the architecture of the formal package.
Uses matplotlib to draw a directed acyclic graph of theorem dependencies.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def main():
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Node positions and labels
    nodes = {
        # Definitions (bottom layer)
        'expTuple': (2, 1, 'expTuple', '#E8D5B7', 'def'),
        'combinedTuple': (5, 1, 'combinedTuple', '#E8D5B7', 'def'),
        'ExpAlgConfig': (8, 1, 'ExpAlgConfig', '#E8D5B7', 'def'),
        'SchanuelLBP': (3.5, 2.5, 'SchanuelLowerBound\nPredicate', '#D4E6F1', 'def'),
        'SchanuelDef': (7.5, 2.5, 'SchanuelDeficient', '#D4E6F1', 'def'),
        'SchanuelConj': (11, 2.5, 'SchanuelConjecture', '#D4E6F1', 'def'),
        
        # Lemmas (middle layer)
        'notAlgIndep': (2, 4.5, 'not_algebraicIndep\n_of_isAlgebraic', '#FADBD8', 'lemma'),
        'embToInr': (5.5, 4.5, 'embedding_maps\n_to_inr_of_algebraic', '#FADBD8', 'lemma'),
        'notLinIndep': (9.5, 4.5, 'not_linearIndep\n_of_rational_relation', '#FADBD8', 'lemma'),
        
        # Main theorems (top layer)
        'thm1': (2, 7, 'Schanuel implies\n∃ transcendental exp', '#ABEBC6', 'theorem'),
        'thm2': (5.5, 7, 'Schanuel vacuous\non dependent tuples', '#ABEBC6', 'theorem'),
        'thm3': (9, 7, 'Pair forces\ntranscendence', '#ABEBC6', 'theorem'),
        'thm4': (12, 7, 'Matrix rank →\nℚ-independence', '#ABEBC6', 'theorem'),
        
        # Corollaries
        'cor1': (3.5, 9, 'Global Schanuel →\nno deficiency', '#D5F5E3', 'corollary'),
        'cor2': (7.5, 9, 'Global Schanuel →\ntranscendence', '#D5F5E3', 'corollary'),
    }
    
    # Draw nodes
    for key, (x, y, label, color, kind) in nodes.items():
        w, h = 2.2, 1.2
        if kind == 'def':
            h = 0.8
        rect = mpatches.FancyBboxPatch((x - w/2, y - h/2), w, h, 
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, edgecolor='black',
                                        linewidth=1.5 if kind == 'theorem' else 1)
        ax.add_patch(rect)
        fontsize = 8 if '\n' in label else 9
        ax.text(x, y, label, ha='center', va='center', fontsize=fontsize, fontweight='bold')
    
    # Edges (from → to)
    edges = [
        ('expTuple', 'combinedTuple'),
        ('combinedTuple', 'SchanuelLBP'),
        ('SchanuelLBP', 'SchanuelDef'),
        ('SchanuelLBP', 'SchanuelConj'),
        ('notAlgIndep', 'embToInr'),
        ('embToInr', 'thm1'),
        ('SchanuelLBP', 'thm1'),
        ('notLinIndep', 'thm2'),
        ('SchanuelDef', 'thm2'),
        ('thm1', 'thm3'),
        ('SchanuelConj', 'cor1'),
        ('thm1', 'cor2'),
        ('SchanuelConj', 'cor2'),
    ]
    
    for src, dst in edges:
        sx, sy = nodes[src][0], nodes[src][1]
        dx, dy = nodes[dst][0], nodes[dst][1]
        
        # Offset for node boundaries
        h_src = 0.4 if nodes[src][4] == 'def' else 0.6
        h_dst = 0.4 if nodes[dst][4] == 'def' else 0.6
        
        ax.annotate('', xy=(dx, dy - h_dst), xytext=(sx, sy + h_src),
                    arrowprops=dict(arrowstyle='->', color='#555555', lw=1.2,
                                   connectionstyle='arc3,rad=0.1'))
    
    # Legend
    legend_items = [
        mpatches.Patch(facecolor='#E8D5B7', edgecolor='black', label='Definition'),
        mpatches.Patch(facecolor='#D4E6F1', edgecolor='black', label='Core Predicate'),
        mpatches.Patch(facecolor='#FADBD8', edgecolor='black', label='Key Lemma'),
        mpatches.Patch(facecolor='#ABEBC6', edgecolor='black', label='Main Theorem'),
        mpatches.Patch(facecolor='#D5F5E3', edgecolor='black', label='Corollary'),
    ]
    ax.legend(handles=legend_items, loc='lower right', fontsize=10,
             framealpha=0.9, edgecolor='black')
    
    ax.set_title('Schanuel Formal Package: Theorem Dependency Flow',
                fontsize=16, fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig('viz_theorem_flow.png', dpi=150, bbox_inches='tight')
    print("Saved viz_theorem_flow.png")

if __name__ == "__main__":
    main()
