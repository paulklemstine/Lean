#!/usr/bin/env python3
"""
Visualization: Lyapunov Certificate for Optimizer Convergence

Shows how the Lyapunov potential tracks and certifies convergence.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def optimizer(x: int) -> int:
    """Halving optimizer."""
    return x // 2

def complexity(x: int) -> int:
    return x

def lyapunov_potential(x: int) -> int:
    """V(x) = 2x — a valid Lyapunov certificate for the halving optimizer."""
    return 2 * x

# Generate trajectory
x = 500
steps_data = []
for step in range(30):
    x_new = optimizer(x)
    c_old, c_new = complexity(x), complexity(x_new)
    v_old, v_new = lyapunov_potential(x), lyapunov_potential(x_new)
    steps_data.append({
        'step': step,
        'state': x,
        'complexity': c_old,
        'potential': v_old,
        'dc': c_new - c_old,
        'dv': v_new - v_old,
    })
    if x_new == x:
        steps_data.append({
            'step': step + 1,
            'state': x_new,
            'complexity': c_new,
            'potential': v_new,
            'dc': 0,
            'dv': 0,
        })
        break
    x = x_new

fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(12, 12), sharex=True)
fig.suptitle('Lyapunov Convergence Certificate\nBoth Complexity and Potential Must Stabilize',
             fontsize=14, fontweight='bold')

steps = [d['step'] for d in steps_data]
complexities = [d['complexity'] for d in steps_data]
potentials = [d['potential'] for d in steps_data]
dc_vals = [d['dc'] for d in steps_data]

# Plot 1: Complexity
ax1.plot(steps, complexities, 'o-', color='#e74c3c', linewidth=2, markersize=6)
ax1.fill_between(steps, complexities, alpha=0.2, color='#e74c3c')
ax1.set_ylabel('Complexity C(p)', fontsize=12)
ax1.set_title('Complexity Trajectory', fontsize=12)
ax1.grid(True, alpha=0.3)

# Plot 2: Lyapunov potential
ax2.plot(steps, potentials, 's-', color='#3498db', linewidth=2, markersize=6)
ax2.fill_between(steps, potentials, alpha=0.2, color='#3498db')
ax2.set_ylabel('Potential V(p)', fontsize=12)
ax2.set_title('Lyapunov Potential (V = 2C)', fontsize=12)
ax2.grid(True, alpha=0.3)

# Plot 3: Changes
ax3.bar(steps, dc_vals, color=['#e74c3c' if d < 0 else '#2ecc71' for d in dc_vals],
        alpha=0.7, label='ΔC')
ax3.axhline(y=0, color='black', linewidth=0.5)
ax3.set_xlabel('Iteration Step', fontsize=12)
ax3.set_ylabel('Change in Complexity', fontsize=12)
ax3.set_title('Complexity Change per Step (negative = improvement)', fontsize=12)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('lyapunov_certificate.png', dpi=150, bbox_inches='tight')
print("Saved: lyapunov_certificate.png")
