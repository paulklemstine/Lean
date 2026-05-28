"""
Visualization: Certified Robustness Regions

Shows the robustness certificate for topological events. For a given
weight function and target bar length L, the visualization displays:
1. The weight range (bar length) as a function of perturbation magnitude
2. The certified threshold below which the bar persists
3. Monte Carlo validation of the theoretical bound

This visualizes: long_bar_robust_under_weight_perturbation.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def merge_time(w):
    return float(np.max(w))

def min_critical_value(w):
    return float(np.min(w))

def weight_range(w):
    return merge_time(w) - min_critical_value(w)

def robustness_certificate(w, L):
    return max(0.0, weight_range(w) - L)


np.random.seed(42)

# Setup: weights with a clear persistent feature
w = np.array([1.0, 2.5, 3.0, 4.5, 6.0, 7.5, 9.0, 10.0])
m = len(w)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Weight range vs perturbation for multiple L
ax = axes[0]
L_values = [4.0, 6.0, 8.0]
colors = ['#4CAF50', '#FF9800', '#F44336']
eps_range = np.linspace(0, 3, 200)
n_trials = 500

for L, color in zip(L_values, colors):
    margin = robustness_certificate(w, L)
    certified_threshold = margin / 2

    # Monte Carlo: fraction of trials preserving the bar
    preservation = []
    for eps in eps_range:
        count = 0
        for _ in range(n_trials):
            noise = np.random.uniform(-eps, eps, m)
            if weight_range(w + noise) >= L:
                count += 1
        preservation.append(count / n_trials)

    ax.plot(eps_range, preservation, color=color, linewidth=2,
            label=f'L = {L} (margin = {margin:.1f})')
    if certified_threshold > 0:
        ax.axvline(x=certified_threshold, color=color, linestyle='--',
                   alpha=0.7, linewidth=1.5)

ax.set_xlabel('Perturbation ε', fontsize=12)
ax.set_ylabel('P(bar preserved)', fontsize=12)
ax.set_title('Bar Preservation Probability', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.1)

# Panel 2: Robustness margin as a function of L
ax = axes[1]
L_range = np.linspace(0, weight_range(w) + 1, 200)
margins = [robustness_certificate(w, L) for L in L_range]
safe_perts = [m / 2 for m in margins]

ax.fill_between(L_range, 0, safe_perts, alpha=0.3, color='#4CAF50',
                label='Certified safe region')
ax.plot(L_range, safe_perts, color='#4CAF50', linewidth=2.5)
ax.axvline(x=weight_range(w), color='red', linestyle=':', linewidth=1.5,
           label=f'Max bar = {weight_range(w):.1f}')
ax.set_xlabel('Target bar length L', fontsize=12)
ax.set_ylabel('Max safe perturbation δ/2', fontsize=12)
ax.set_title('Certified Safe Perturbation Region', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Weight filtration diagram
ax = axes[2]
sorted_w = np.sort(w)
n = len(sorted_w)

# Draw the filtration as horizontal bars
for i, wi in enumerate(sorted_w):
    ax.barh(i, wi, left=0, height=0.6, color='#2196F3', alpha=0.7)
    ax.text(wi + 0.15, i, f'{wi:.1f}', va='center', fontsize=9)

# Show the weight range
ax.annotate('', xy=(sorted_w[0], -0.8), xytext=(sorted_w[-1], -0.8),
            arrowprops=dict(arrowstyle='<->', color='red', lw=2.5))
ax.text((sorted_w[0] + sorted_w[-1]) / 2, -1.3,
        f'Range = {weight_range(w):.1f}', ha='center', fontsize=11,
        color='red', fontweight='bold')

ax.set_xlabel('Weight value', fontsize=12)
ax.set_ylabel('Edge index (sorted)', fontsize=12)
ax.set_title('Edge Weight Filtration', fontsize=13)
ax.set_xlim(-0.5, sorted_w[-1] + 1.5)
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Tropical Persistence: Certified Robustness',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_robustness.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_robustness.png")
