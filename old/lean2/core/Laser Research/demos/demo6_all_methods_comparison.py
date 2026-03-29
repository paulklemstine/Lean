#!/usr/bin/env python3
"""
DEMO 6: Grand Comparison of All Alternative Laser Methods
==========================================================
Comparative visualization of all six alternative laser creation
methods investigated in this research.

Run: python demo6_all_methods_comparison.py
Outputs: grand_comparison.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib.patches as patches

# ─── Method Data ───────────────────────────────────────────────────

methods = {
    'Random Laser': {
        'mechanism': 'Multiple scattering\nin disordered medium',
        'pump': 'External (LED/flash)',
        'color': 'crimson',
        'wavelength': 590,
        'coherence': 0.6,
        'power': 0.4,
        'cost': 0.8,
        'safety': 0.7,
        'novelty': 0.5,
        'hobbyist': 0.9,
    },
    'Sonoluminescence\nPumped': {
        'mechanism': 'Ultrasonic bubble\ncollapse → flash',
        'pump': 'Ultrasound',
        'color': 'purple',
        'wavelength': 580,
        'coherence': 0.4,
        'power': 0.2,
        'cost': 0.5,
        'safety': 0.8,
        'novelty': 0.9,
        'hobbyist': 0.6,
    },
    'Chemiluminescent': {
        'mechanism': 'Chemical reaction\nemits pump light',
        'pump': 'Chemistry',
        'color': 'forestgreen',
        'wavelength': 520,
        'coherence': 0.5,
        'power': 0.3,
        'cost': 0.9,
        'safety': 0.6,
        'novelty': 0.7,
        'hobbyist': 0.8,
    },
    'Bioluminescent': {
        'mechanism': 'Living organisms\nas gain medium',
        'pump': 'Biology / UV LED',
        'color': 'lime',
        'wavelength': 509,
        'coherence': 0.5,
        'power': 0.1,
        'cost': 0.6,
        'safety': 0.9,
        'novelty': 1.0,
        'hobbyist': 0.5,
    },
    'Triboluminescent': {
        'mechanism': 'Crystal fracture\nemits light',
        'pump': 'Mechanical force',
        'color': 'orange',
        'wavelength': 613,
        'coherence': 0.3,
        'power': 0.1,
        'cost': 0.9,
        'safety': 0.9,
        'novelty': 0.8,
        'hobbyist': 0.9,
    },
    'Nonlinear\nMixing': {
        'mechanism': 'Two beams create\nthird wavelength',
        'pump': 'Two laser diodes',
        'color': 'dodgerblue',
        'wavelength': 460,
        'coherence': 0.9,
        'power': 0.5,
        'cost': 0.3,
        'safety': 0.4,
        'novelty': 0.4,
        'hobbyist': 0.3,
    },
}

# ─── Visualization ─────────────────────────────────────────────────

fig = plt.figure(figsize=(20, 22))
gs = GridSpec(4, 2, figure=fig, hspace=0.35, wspace=0.3)
fig.suptitle("Grand Comparison: Six Alternative Methods of Laser Light Creation",
             fontsize=20, fontweight='bold', y=0.99)

# ── Panel 1: Radar chart comparison ──
ax1 = fig.add_subplot(gs[0, 0], polar=True)
categories = ['Coherence', 'Power', 'Cost\n(low=good)', 'Safety', 'Novelty', 'Hobbyist\nFriendly']
N_cats = len(categories)
angles = np.linspace(0, 2 * np.pi, N_cats, endpoint=False).tolist()
angles += angles[:1]

for name, props in methods.items():
    values = [props['coherence'], props['power'], props['cost'],
              props['safety'], props['novelty'], props['hobbyist']]
    values += values[:1]
    ax1.plot(angles, values, 'o-', linewidth=2, label=name.replace('\n', ' '),
             color=props['color'], markersize=5)
    ax1.fill(angles, values, alpha=0.05, color=props['color'])

ax1.set_xticks(angles[:-1])
ax1.set_xticklabels(categories, fontsize=9)
ax1.set_ylim(0, 1.1)
ax1.set_title('Multi-Criteria Radar Comparison', fontsize=13, pad=20)
ax1.legend(loc='upper right', bbox_to_anchor=(1.4, 1.1), fontsize=8)

# ── Panel 2: Wavelength coverage ──
ax2 = fig.add_subplot(gs[0, 1])
y_positions = range(len(methods))
names = list(methods.keys())
for i, (name, props) in enumerate(methods.items()):
    wl = props['wavelength']
    # Color bar representing emission bandwidth
    width = 30  # approximate bandwidth
    ax2.barh(i, width, left=wl - width/2, height=0.6,
             color=props['color'], alpha=0.7, edgecolor='black')
    ax2.text(wl, i, f'{wl} nm', ha='center', va='center',
             fontsize=9, fontweight='bold', color='white')

# Visible spectrum background
visible = np.linspace(380, 700, 1000)
for wl in visible:
    # Approximate wavelength to RGB
    if wl < 440:
        r, g, b = (440 - wl) / 60, 0, 1
    elif wl < 490:
        r, g, b = 0, (wl - 440) / 50, 1
    elif wl < 510:
        r, g, b = 0, 1, (510 - wl) / 20
    elif wl < 580:
        r, g, b = (wl - 510) / 70, 1, 0
    elif wl < 645:
        r, g, b = 1, (645 - wl) / 65, 0
    else:
        r, g, b = 1, 0, 0
    ax2.axvspan(wl - 0.5, wl + 0.5, alpha=0.08, color=(r, g, b))

ax2.set_yticks(list(y_positions))
ax2.set_yticklabels(names, fontsize=10)
ax2.set_xlabel('Wavelength (nm)', fontsize=11)
ax2.set_title('Emission Wavelength Coverage', fontsize=13)
ax2.set_xlim(380, 700)

# ── Panel 3: Cost vs Hobbyist Accessibility scatter ──
ax3 = fig.add_subplot(gs[1, 0])
for name, props in methods.items():
    cost_dollars = {0.3: 150, 0.5: 75, 0.6: 55, 0.8: 35, 0.9: 20}
    cost = cost_dollars.get(props['cost'], 50)
    ax3.scatter(cost, props['hobbyist'] * 10, s=300, c=props['color'],
                edgecolors='black', linewidth=1.5, zorder=5)
    ax3.annotate(name.replace('\n', ' '), (cost, props['hobbyist'] * 10),
                textcoords="offset points", xytext=(10, 5), fontsize=9)

ax3.set_xlabel('Estimated Cost ($)', fontsize=11)
ax3.set_ylabel('Hobbyist Accessibility Score (0-10)', fontsize=11)
ax3.set_title('Cost vs Accessibility\n(Top-left = Best for Hobbyists)', fontsize=13)
ax3.set_xlim(0, 200)
ax3.set_ylim(0, 11)

# Highlight sweet spot
sweet = patches.Rectangle((0, 6), 60, 5, facecolor='lightgreen',
                            alpha=0.2, edgecolor='green', linestyle='--', linewidth=2)
ax3.add_patch(sweet)
ax3.text(30, 10, 'Sweet Spot', fontsize=11, ha='center', color='green',
         fontweight='bold')

# ── Panel 4: Energy flow Sankey-style diagram ──
ax4 = fig.add_subplot(gs[1, 1])
ax4.set_xlim(0, 10)
ax4.set_ylim(0, 10)

# Energy sources on left
sources = [
    ('Chemical\nEnergy', 1.5, 'forestgreen'),
    ('Sound\nWaves', 3.5, 'purple'),
    ('Mechanical\nForce', 5.5, 'orange'),
    ('Biological\nMetabolism', 7.5, 'lime'),
]

for label, y, color in sources:
    ax4.text(0.5, y, label, fontsize=10, ha='center', va='center',
             bbox=dict(boxstyle='round', facecolor=color, alpha=0.3),
             fontweight='bold')
    ax4.annotate('', xy=(3.5, y), xytext=(1.5, y),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

# Central process
ax4.text(5, 4.5, 'Population\nInversion\n+\nOptical\nFeedback', fontsize=12,
         ha='center', va='center', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.8', facecolor='lightyellow',
                   edgecolor='gold', linewidth=3))

# All arrows converge
for _, y, color in sources:
    ax4.annotate('', xy=(3.8, 4.5), xytext=(3.5, y),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5, 
                               connectionstyle='arc3,rad=0.2'))

# Output
ax4.annotate('', xy=(9, 4.5), xytext=(6.5, 4.5),
            arrowprops=dict(arrowstyle='->', color='red', lw=4))
ax4.text(9, 4.5, '🔴\nCOHERENT\nLIGHT', fontsize=14, ha='center', va='center',
         fontweight='bold', color='red')

ax4.text(5, 9.5, 'Alternative Energy → Coherent Light Pathways', fontsize=13,
         ha='center', fontweight='bold')
ax4.axis('off')

# ── Panel 5: Technology Readiness Level ──
ax5 = fig.add_subplot(gs[2, 0])
trl_data = {
    'Random Laser': 7,
    'Sono-Pumped': 3,
    'Chemiluminescent': 4,
    'Bioluminescent': 5,
    'Triboluminescent': 2,
    'Nonlinear Mix': 6,
}
colors_trl = ['crimson', 'purple', 'forestgreen', 'lime', 'orange', 'dodgerblue']
bars = ax5.barh(list(trl_data.keys()), list(trl_data.values()),
                color=colors_trl, edgecolor='black', linewidth=1.5)

for bar, val in zip(bars, trl_data.values()):
    ax5.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
             f'TRL {val}', va='center', fontsize=10, fontweight='bold')

ax5.set_xlabel('Technology Readiness Level (1-9)', fontsize=11)
ax5.set_title('Technology Readiness Assessment', fontsize=13)
ax5.set_xlim(0, 9)

# TRL labels
trl_labels = {1: 'Basic\nresearch', 3: 'Proof of\nconcept',
              5: 'Lab\nvalidation', 7: 'Prototype', 9: 'Deployed'}
for trl, label in trl_labels.items():
    ax5.axvline(trl, color='gray', linestyle=':', alpha=0.3)
    ax5.text(trl, -0.8, label, fontsize=7, ha='center', color='gray')

# ── Panel 6: Innovation matrix ──
ax6 = fig.add_subplot(gs[2, 1])
for name, props in methods.items():
    ax6.scatter(props['novelty'] * 10, props['coherence'] * 10,
                s=props['hobbyist'] * 500, c=props['color'],
                edgecolors='black', linewidth=1.5, alpha=0.7, zorder=5)
    ax6.annotate(name.replace('\n', ' '),
                (props['novelty'] * 10, props['coherence'] * 10),
                textcoords="offset points", xytext=(10, 5), fontsize=9)

ax6.set_xlabel('Novelty Score (0-10)', fontsize=11)
ax6.set_ylabel('Coherence Quality (0-10)', fontsize=11)
ax6.set_title('Innovation vs Performance\n(Bubble size = Hobbyist Accessibility)', fontsize=13)
ax6.set_xlim(0, 11)
ax6.set_ylim(0, 11)

# Quadrant labels
ax6.text(8, 8, 'HIGH VALUE\nINNOVATION', fontsize=10, ha='center',
         color='green', alpha=0.5, fontweight='bold')
ax6.text(2, 2, 'INCREMENTAL', fontsize=10, ha='center',
         color='gray', alpha=0.5, fontweight='bold')

# ── Panel 7: Timeline and roadmap ──
ax7 = fig.add_subplot(gs[3, :])
ax7.set_xlim(0, 12)
ax7.set_ylim(0, 8)

# Timeline
ax7.plot([1, 11], [4, 4], 'k-', linewidth=3)

milestones = [
    (1, 'Week 1-2', 'Materials\nSourcing', 'lightblue'),
    (3, 'Week 3-4', 'Random Laser\nBuild & Test', 'crimson'),
    (5, 'Week 5-6', 'Chemiluminescent\nExperiments', 'forestgreen'),
    (7, 'Week 7-8', 'Tribo/Bio\nExperiments', 'orange'),
    (9, 'Week 9-10', 'Optimization\n& Measurement', 'purple'),
    (11, 'Week 11-12', 'Documentation\n& Sharing', 'gold'),
]

for x, label, desc, color in milestones:
    ax7.plot(x, 4, 'o', color=color, markersize=15, markeredgecolor='black',
             markeredgewidth=2, zorder=5)
    ax7.text(x, 4.8, label, fontsize=9, ha='center', fontweight='bold')
    ax7.text(x, 3, desc, fontsize=8, ha='center', color=color,
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.8,
                       edgecolor=color))

ax7.text(6, 7, 'Suggested Hobbyist Research Roadmap', fontsize=14,
         ha='center', fontweight='bold')
ax7.text(6, 6.2, '12-week plan to explore alternative laser creation at home',
         fontsize=11, ha='center', fontstyle='italic', color='gray')
ax7.axis('off')

plt.savefig('/workspace/request-project/laser_research/demos/grand_comparison.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Saved: grand_comparison.png")
