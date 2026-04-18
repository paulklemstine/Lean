"""Demo 9: EML as Optimal Transport Cost

Visualizes the EML cost function c(x,y) = exp(x) - ln(y) for optimal transport,
including cost matrices, transport plans, and Kantorovich potentials.
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linear_sum_assignment

def eml_cost(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Cost matrix
n = 20
x_source = np.linspace(-1, 2, n)
y_target = np.linspace(0.5, 5, n)
C = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        C[i, j] = eml_cost(x_source[i], y_target[j])

im = axes[0,0].imshow(C, cmap='YlOrRd', aspect='auto',
                       extent=[y_target[0], y_target[-1], x_source[-1], x_source[0]])
plt.colorbar(im, ax=axes[0,0], label='c(x,y) = exp(x) - ln(y)')
axes[0,0].set_xlabel('y (target)'); axes[0,0].set_ylabel('x (source)')
axes[0,0].set_title('EML Transport Cost Matrix')

# Plot 2: Optimal assignment
row_ind, col_ind = linear_sum_assignment(C)
axes[0,1].scatter(x_source, np.zeros(n), c='blue', s=50, label='Source', zorder=5)
axes[0,1].scatter(y_target, np.ones(n), c='red', s=50, label='Target', zorder=5)
for i, j in zip(row_ind, col_ind):
    axes[0,1].plot([x_source[i], y_target[j]], [0, 1], 'k-', alpha=0.3, linewidth=0.5)
axes[0,1].set_xlabel('Position')
axes[0,1].set_title(f'Optimal Transport Map (total cost: {C[row_ind, col_ind].sum():.2f})')
axes[0,1].legend(); axes[0,1].set_yticks([0, 1], ['Source', 'Target'])

# Plot 3: Cost asymmetry c(x,y) vs c(y,x)
x_range = np.linspace(-1, 2, 100)
y_range = np.linspace(0.5, 3, 100)
X, Y = np.meshgrid(x_range, y_range)
asym = eml_cost(X, Y) - eml_cost(Y, X)

im2 = axes[1,0].pcolormesh(X, Y, asym, cmap='RdBu_r', shading='auto',
                             vmin=-5, vmax=5)
plt.colorbar(im2, ax=axes[1,0], label='c(x,y) - c(y,x)')
axes[1,0].set_xlabel('x'); axes[1,0].set_ylabel('y')
axes[1,0].set_title('EML Cost Asymmetry')

# Plot 4: Transport cost for Gaussian-like distributions
np.random.seed(42)
n_samples = 200
source = np.random.normal(0, 1, n_samples)
target = np.exp(np.random.normal(1, 0.5, n_samples))
target = np.sort(target)

# Simple nearest-neighbor transport
source_sorted = np.sort(source)
costs = [eml_cost(source_sorted[i], target[i]) for i in range(n_samples)]

axes[1,1].hist(costs, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
axes[1,1].axvline(x=np.mean(costs), color='red', linestyle='--',
                   label=f'Mean cost: {np.mean(costs):.2f}')
axes[1,1].set_xlabel('Individual transport cost')
axes[1,1].set_ylabel('Count')
axes[1,1].set_title('Distribution of Transport Costs')
axes[1,1].legend()

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/optimal_transport_v17.png', dpi=150)
plt.close()
print("Demo 9 complete: optimal_transport_v17.png")
