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

scores = [1.0, 4.0, 6.0, 10.0]
candidates = [0, 1, 2, 3]
gamma = elimination_gap_certificate(candidates, scores)

eps_range = np.linspace(0, gamma, 200)
residual = gamma - 2 * eps_range

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(eps_range, residual, 'b-', linewidth=2, label='Residual gap γ − 2ε')
ax.axhline(y=0, color='r', linestyle='--', linewidth=1, label='Stability threshold')
ax.axvline(x=gamma/2, color='orange', linestyle=':', linewidth=1.5,
           label=f'Critical ε* = γ/2 = {gamma/2:.1f}')
ax.fill_between(eps_range, residual, 0, where=(residual > 0),
                alpha=0.15, color='green', label='Certified stable region')
ax.fill_between(eps_range, residual, 0, where=(residual <= 0),
                alpha=0.15, color='red', label='Uncertified region')
ax.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax.set_ylabel('Residual gap', fontsize=12)
ax.set_title(f'Gap Certificate Analysis (γ = {gamma:.1f})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('gap_vs_perturbation.png', dpi=150)
print('Saved gap_vs_perturbation.png')