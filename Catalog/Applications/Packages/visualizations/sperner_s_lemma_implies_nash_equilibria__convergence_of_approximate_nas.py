"""
Visualization: Convergence of Sperner-Based Approximate Nash Equilibria
========================================================================

This script visualizes how the quality of approximate Nash equilibria
improves as the triangulation mesh gets finer, demonstrating the
mesh refinement theorem: ε ≤ maxPayoff * (n*m) / meshSize.

Three games are compared: Matching Pennies, Rock-Paper-Scissors,
and Battle of the Sexes.
"""

import numpy as np
import matplotlib.pyplot as plt


def max_regret_grid(payoff1, payoff2, k):
    """Find the minimum max-regret over a k-grid of mixed strategies for a 2-player game."""
    m = payoff1.shape[0]
    
    # Generate lattice points on the (m-1)-simplex
    def simplex_points(dim, resolution):
        if dim == 1:
            return [np.array([1.0])]
        if dim == 2:
            return [np.array([i/resolution, 1 - i/resolution]) for i in range(resolution + 1)]
        points = []
        _gen(dim, resolution, [], points)
        return points
    
    def _gen(dim, res, partial, pts):
        if len(partial) == dim - 1:
            rem = res - sum(partial)
            if rem >= 0:
                coords = partial + [rem]
                pts.append(np.array(coords, dtype=float) / res)
            return
        rem = res - sum(partial)
        for v in range(rem + 1):
            _gen(dim, res, partial + [v], pts)
    
    pts = simplex_points(m, k)
    
    best_regret = float('inf')
    
    for p1 in pts:
        for p2 in pts:
            # Expected payoffs
            ep1 = p1 @ payoff1 @ p2
            ep2 = p1 @ payoff2 @ p2
            
            # Max regret
            regret = 0
            for a in range(m):
                e_a = np.zeros(m)
                e_a[a] = 1.0
                dev1 = e_a @ payoff1 @ p2 - ep1
                dev2 = p1 @ payoff2 @ e_a - ep2
                regret = max(regret, dev1, dev2)
            
            best_regret = min(best_regret, regret)
    
    return best_regret


# Define games
games = {
    'Matching Pennies': (
        np.array([[1, -1], [-1, 1]], dtype=float),
        np.array([[-1, 1], [1, -1]], dtype=float)
    ),
    'Rock-Paper-Scissors': (
        np.array([[0, -1, 1], [1, 0, -1], [-1, 1, 0]], dtype=float),
        np.array([[0, 1, -1], [-1, 0, 1], [1, -1, 0]], dtype=float)
    ),
    'Battle of Sexes': (
        np.array([[3, 0], [0, 2]], dtype=float),
        np.array([[2, 0], [0, 3]], dtype=float)
    )
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

mesh_sizes = [2, 3, 4, 6, 8, 10, 12, 16, 20]
colors = ['#e74c3c', '#3498db', '#2ecc71']
markers = ['o', 's', '^']

for idx, (name, (u1, u2)) in enumerate(games.items()):
    m = u1.shape[0]
    epsilons = []
    max_payoff = max(np.max(np.abs(u1)), np.max(np.abs(u2)))
    n = 2
    
    valid_ks = []
    for k in mesh_sizes:
        eps = max_regret_grid(u1, u2, k)
        epsilons.append(eps)
        valid_ks.append(k)
    
    ax1.plot(valid_ks, epsilons, f'-{markers[idx]}', color=colors[idx], 
             label=name, linewidth=2, markersize=8)
    
    # Theoretical bound
    bounds = [max_payoff * (n * m) / k for k in valid_ks]
    ax1.plot(valid_ks, bounds, f'--', color=colors[idx], alpha=0.4, linewidth=1.5)

ax1.set_xlabel('Mesh Size (k)', fontsize=12)
ax1.set_ylabel('ε (Maximum Regret)', fontsize=12)
ax1.set_title('Convergence to Nash Equilibrium', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.set_xscale('log')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=1e-16)

# Right panel: Complexity (simplices evaluated) vs accuracy
for idx, (name, (u1, u2)) in enumerate(games.items()):
    m = u1.shape[0]
    max_payoff = max(np.max(np.abs(u1)), np.max(np.abs(u2)))
    n = 2
    
    from math import comb
    complexities = []
    actual_eps = []
    
    for k in mesh_sizes:
        n_points = comb(k + m - 1, m - 1)
        complexity = n_points ** 2  # All pairs of lattice points
        eps = max_regret_grid(u1, u2, k)
        complexities.append(complexity)
        actual_eps.append(max(eps, 1e-16))
    
    ax2.plot(complexities, actual_eps, f'-{markers[idx]}', color=colors[idx],
             label=name, linewidth=2, markersize=8)

ax2.set_xlabel('Simplices Evaluated', fontsize=12)
ax2.set_ylabel('ε (Maximum Regret)', fontsize=12)
ax2.set_title('Accuracy vs Computational Cost', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xscale('log')
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=1e-16)

plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_convergence.png")
