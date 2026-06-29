import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def plot_chain_of_closed_sets():
    universe = [0, 1, 2, 3, 4]
    v = {0: 3, 1: 1, 2: 5, 3: 1, 4: 2}
    closed = [
        (set(), 0), ({1, 3}, 1), ({1, 3, 4}, 2),
        ({0, 1, 3, 4}, 3), ({0, 1, 2, 3, 4}, 5),
    ]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    ax1.set_title('Chain of Closed Sets (Hasse Diagram)', fontsize=14, fontweight='bold')
    for i, (s, threshold) in enumerate(closed):
        label = '{' + ', '.join(map(str, sorted(s))) + '}' if s else '\u2205'
        color = plt.cm.Blues(0.3 + 0.15 * i)
        ax1.add_patch(mpatches.FancyBboxPatch(
            (0.3, i * 1.2), 2.4, 0.8, boxstyle='round,pad=0.1',
            facecolor=color, edgecolor='black', linewidth=1.5))
        ax1.text(1.5, i * 1.2 + 0.4, f'{label}\n(threshold = {threshold})',
                ha='center', va='center', fontsize=10)
        if i > 0:
            ax1.annotate('', xy=(1.5, i * 1.2), xytext=(1.5, (i-1) * 1.2 + 0.8),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    ax1.set_xlim(-0.5, 3.5); ax1.set_ylim(-0.5, 5.5); ax1.axis('off')
    ax2.set_title('Gauge Valuation v', fontsize=14, fontweight='bold')
    elements = sorted(v.keys()); values = [v[e] for e in elements]
    colors = plt.cm.viridis(np.array(values) / max(values))
    bars = ax2.bar(elements, values, color=colors, edgecolor='black', linewidth=1.2)
    ax2.set_xlabel('Element', fontsize=12); ax2.set_ylabel('v(x)', fontsize=12)
    ax2.set_xticks(elements)
    for bar, val in zip(bars, values):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                str(val), ha='center', va='bottom', fontsize=11, fontweight='bold')
    plt.tight_layout()
    plt.savefig('closure_chain_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()

plot_chain_of_closed_sets()
