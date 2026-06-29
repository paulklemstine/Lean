import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def round_loser(active, scores):
    return min(active, key=lambda i: scores[i])

def elimination_gap_certificate(active, scores):
    active = list(active)
    min_gap = float('inf')
    while len(active) > 1:
        loser = round_loser(active, scores)
        gap = min(scores[j] - scores[loser] for j in active if j != loser)
        min_gap = min(min_gap, gap)
        active.remove(loser)
    return min_gap

# Sweep over 2D score configurations for 3 candidates
# Fix candidate 0 at score 0, candidate 2 at score 10
# Vary candidates 1's score (x-axis) and perturbation epsilon (y-axis)
s1_vals = np.linspace(0.1, 9.9, 100)
eps_vals = np.linspace(0.0, 5.0, 100)
stable = np.zeros((len(eps_vals), len(s1_vals)))

for i, s1 in enumerate(s1_vals):
    scores = [0.0, s1, 10.0]
    gamma = elimination_gap_certificate([0, 1, 2], scores)
    for j, eps in enumerate(eps_vals):
        stable[j, i] = 1.0 if 2 * eps < gamma else 0.0

fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(stable, extent=[0.1, 9.9, 5.0, 0.0], aspect='auto',
               cmap='RdYlGn', vmin=0, vmax=1)
ax.set_xlabel('Score of candidate 1 (candidates 0=0, 2=10)', fontsize=12)
ax.set_ylabel('Perturbation magnitude ε', fontsize=12)
ax.set_title('Certified Stability Region for 3-Candidate IRV', fontsize=14)
cbar = plt.colorbar(im, ax=ax, ticks=[0, 1])
cbar.set_ticklabels(['Unstable', 'Certified Stable'])
plt.tight_layout()
plt.savefig('robustness_heatmap.png', dpi=150)
print('Saved robustness_heatmap.png')