"""
Visualization 3: The K-Fold Hierarchy as Nested Regions

Visualizes the nesting structure of the k-fold DLC classes:
  0-fold ⊃ 1-fold ⊃ 2-fold ⊃ 3-fold ⊃ ...

Uses a parameter space where each point represents a valuated matroid
(parameterized by two weights), and colors indicate the maximum depth.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial


def parameterized_valuation(m, alpha, beta, degree=4):
    """
    A 2-parameter family of valuated matroids on Fin 3 -> Z.
    f(m) = C(d; m) * alpha^{m_0 * m_1} * beta^{m_1 * m_2}
    """
    n = 3
    if any(x < 0 for x in m) or len(m) != n or sum(m) != degree:
        return 0.0
    c = factorial(degree) / np.prod([factorial(int(x)) for x in m])
    return c * (alpha ** (m[0] * m[1])) * (beta ** (m[1] * m[2]))


def check_depth(alpha, beta, degree=4, max_k=5):
    """Check k-fold DLC depth for given parameters."""
    n = 3
    points = [m for m in generate_degree_points(n, degree)]
    
    f = lambda m: parameterized_valuation(m, alpha, beta, degree)
    
    # Check positivity
    for m in points:
        if f(m) <= 0:
            return 0
    
    current_f = f
    for k in range(max_k):
        # Check all-direction LC
        all_lc = True
        for direction in range(n):
            for m in points:
                e = [0] * n
                e[direction] = 1
                m1 = tuple(m[j] + e[j] for j in range(n))
                m2 = tuple(m[j] + 2*e[j] for j in range(n))
                fm = current_f(tuple(m))
                fm1 = current_f(m1)
                fm2 = current_f(m2)
                if fm > 1e-12 and fm2 > 1e-12:
                    if fm1**2 < fm * fm2 - 1e-10:
                        all_lc = False
                        break
            if not all_lc:
                break
        
        if not all_lc:
            return k
        
        # Apply ratio transform
        prev_f = current_f
        current_f = lambda m, pf=prev_f: (
            pf(tuple(list(m[:0]) + [m[0]+1] + list(m[1:]))) / pf(m)
            if pf(m) != 0 else 0
        )
    
    return max_k


def generate_degree_points(n, degree):
    """Generate all nonneg integer points of given degree."""
    if n == 1:
        yield (degree,)
        return
    for k in range(degree + 1):
        for rest in generate_degree_points(n - 1, degree - k):
            yield (k,) + rest


# Compute depth map
resolution = 50
alphas = np.linspace(0.3, 3.0, resolution)
betas = np.linspace(0.3, 3.0, resolution)
depth_map = np.zeros((resolution, resolution))

for i, alpha in enumerate(alphas):
    for j, beta in enumerate(betas):
        depth_map[j, i] = check_depth(alpha, beta, degree=4, max_k=5)

# Create visualization
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Depth heatmap
cmap = plt.cm.get_cmap('viridis', 6)
im = ax1.imshow(depth_map, extent=[alphas[0], alphas[-1], betas[0], betas[-1]],
                origin='lower', aspect='auto', cmap=cmap, vmin=0, vmax=5)
ax1.set_xlabel('Weight parameter α', fontsize=12)
ax1.set_ylabel('Weight parameter β', fontsize=12)
ax1.set_title('Lorentzian Depth Map\nof Parameterized Valuated Matroids', fontsize=13)
cbar = plt.colorbar(im, ax=ax1, ticks=range(6))
cbar.set_label('K-fold DLC Depth', fontsize=11)

# Mark the uniform case (alpha=beta=1)
ax1.plot(1, 1, 'w*', markersize=15, markeredgecolor='black', markeredgewidth=1.5)
ax1.annotate('Uniform\nmatroid', xy=(1, 1), xytext=(1.5, 0.5),
            arrowprops=dict(arrowstyle='->', color='white', lw=2),
            fontsize=10, color='white', fontweight='bold')

# Contour plot showing depth boundaries
contour = ax2.contourf(alphas, betas, depth_map, levels=range(7), cmap=cmap)
ax2.contour(alphas, betas, depth_map, levels=range(7), colors='black', linewidths=0.5)
ax2.set_xlabel('Weight parameter α', fontsize=12)
ax2.set_ylabel('Weight parameter β', fontsize=12)
ax2.set_title('Nested Depth Regions\n$D_0 ⊃ D_1 ⊃ D_2 ⊃ D_3 ⊃ ...$', fontsize=13)
plt.colorbar(contour, ax=ax2, ticks=range(6), label='K-fold DLC Depth')

# Mark boundaries
ax2.plot(1, 1, 'w*', markersize=15, markeredgecolor='black', markeredgewidth=1.5)

plt.suptitle('The K-Fold Log-Concavity Hierarchy\nA New Invariant for Valuated Matroids',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hierarchy_regions.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved hierarchy_regions.png")
