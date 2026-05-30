#!/usr/bin/env python3
"""
Visualization: Convergence Rate Comparison

Compares natural gradient descent vs standard gradient descent convergence
on strongly convex quadratics with varying condition numbers.

Shows that natural gradient convergence is independent of the condition number,
while standard gradient convergence degrades linearly with κ.
"""

import numpy as np
import matplotlib.pyplot as plt

def nat_grad_bound(delta0, d, T_arr):
    return delta0 * np.exp(-T_arr / d)

def gd_bound(delta0, kappa, T_arr):
    return delta0 * (1 - 1/kappa)**T_arr

def run_gd(A, b, x0, eta, n_steps):
    x = x0.copy()
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    gaps = []
    for _ in range(n_steps + 1):
        f_val = 0.5 * x @ A @ x - b @ x
        gaps.append(f_val - f_opt)
        grad = A @ x - b
        x = x - eta * grad
    return np.array(gaps)

def run_ng(A, b, x0, eta, n_steps):
    x = x0.copy()
    G_inv = np.linalg.inv(A)
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    gaps = []
    for _ in range(n_steps + 1):
        f_val = 0.5 * x @ A @ x - b @ x
        gaps.append(f_val - f_opt)
        grad = A @ x - b
        x = x - eta * G_inv @ grad
    return np.array(gaps)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

d = 10
n_steps = 150
kappas = [5, 50, 500]
colors_gd = ['#e74c3c', '#c0392b', '#922b21']
colors_ng = ['#2ecc71', '#27ae60', '#1e8449']

T = np.arange(n_steps + 1)
b = np.ones(d)
x0 = np.zeros(d)

# Panel 1: Actual convergence curves
ax = axes[0]
for i, kappa in enumerate(kappas):
    eigenvalues = np.linspace(1, kappa, d)
    A = np.diag(eigenvalues)
    
    gaps_gd = run_gd(A, b, x0, 1.0/kappa, n_steps)
    gaps_ng = run_ng(A, b, x0, 1.0, n_steps)
    
    ax.semilogy(T, np.maximum(gaps_gd, 1e-16), color=colors_gd[i], 
                linestyle='--', label=f'GD κ={kappa}', alpha=0.8)
    ax.semilogy(T, np.maximum(gaps_ng, 1e-16), color=colors_ng[i], 
                linestyle='-', label=f'NG κ={kappa}', alpha=0.8, linewidth=2)

ax.set_xlabel('Iteration T', fontsize=12)
ax.set_ylabel('Optimality Gap L(θ_T) - L*', fontsize=12)
ax.set_title('Convergence: Natural vs Standard GD', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, loc='upper right')
ax.set_ylim(1e-16, 1e2)
ax.grid(True, alpha=0.3)

# Panel 2: Theoretical bounds
ax = axes[1]
delta0 = 0.5 * np.sum(b**2)  # approximate initial gap

for i, kappa in enumerate(kappas):
    bound_gd = gd_bound(delta0, kappa, T.astype(float))
    bound_ng = nat_grad_bound(delta0, d, T.astype(float))
    
    ax.semilogy(T, bound_gd, color=colors_gd[i], linestyle='--', 
                label=f'GD bound κ={kappa}', alpha=0.8)

ax.semilogy(T, nat_grad_bound(delta0, d, T.astype(float)), color='#2ecc71', 
            linestyle='-', label=f'NG bound (all κ)', linewidth=3)

ax.set_xlabel('Iteration T', fontsize=12)
ax.set_ylabel('Theoretical Upper Bound', fontsize=12)
ax.set_title('Theoretical Bounds (Proved)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(1e-16, 1e2)
ax.grid(True, alpha=0.3)

# Panel 3: Speedup factor vs condition number
ax = axes[2]
kappa_range = np.logspace(0, 4, 100)
T_values = [20, 50, 100]

for T_val in T_values:
    speedup = (1 - 1/kappa_range)**T_val / np.exp(-T_val/d)
    ax.loglog(kappa_range, speedup, linewidth=2, label=f'T={T_val}')

ax.set_xlabel('Condition Number κ', fontsize=12)
ax.set_ylabel('GD/NG Bound Ratio', fontsize=12)
ax.set_title('Speedup: NG over GD', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

plt.tight_layout()
plt.savefig('convergence_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence_comparison.png")
