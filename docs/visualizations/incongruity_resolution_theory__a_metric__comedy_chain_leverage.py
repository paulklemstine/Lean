"""
Visualization: Comedy Chain Leverage
======================================
Illustrates the Comedy Chain Leverage theorem: for a sequence of jokes,
the total transition distance (sum of surprises) is always at least
the endpoint distance. Longer, more meandering chains have higher leverage.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

np.random.seed(42)

# --- Panel 1: 2D comedy chains with different leverage ---
ax = axes[0]
ax.set_title("Comedy Chains in 2D Space", fontsize=12, fontweight='bold')

chains = {
    'Direct (low leverage)': [(0, 0), (1, 0.2), (2, 0.1), (3, 0.3), (4, 0)],
    'Zigzag (medium)': [(0, 0), (1, 2), (2, -1), (3, 2.5), (4, 0)],
    'Wild (high leverage)': [(0, 0), (-1, 3), (3, -2), (-2, 4), (4, 0)],
}

colors = ['#27ae60', '#f39c12', '#e74c3c']
for (name, chain), color in zip(chains.items(), colors):
    xs = [p[0] for p in chain]
    ys = [p[1] for p in chain]
    
    # Path length
    path = sum(np.sqrt((xs[i+1]-xs[i])**2 + (ys[i+1]-ys[i])**2) 
               for i in range(len(chain)-1))
    endpoint = np.sqrt((xs[-1]-xs[0])**2 + (ys[-1]-ys[0])**2)
    leverage = path / endpoint if endpoint > 0.01 else float('inf')
    
    ax.plot(xs, ys, 'o-', color=color, linewidth=2, markersize=6,
            label=f'{name}\nL={leverage:.1f}x')
    
    # Draw endpoint arrow
    ax.annotate('', xy=(xs[-1], ys[-1]-0.3), xytext=(xs[0], ys[0]-0.3),
                arrowprops=dict(arrowstyle='->', color=color, alpha=0.3, lw=2))

ax.set_xlabel("Semantic Dimension 1", fontsize=10)
ax.set_ylabel("Semantic Dimension 2", fontsize=10)
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# --- Panel 2: Leverage distribution for random chains ---
ax2 = axes[1]
ax2.set_title("Leverage Distribution\n(Random 10-point Chains)", fontsize=12, fontweight='bold')

n_chains = 5000
leverages = []

for _ in range(n_chains):
    # Random walk in 2D
    points = np.cumsum(np.random.randn(10, 2), axis=0)
    path_length = sum(np.linalg.norm(points[i+1] - points[i]) 
                      for i in range(len(points)-1))
    endpoint_dist = np.linalg.norm(points[-1] - points[0])
    if endpoint_dist > 0.01:
        leverages.append(path_length / endpoint_dist)

ax2.hist(leverages, bins=50, color='#3498db', alpha=0.7, edgecolor='black',
         linewidth=0.5, density=True)
ax2.axvline(x=1, color='#e74c3c', linestyle='--', linewidth=2, 
            label='Minimum (leverage = 1)')
ax2.axvline(x=np.mean(leverages), color='#27ae60', linestyle='-', linewidth=2,
            label=f'Mean = {np.mean(leverages):.2f}')

ax2.set_xlabel("Chain Leverage Ratio", fontsize=11)
ax2.set_ylabel("Density", fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Leverage vs chain length ---
ax3 = axes[2]
ax3.set_title("Leverage Grows with Chain Length", fontsize=12, fontweight='bold')

chain_lengths = list(range(2, 51))
mean_leverages = []
std_leverages = []

for n in chain_lengths:
    levs = []
    for _ in range(500):
        points = np.cumsum(np.random.randn(n, 2), axis=0)
        path_length = sum(np.linalg.norm(points[i+1] - points[i]) 
                          for i in range(n-1))
        endpoint_dist = np.linalg.norm(points[-1] - points[0])
        if endpoint_dist > 0.01:
            levs.append(path_length / endpoint_dist)
    mean_leverages.append(np.mean(levs) if levs else 1)
    std_leverages.append(np.std(levs) if levs else 0)

mean_leverages = np.array(mean_leverages)
std_leverages = np.array(std_leverages)

ax3.plot(chain_lengths, mean_leverages, 'b-', linewidth=2, label='Mean leverage')
ax3.fill_between(chain_lengths, 
                  mean_leverages - std_leverages,
                  mean_leverages + std_leverages,
                  alpha=0.2, color='blue', label='±1 std')
ax3.axhline(y=1, color='#e74c3c', linestyle='--', alpha=0.5, label='Minimum = 1')

# Theoretical: for random walk, E[path]/E[endpoint] ~ sqrt(n-1) * sqrt(pi/2) / ???
# Actually E[path] = (n-1) * E[step] and E[endpoint] ~ sqrt(n-1) * E[step]
# So leverage ~ sqrt(n-1) * const
sqrt_fit = np.sqrt(np.array(chain_lengths) - 1) * mean_leverages[0]
ax3.plot(chain_lengths, sqrt_fit, 'g:', linewidth=2, alpha=0.7,
         label=f'√(n-1) scaling')

ax3.set_xlabel("Chain Length (number of jokes)", fontsize=11)
ax3.set_ylabel("Mean Leverage Ratio", fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle("Comedy Chain Leverage: Longer Chains Amplify Narrative Distance",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("comedy_chain.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: comedy_chain.png")
