"""
Visualization: Coefficient Landscape of Lorentzian Polynomials

Visualizes how the coefficient inequalities create a geometric landscape:
- Heatmap of coefficient ratios for Lorentzian vs non-Lorentzian polynomials
- The "descent" structure from degree d down to degree 2
"""

import numpy as np
import matplotlib.pyplot as plt


def multi_indices(n: int, d: int):
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in multi_indices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def product_of_linear_forms(n, d, seed=None):
    rng = np.random.default_rng(seed)
    coeffs = {tuple(0 for _ in range(n)): 1.0}
    for _ in range(d):
        lc = rng.uniform(0.5, 3.0, size=n)
        new_coeffs = {}
        for alpha, c in coeffs.items():
            for var in range(n):
                na = list(alpha)
                na[var] += 1
                t = tuple(na)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * lc[var]
        coeffs = new_coeffs
    return coeffs, n, d


def compute_minor_ratios(coeffs, n, d):
    """Compute all mixed log-concavity ratios c(m+2ei)*c(m+2ej)/c(m+ei+ej)^2."""
    ratios = []
    if d < 2:
        return ratios
    for m in multi_indices(n, d - 2):
        for i in range(n):
            for j in range(i, n):
                ei = tuple(1 if k == i else 0 for k in range(n))
                ej = tuple(1 if k == j else 0 for k in range(n))
                m_ii = tuple(mk + 2*eik for mk, eik in zip(m, ei))
                m_jj = tuple(mk + 2*ejk for mk, ejk in zip(m, ej))
                m_ij = tuple(mk + eik + ejk for mk, eik, ejk in zip(m, ei, ej))
                c_ii = coeffs.get(m_ii, 0)
                c_jj = coeffs.get(m_jj, 0)
                c_ij = coeffs.get(m_ij, 0)
                if abs(c_ij) > 1e-15:
                    ratio = c_ii * c_jj / (c_ij**2)
                    ratios.append(ratio)
    return ratios


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Coefficient ratio histogram for Lorentzian polynomials
ax = axes[0, 0]
all_ratios_lor = []
for seed in range(50):
    coeffs, n, d = product_of_linear_forms(3, 4, seed=seed)
    ratios = compute_minor_ratios(coeffs, n, d)
    all_ratios_lor.extend(ratios)

all_ratios_rand = []
for seed in range(50):
    rng = np.random.default_rng(seed + 1000)
    indices = multi_indices(3, 4)
    coeffs = {idx: rng.uniform(0.1, 5.0) for idx in indices}
    ratios = compute_minor_ratios(coeffs, 3, 4)
    all_ratios_rand.extend(ratios)

ax.hist(all_ratios_lor, bins=50, range=(0, 3), alpha=0.6, color='#2ecc71',
        label='Lorentzian', density=True)
ax.hist(all_ratios_rand, bins=50, range=(0, 3), alpha=0.6, color='#e74c3c',
        label='Random', density=True)
ax.axvline(x=1, color='black', linestyle='--', linewidth=1.5,
           label='Boundary ($r = 1$)')
ax.set_xlabel('Ratio $c(m+2e_i)c(m+2e_j) / c(m+e_i+e_j)^2$', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title('Coefficient ratio distribution (n=3, d=4)', fontsize=12)
ax.legend(fontsize=10)

# Panel 2: Heatmap of coefficient matrix for a Lorentzian polynomial
ax = axes[0, 1]
coeffs, n, d = product_of_linear_forms(3, 4, seed=42)
indices = sorted(multi_indices(3, 4))
n_idx = len(indices)
idx_map = {idx: i for i, idx in enumerate(indices)}

coeff_vals = np.array([coeffs.get(idx, 0) for idx in indices])
coeff_vals = coeff_vals / np.max(coeff_vals)

# Create ratio matrix
ratio_matrix = np.ones((n_idx, n_idx))
for i_idx in range(n_idx):
    for j_idx in range(n_idx):
        c_i = coeffs.get(indices[i_idx], 0)
        c_j = coeffs.get(indices[j_idx], 0)
        # For visualization: compute product of coefficients
        ratio_matrix[i_idx, j_idx] = np.sqrt(c_i * c_j) if c_i > 0 and c_j > 0 else 0

ratio_matrix = ratio_matrix / np.max(ratio_matrix) if np.max(ratio_matrix) > 0 else ratio_matrix

im = ax.imshow(ratio_matrix, cmap='YlOrRd', aspect='auto')
ax.set_xlabel('Multi-index (lexicographic order)', fontsize=11)
ax.set_ylabel('Multi-index', fontsize=11)
ax.set_title('Coefficient correlation matrix\n(Lorentzian, n=3, d=4)', fontsize=12)
plt.colorbar(im, ax=ax, shrink=0.8)

# Panel 3: Descent structure — how ratios change across derivative levels
ax = axes[1, 0]
coeffs_orig, n, d = product_of_linear_forms(3, 5, seed=42)

class SimplePoly:
    def __init__(self, coeffs, n, d):
        self.coeffs = coeffs
        self.n = n
        self.d = d

    def partial_derivative(self, var):
        new_coeffs = {}
        for alpha, c in self.coeffs.items():
            if alpha[var] > 0:
                na = list(alpha)
                f = na[var]
                na[var] -= 1
                t = tuple(na)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * f
        return SimplePoly(new_coeffs, self.n, max(0, self.d - 1))

levels = []
current = SimplePoly(coeffs_orig, n, d)
for level in range(d - 1):
    ratios = compute_minor_ratios(current.coeffs, current.n, current.d)
    if ratios:
        levels.append((level, ratios))
    if current.d > 0:
        current = current.partial_derivative(0)  # Differentiate w.r.t. x_0

positions = []
data = []
labels = []
for level, ratios in levels:
    positions.append(level)
    data.append(ratios)
    labels.append(f'Level {level}\n(deg {d - level})')

if data:
    bp = ax.boxplot(data, positions=positions, widths=0.5,
                    patch_artist=True,
                    boxprops=dict(facecolor='#3498db', alpha=0.6),
                    medianprops=dict(color='darkblue', linewidth=2))
    ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5,
               label='Log-concavity boundary')
    ax.set_xlabel('Derivative level', fontsize=11)
    ax.set_ylabel('Coefficient ratio', fontsize=11)
    ax.set_title('Ratio descent across derivative levels\n(n=3, d=5)', fontsize=12)
    ax.set_xticks(positions)
    ax.set_xticklabels(labels, fontsize=9)
    ax.legend(fontsize=10)

# Panel 4: Support exchange connectivity
ax = axes[1, 1]
from itertools import combinations
n_viz = 4
d_viz = 2
indices = multi_indices(n_viz, d_viz)
n_nodes = len(indices)

# Draw support exchange graph
node_positions = {}
for i, idx in enumerate(indices):
    angle = 2 * np.pi * i / n_nodes
    node_positions[idx] = (np.cos(angle), np.sin(angle))

# Draw edges: connect α to β if they differ by a single exchange
edges = []
for alpha in indices:
    for beta in indices:
        for i_var in range(n_viz):
            if alpha[i_var] > beta[i_var]:
                for j_var in range(n_viz):
                    if beta[j_var] > alpha[j_var]:
                        exchanged = list(alpha)
                        exchanged[i_var] -= 1
                        exchanged[j_var] += 1
                        if tuple(exchanged) in node_positions:
                            edges.append((alpha, tuple(exchanged)))

# Draw edges
for a, b in edges:
    ax.plot([node_positions[a][0], node_positions[b][0]],
            [node_positions[a][1], node_positions[b][1]],
            'gray', alpha=0.3, linewidth=0.5)

# Draw nodes
for idx, (x, y) in node_positions.items():
    ax.plot(x, y, 'o', markersize=12, color='#3498db', zorder=5)
    label = ''.join(str(v) for v in idx)
    ax.annotate(label, (x, y), textcoords="offset points",
                xytext=(0, -18), ha='center', fontsize=8)

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title(f'Exchange support graph\n(n={n_viz}, d={d_viz})', fontsize=12)
ax.axis('off')

plt.suptitle('Hessian Descent: Coefficient Landscape of Lorentzian Polynomials',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_coefficient_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_coefficient_landscape.png")
