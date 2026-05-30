"""
Visualization: Surprise-Entropy Duality
=========================================
Shows the MAD ≤ σ inequality (Mean Absolute Deviation ≤ Standard Deviation)
across different probability distributions, demonstrating that average
surprise is always bounded by uncertainty.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: MAD vs σ across distribution shapes ---
ax = axes[0]
ax.set_title("MAD ≤ σ Across Distributions", fontsize=12, fontweight='bold')

np.random.seed(42)
distributions = {
    'Uniform': np.random.uniform(0, 10, 1000),
    'Normal': np.random.normal(5, 2, 1000),
    'Exponential': np.random.exponential(3, 1000),
    'Bimodal': np.concatenate([np.random.normal(2, 0.5, 500),
                                np.random.normal(8, 0.5, 500)]),
    'Heavy-tailed': np.random.standard_t(3, 1000) * 2 + 5,
    'Concentrated': np.concatenate([np.full(900, 5.0), 
                                     np.random.uniform(0, 10, 100)]),
}

mads, sigmas, names = [], [], []
for name, data in distributions.items():
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    mads.append(mad)
    sigmas.append(sigma)
    names.append(name)

ax.scatter(sigmas, mads, c=['#e74c3c', '#3498db', '#27ae60', 
                             '#8e44ad', '#f39c12', '#1abc9c'],
           s=120, zorder=5, edgecolors='black', linewidth=0.5)

for i, name in enumerate(names):
    ax.annotate(name, (sigmas[i], mads[i]), textcoords="offset points",
                xytext=(8, 5), fontsize=8)

# Plot the y=x line (boundary)
max_val = max(max(mads), max(sigmas)) * 1.1
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='MAD = σ')
ax.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                alpha=0.1, color='red', label='Forbidden (MAD > σ)')
ax.fill_between([0, max_val], [0, 0], [0, max_val],
                alpha=0.1, color='green', label='Achievable (MAD ≤ σ)')

ax.set_xlabel("Standard Deviation (σ)", fontsize=11)
ax.set_ylabel("Mean Absolute Deviation (MAD)", fontsize=11)
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(0, max_val)
ax.set_ylim(0, max_val)
ax.grid(True, alpha=0.3)

# --- Panel 2: How sample size affects the bound tightness ---
ax2 = axes[1]
ax2.set_title("Bound Tightness vs Sample Size", fontsize=12, fontweight='bold')

sample_sizes = list(range(2, 201))
ratios_normal = []
ratios_uniform = []

for n in sample_sizes:
    # Normal distribution
    data = np.random.normal(0, 1, n)
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    ratios_normal.append(mad / sigma if sigma > 1e-10 else 0)
    
    # Uniform distribution
    data = np.random.uniform(0, 1, n)
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    ratios_uniform.append(mad / sigma if sigma > 1e-10 else 0)

ax2.plot(sample_sizes, ratios_normal, '-', color='#3498db', 
         alpha=0.7, label='Normal', linewidth=1)
ax2.plot(sample_sizes, ratios_uniform, '-', color='#e74c3c',
         alpha=0.7, label='Uniform', linewidth=1)
ax2.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='MAD = σ bound')
ax2.axhline(y=np.sqrt(2/np.pi), color='#27ae60', linestyle=':',
            alpha=0.7, label=f'√(2/π) ≈ {np.sqrt(2/np.pi):.3f} (Normal limit)')

ax2.set_xlabel("Sample Size (n)", fontsize=11)
ax2.set_ylabel("MAD / σ Ratio", fontsize=11)
ax2.legend(fontsize=8)
ax2.set_ylim(0, 1.2)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Distribution shape vs MAD/σ ratio ---
ax3 = axes[2]
ax3.set_title("Distribution Shape Determines\nSurprise/Uncertainty Ratio", 
              fontsize=12, fontweight='bold')

# Generate distributions with varying kurtosis
n_samples = 10000
beta_params = [(0.5, 0.5), (1, 1), (2, 2), (5, 5), (1, 3), (0.5, 2)]
labels_beta = ['U-shaped\n(β=0.5,0.5)', 'Uniform\n(β=1,1)', 
               'Bell\n(β=2,2)', 'Peaked\n(β=5,5)',
               'Skewed\n(β=1,3)', 'J-shaped\n(β=0.5,2)']
colors = ['#e74c3c', '#f39c12', '#3498db', '#27ae60', '#8e44ad', '#1abc9c']

ratios = []
for a, b in beta_params:
    data = np.random.beta(a, b, n_samples)
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    ratios.append(mad / sigma)

bars = ax3.bar(range(len(ratios)), ratios, color=colors, 
               edgecolor='black', linewidth=0.5, alpha=0.8)
ax3.set_xticks(range(len(ratios)))
ax3.set_xticklabels(labels_beta, fontsize=8)
ax3.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='Upper bound')
ax3.set_ylabel("MAD / σ Ratio", fontsize=11)
ax3.set_ylim(0, 1.1)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

# Add ratio values on bars
for i, (bar, ratio) in enumerate(zip(bars, ratios)):
    ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
             f'{ratio:.3f}', ha='center', fontsize=8, fontweight='bold')

plt.suptitle("Surprise-Entropy Duality: Average Surprise ≤ Uncertainty",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("surprise_entropy.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: surprise_entropy.png")
