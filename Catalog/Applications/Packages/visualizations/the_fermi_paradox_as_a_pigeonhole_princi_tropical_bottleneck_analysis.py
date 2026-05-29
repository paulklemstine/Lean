"""
Visualization: Tropical Bottleneck Analysis

Shows the Drake equation factors in tropical (log) space, identifying
the bottleneck factor. In tropical geometry, multiplication becomes
addition and the dominant factor (maximum in log space) is the
"Great Filter" bottleneck.
"""

import numpy as np
import matplotlib.pyplot as plt

# Drake factor scenarios
scenarios = {
    "Optimistic": {
        "Abiogenesis": 0.5,
        "Complex Life": 0.1,
        "Intelligence": 0.01,
        "Technology": 0.1,
        "Survival": 0.5,
    },
    "Moderate": {
        "Abiogenesis": 0.1,
        "Complex Life": 0.01,
        "Intelligence": 1e-3,
        "Technology": 0.01,
        "Survival": 0.1,
    },
    "Conservative": {
        "Abiogenesis": 0.01,
        "Complex Life": 1e-3,
        "Intelligence": 1e-5,
        "Technology": 1e-3,
        "Survival": 0.01,
    },
    "Pessimistic": {
        "Abiogenesis": 1e-3,
        "Complex Life": 1e-4,
        "Intelligence": 1e-7,
        "Technology": 1e-4,
        "Survival": 1e-3,
    },
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

bar_colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']

for idx, (scenario_name, factors) in enumerate(scenarios.items()):
    ax = axes[idx]
    names = list(factors.keys())
    probs = list(factors.values())
    strengths = [-np.log10(p) for p in probs]
    total = sum(strengths)
    bottleneck_idx = np.argmax(strengths)
    
    colors_list = [bar_colors[i] if i != bottleneck_idx else '#FF0000' for i in range(len(names))]
    
    bars = ax.barh(names, strengths, color=colors_list, edgecolor='black', linewidth=0.5)
    
    # Mark bottleneck
    ax.barh(names[bottleneck_idx], strengths[bottleneck_idx],
            color='#FF0000', edgecolor='black', linewidth=2, hatch='///')
    
    # Add value labels
    for i, (s, p) in enumerate(zip(strengths, probs)):
        ax.text(s + 0.1, i, f'{s:.1f} ({p:.0e})', va='center', fontsize=9)
    
    # Total line
    ax.axvline(x=total/len(names), color='gray', linestyle='--', alpha=0.5)
    
    ax.set_xlabel('Filter Strength (-log₁₀ p)', fontsize=11)
    ax.set_title(f'{scenario_name}\nTotal: {total:.1f} | Bottleneck: {names[bottleneck_idx]}',
                 fontsize=12, fontweight='bold')
    ax.set_xlim(0, max(strengths) * 1.5)

fig.suptitle('Tropical Bottleneck Analysis of the Great Filter\n'
             'Red hatched bar = dominant filter (tropical maximum)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_tropical_bottleneck.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_bottleneck.png")
