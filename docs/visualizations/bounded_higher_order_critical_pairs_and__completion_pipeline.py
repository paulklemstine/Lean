"""
Visualization: The Bounded Higher-Order Completion Pipeline

Visualizes the full pipeline from rewrite system input to confluence certificate,
showing how each theorem connects to produce the final result.

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib
matplotlib.use('Agg')
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # ===== Left panel: Pipeline flow diagram =====
    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    ax.set_title('Bounded Completion Pipeline', fontsize=14, fontweight='bold')
    
    # Pipeline stages
    stages = [
        (5, 11, 'Rewrite System E\n+ Size Bound N', '#E3F2FD', '#1565C0'),
        (5, 9.2, 'Miller Pattern\nCheck', '#E8F5E9', '#2E7D32'),
        (5, 7.4, 'Critical Pair\nEnumeration', '#FFF3E0', '#E65100'),
        (5, 5.6, 'Bounded Joinability\nChecking', '#FCE4EC', '#AD1457'),
        (5, 3.8, 'Peak Classification\n& Analysis', '#F3E5F5', '#6A1B9A'),
        (5, 2.0, 'Local Confluence\nCertificate', '#E8EAF6', '#1A237E'),
        (5, 0.3, 'Newman\'s Lemma\n→ Unique NFs', '#C8E6C9', '#1B5E20'),
    ]
    
    for x, y, text, bg_color, text_color in stages:
        box = mpatches.FancyBboxPatch((x-2.2, y-0.7), 4.4, 1.4,
                                       boxstyle="round,pad=0.15",
                                       facecolor=bg_color,
                                       edgecolor=text_color,
                                       linewidth=2)
        ax.add_patch(box)
        ax.text(x, y, text, ha='center', va='center',
               fontsize=10, fontweight='bold', color=text_color)
    
    # Arrows between stages
    for i in range(len(stages) - 1):
        y_start = stages[i][1] - 0.75
        y_end = stages[i+1][1] + 0.75
        ax.annotate('', xy=(5, y_end), xytext=(5, y_start),
                   arrowprops=dict(arrowstyle='->', color='#455A64', lw=2.5))
    
    # Side annotations
    annotations = [
        (8.5, 10.1, '∀ r ∈ E.rules,\nisMillerPattern r.lhs', '#2E7D32'),
        (8.5, 8.3, 'BetaCriticalPairsUpTo\nN E', '#E65100'),
        (8.5, 6.5, 'tryJoin / joinableUpTo\nE N t u', '#AD1457'),
        (8.5, 4.7, 'PeakShape:\ndisjoint | nested | overlap', '#6A1B9A'),
        (8.5, 2.9, 'LocallyConfluentOnClosedUpTo\nE N', '#1A237E'),
        (8.5, 1.1, 'full_kb_pipeline\n∃! nf', '#1B5E20'),
    ]
    
    for x, y, text, color in annotations:
        ax.text(x, y, text, ha='center', va='center',
               fontsize=7.5, color=color, style='italic',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='white', 
                        edgecolor=color, alpha=0.7))
    
    # ===== Right panel: Theorem dependency graph =====
    ax2 = axes[1]
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 12)
    ax2.axis('off')
    ax2.set_title('Theorem Dependency Structure', fontsize=14, fontweight='bold')
    
    # Nodes
    nodes = {
        'subst_closure': (3, 11, 'hoRewrite_closed\n_under_subst'),
        'par_refl': (7, 11, 'parRewrite_refl'),
        'par_subsume': (5, 9.5, 'parRewrite_subsumes\n_single'),
        'par_to_star': (2, 8, 'parRewrite_to\n_rewriteStar'),
        'rename_subst': (8, 8, 'rename_eq\n_subst_var'),
        'star_subst': (5, 6.5, 'rewriteStar_subst\n_of_pointwise'),
        'local_conf': (2, 5, 'localConfluence_from\n_joinable_pairs'),
        'newman': (5, 3.5, 'newman_lemma'),
        'church_rosser': (8, 5, 'church_rosser'),
        'full_pipeline': (5, 1.5, 'full_kb_pipeline'),
        'unique_nf': (2, 1.5, 'exists_unique_nf'),
    }
    
    colors = {
        'subst_closure': '#1565C0',
        'par_refl': '#2E7D32',
        'par_subsume': '#2E7D32',
        'par_to_star': '#E65100',
        'rename_subst': '#E65100',
        'star_subst': '#E65100',
        'local_conf': '#AD1457',
        'newman': '#6A1B9A',
        'church_rosser': '#6A1B9A',
        'full_pipeline': '#1B5E20',
        'unique_nf': '#1B5E20',
    }
    
    for key, (x, y, text) in nodes.items():
        c = colors[key]
        box = mpatches.FancyBboxPatch((x-1.3, y-0.5), 2.6, 1.0,
                                       boxstyle="round,pad=0.1",
                                       facecolor='white',
                                       edgecolor=c,
                                       linewidth=1.5)
        ax2.add_patch(box)
        ax2.text(x, y, text, ha='center', va='center',
                fontsize=7, color=c, fontweight='bold',
                family='monospace')
    
    # Edges (dependencies)
    edges = [
        ('subst_closure', 'par_subsume'),
        ('par_refl', 'par_subsume'),
        ('par_subsume', 'par_to_star'),
        ('rename_subst', 'star_subst'),
        ('subst_closure', 'star_subst'),
        ('par_to_star', 'star_subst'),
        ('local_conf', 'newman'),
        ('newman', 'full_pipeline'),
        ('newman', 'church_rosser'),
        ('newman', 'unique_nf'),
        ('church_rosser', 'full_pipeline'),
        ('local_conf', 'full_pipeline'),
        ('unique_nf', 'full_pipeline'),
    ]
    
    for src, tgt in edges:
        x1, y1, _ = nodes[src]
        x2, y2, _ = nodes[tgt]
        ax2.annotate('', xy=(x2, y2 + 0.55), xytext=(x1, y1 - 0.55),
                    arrowprops=dict(arrowstyle='->', color='#90A4AE', 
                                   lw=1, connectionstyle='arc3,rad=0.1'))
    
    # Legend
    legend_items = [
        mpatches.Patch(color='#1565C0', label='Catalog (imported)'),
        mpatches.Patch(color='#2E7D32', label='Parallel rewriting (new)'),
        mpatches.Patch(color='#E65100', label='Substitution stability (new)'),
        mpatches.Patch(color='#AD1457', label='Peak analysis'),
        mpatches.Patch(color='#6A1B9A', label='Confluence theory'),
        mpatches.Patch(color='#1B5E20', label='Full pipeline (new)'),
    ]
    ax2.legend(handles=legend_items, loc='lower right', fontsize=8,
              framealpha=0.9)
    
    plt.suptitle('Bounded Higher-Order Knuth-Bendix Completion Modulo β',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_completion_pipeline.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_completion_pipeline.png")


if __name__ == "__main__":
    main()
