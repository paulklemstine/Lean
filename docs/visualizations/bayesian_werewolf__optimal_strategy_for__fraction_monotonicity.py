#!/usr/bin/env python3
"""
Visualization 3: Werewolf Fraction Monotonicity

Visualizes the two key monotonicity theorems proved in Lean:
1. Werewolf fraction increases when a villager is removed
2. Werewolf fraction decreases when a werewolf is removed

These theorems explain WHY the game gets progressively harder
for villagers: each mistake (eliminating a villager) makes future
mistakes more likely, creating a positive feedback loop.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Fraction increases as villagers are removed (fixed w)
ax1 = axes[0]
for w in [1, 2, 3, 4]:
    vs = list(range(w + 2, 20))
    fracs = [w / (w + v) for v in vs]
    ax1.plot(vs, fracs, 'o-', label=f'w={w}', linewidth=2, markersize=4)

ax1.set_xlabel('Villagers (v)', fontsize=12)
ax1.set_ylabel('Werewolf Fraction w/(w+v)', fontsize=12)
ax1.set_title('Wolf Fraction vs Villagers\n(Decreasing: removing villagers\nincreases wolf fraction)',
              fontsize=11, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.invert_xaxis()  # Show effect of removing villagers

# Panel 2: Game trajectory showing fraction evolution
ax2 = axes[1]
scenarios = [
    ("Perfect play", [(2, 5), (1, 4), (0, 3)], 'green'),
    ("All mistakes", [(2, 5), (2, 3), (2, 1)], 'red'),
    ("Mixed (1 correct, 1 wrong)", [(2, 5), (1, 4), (1, 2)], 'orange'),
]

for label, trajectory, color in scenarios:
    fracs = [w / (w + v) if w + v > 0 else 1.0 for w, v in trajectory]
    rounds = list(range(len(trajectory)))
    ax2.plot(rounds, fracs, 'o-', color=color, label=label,
             linewidth=2.5, markersize=8)
    for r, (w, v) in enumerate(trajectory):
        ax2.annotate(f'({w},{v})', (r, fracs[r]),
                    textcoords="offset points", xytext=(5, 10),
                    fontsize=8, color=color)

ax2.axhline(y=0.5, color='black', linestyle=':', linewidth=1.5,
            label='w=v (wolf win)')
ax2.set_xlabel('Round', fontsize=12)
ax2.set_ylabel('Werewolf Fraction', fontsize=12)
ax2.set_title('Game Trajectories (n=7, k=2)\n(States shown as (w,v))',
              fontsize=11, fontweight='bold')
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.05)

# Panel 3: The "vicious cycle" effect
ax3 = axes[2]
# Show how probability of correct elimination changes along paths
w_start, v_start = 2, 8
rounds_correct = []
rounds_incorrect = []
w, v = w_start, v_start

# Correct path
ws, vs = [w], [v]
while w > 0 and w < v and v > 1:
    w -= 1; v -= 1  # correct elimination + night kill
    ws.append(w); vs.append(v)
probs_correct = [wi / (wi + vi) if wi + vi > 0 else 0 for wi, vi in zip(ws, vs)]

# Incorrect path
w, v = w_start, v_start
ws2, vs2 = [w], [v]
while w > 0 and w < v and v > 2:
    v -= 2  # incorrect elimination + night kill (lose 2 villagers)
    ws2.append(w); vs2.append(v)
probs_incorrect = [wi / (wi + vi) if wi + vi > 0 else 0 for wi, vi in zip(ws2, vs2)]

ax3.plot(range(len(probs_correct)), probs_correct, 's-', color='green',
         label='Correct eliminations', linewidth=2.5, markersize=8)
ax3.plot(range(len(probs_incorrect)), probs_incorrect, 'D-', color='red',
         label='Incorrect eliminations', linewidth=2.5, markersize=8)

ax3.axhline(y=0.5, color='black', linestyle=':', linewidth=1.5)
ax3.fill_between(range(max(len(probs_correct), len(probs_incorrect))),
                 0.5, 1.0, alpha=0.1, color='red', label='Wolf win zone')

ax3.set_xlabel('Round', fontsize=12)
ax3.set_ylabel('P(correct next elimination)', fontsize=12)
ax3.set_title('The Vicious Cycle Effect\n(n=10, k=2)',
              fontsize=11, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 1.05)

plt.suptitle('Werewolf Fraction Monotonicity — Formally Verified',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_fraction_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved viz_fraction_monotonicity.png")
