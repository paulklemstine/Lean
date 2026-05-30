"""
Visualization: The Nash Support Lemma (Indifference Principle)
===============================================================

This script illustrates the support lemma: in a Nash equilibrium,
every strategy played with positive probability must yield the same
expected payoff (indifference). This is visualized as a payoff
landscape where the equilibrium sits at an intersection of payoff
surfaces.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def compute_payoffs_3strategy(p_rock, p_paper, payoff_matrix):
    """Compute expected payoffs for each pure strategy in RPS-like game.
    
    p_rock, p_paper: opponent's mixing probabilities
    p_scissors = 1 - p_rock - p_paper
    """
    p_scissors = 1 - p_rock - p_paper
    opponent = np.array([p_rock, p_paper, p_scissors])
    
    payoff_rock = payoff_matrix[0] @ opponent
    payoff_paper = payoff_matrix[1] @ opponent
    payoff_scissors = payoff_matrix[2] @ opponent
    
    return payoff_rock, payoff_paper, payoff_scissors


# RPS payoff matrix for Player 1
rps_matrix = np.array([
    [0, -1, 1],   # Rock
    [1, 0, -1],   # Paper
    [-1, 1, 0]    # Scissors
], dtype=float)

fig = plt.figure(figsize=(16, 6))

# --- Panel 1: Payoff surfaces in 2D simplex ---
ax1 = fig.add_subplot(131)

# Sample the 2-simplex
n_grid = 100
p_rocks = []
p_papers = []
payoff_R = []
payoff_P = []
payoff_S = []

for i in range(n_grid + 1):
    for j in range(n_grid + 1 - i):
        pr = i / n_grid
        pp = j / n_grid
        ps = 1 - pr - pp
        if ps >= -1e-10:
            p_rocks.append(pr)
            p_papers.append(pp)
            r, p, s = compute_payoffs_3strategy(pr, pp, rps_matrix)
            payoff_R.append(r)
            payoff_P.append(p)
            payoff_S.append(s)

p_rocks = np.array(p_rocks)
p_papers = np.array(p_papers)

# Best response regions
br_colors = []
for r, p, s in zip(payoff_R, payoff_P, payoff_S):
    vals = [r, p, s]
    mx = max(vals)
    if abs(r - mx) < 0.01 and abs(p - mx) < 0.01 and abs(s - mx) < 0.01:
        br_colors.append('#2ecc71')  # All equal (Nash)
    elif r == mx and p == mx:
        br_colors.append('#f39c12')
    elif r == mx and s == mx:
        br_colors.append('#f39c12')
    elif p == mx and s == mx:
        br_colors.append('#f39c12')
    elif r == mx:
        br_colors.append('#e74c3c')
    elif p == mx:
        br_colors.append('#3498db')
    else:
        br_colors.append('#9b59b6')

ax1.scatter(p_rocks, p_papers, c=br_colors, s=3, alpha=0.7)
ax1.plot(1/3, 1/3, '*', color='gold', markersize=20, zorder=10,
         markeredgecolor='black', markeredgewidth=1.5)

ax1.set_xlabel("Pr(Rock)", fontsize=11)
ax1.set_ylabel("Pr(Paper)", fontsize=11)
ax1.set_title("Best Response Regions\n(Rock-Paper-Scissors)", fontsize=12, fontweight='bold')

from matplotlib.lines import Line2D
legend1 = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#e74c3c', markersize=8, label='BR: Rock'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#3498db', markersize=8, label='BR: Paper'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#9b59b6', markersize=8, label='BR: Scissors'),
    Line2D([0], [0], marker='*', color='w', markerfacecolor='gold', markersize=12,
           markeredgecolor='black', label='Nash (1/3, 1/3, 1/3)'),
]
ax1.legend(handles=legend1, fontsize=8, loc='upper right')

# --- Panel 2: Payoff cross-section ---
ax2 = fig.add_subplot(132)

# Fix opponent at Nash (1/3, 1/3, 1/3) and vary player 1's strategy along a line
ts = np.linspace(0, 1, 200)
devs_R = []
devs_P = []
devs_S = []
expected = []

opp = np.array([1/3, 1/3, 1/3])
for t in ts:
    # Strategy: t*Rock + (1-t)/2*Paper + (1-t)/2*Scissors
    p1 = np.array([t, (1-t)/2, (1-t)/2])
    
    devs_R.append(rps_matrix[0] @ opp)
    devs_P.append(rps_matrix[1] @ opp)
    devs_S.append(rps_matrix[2] @ opp)
    expected.append(p1 @ rps_matrix @ opp)

ax2.plot(ts, devs_R, '-', color='#e74c3c', linewidth=2.5, label='Payoff: Rock')
ax2.plot(ts, devs_P, '-', color='#3498db', linewidth=2.5, label='Payoff: Paper')
ax2.plot(ts, devs_S, '-', color='#9b59b6', linewidth=2.5, label='Payoff: Scissors')
ax2.plot(ts, expected, '--', color='black', linewidth=2, label='Expected payoff')

ax2.axvline(x=1/3, color='gold', linestyle=':', linewidth=2, alpha=0.7)
ax2.annotate('Nash\nequilibrium', xy=(1/3, 0), xytext=(0.55, 0.15),
            fontsize=10, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'))

ax2.set_xlabel('Pr(Rock) — varying along simplex path', fontsize=11)
ax2.set_ylabel('Payoff', fontsize=11)
ax2.set_title('Support Lemma:\nAll BR payoffs equal at Nash', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Regret landscape ---
ax3 = fig.add_subplot(133)

n = 50
p1_vals = np.linspace(0.01, 0.99, n)
p2_vals = np.linspace(0.01, 0.99, n)
P1, P2 = np.meshgrid(p1_vals, p2_vals)

# Matching pennies regret landscape
regret_grid = np.zeros_like(P1)
for i in range(n):
    for j in range(n):
        p1, p2 = P1[i, j], P2[i, j]
        # Player 1: [[1,-1],[-1,1]]
        # Player 2: [[-1,1],[1,-1]]
        ep1 = p1*p2 - p1*(1-p2) - (1-p1)*p2 + (1-p1)*(1-p2)
        dev1_h = 2*p2 - 1
        dev1_t = 1 - 2*p2
        r1 = max(dev1_h - ep1, dev1_t - ep1, 0)
        
        ep2 = -ep1
        dev2_h = -2*p1 + 1
        dev2_t = 2*p1 - 1
        r2 = max(dev2_h - ep2, dev2_t - ep2, 0)
        
        regret_grid[i, j] = max(r1, r2)

contour = ax3.contourf(P1, P2, regret_grid, levels=20, cmap='RdYlGn_r')
plt.colorbar(contour, ax=ax3, label='Max Regret')
ax3.contour(P1, P2, regret_grid, levels=[0.01, 0.05, 0.1, 0.2, 0.5], 
            colors='white', linewidths=0.5, alpha=0.5)

ax3.plot(0.5, 0.5, '*', color='gold', markersize=15, zorder=10,
         markeredgecolor='black', markeredgewidth=1.5)
ax3.set_xlabel('Player 1: Pr(Heads)', fontsize=11)
ax3.set_ylabel('Player 2: Pr(Heads)', fontsize=11)
ax3.set_title('Regret Landscape\n(Matching Pennies)', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_support_lemma.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_support_lemma.png")
