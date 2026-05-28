#!/usr/bin/env python3
"""
Visualization: Phase Diagram and Thermal Width Law

This script creates a phase diagram showing how the tropical and soft margins
vary as a structural parameter crosses a phase boundary. It also tests the
thermal width conjecture: the transition width scales as 1/β.

The visualization connects tropical geometry (sharp phase boundaries) to
statistical mechanics (thermal broadening) via the inverse temperature β.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]

def all_slacks(W):
    n = W.shape[0]
    return np.array([diag_ex_slack(W, i, j) for i in range(n) for j in range(n) if i != j])

def trop_margin(W):
    s = all_slacks(W)
    return float(np.min(s))

def soft_margin(beta, W):
    s = all_slacks(W)
    return -log_sum_exp(beta, -s)

def make_W(t, n=4):
    """1-parameter family crossing a phase boundary."""
    W = np.diag([2.0, 1.8, 1.6, 2.1])
    W[0, 1] = W[1, 0] = t
    W[0, 2] = W[2, 0] = 0.3
    W[0, 3] = W[3, 0] = 0.4
    W[1, 2] = W[2, 1] = 0.5
    W[1, 3] = W[3, 1] = 0.3
    W[2, 3] = W[3, 2] = 0.7
    return W

# Compute margin curves
ts = np.linspace(-0.5, 3.0, 500)
trop_margins = [trop_margin(make_W(t)) for t in ts]
betas = [1, 2, 5, 10, 20, 50]

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Left: Phase diagram
ax = axes[0]
ax.plot(ts, trop_margins, 'k-', linewidth=3, label='Tropical (β=∞)')
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(betas)))
for beta, color in zip(betas, colors):
    sms = [soft_margin(beta, make_W(t)) for t in ts]
    ax.plot(ts, sms, '-', linewidth=1.5, color=color, label=f'β={beta}')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Coupling parameter t', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title('Tropical Phase Diagram\nwith Thermal Smoothing', fontsize=14)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)

# Middle: Thermal broadening detail near crossing
t_star_idx = np.argmin(np.abs(trop_margins))
t_star = ts[t_star_idx]
window = 0.5
mask = (ts > t_star - window) & (ts < t_star + window)

ax = axes[1]
ax.plot(ts[mask], np.array(trop_margins)[mask], 'k-', linewidth=3, label='Tropical')
for beta, color in zip([2, 5, 10, 50], colors[1:5]):
    sms = [soft_margin(beta, make_W(t)) for t in ts[mask]]
    ax.plot(ts[mask], sms, '-', linewidth=2, color=color, label=f'β={beta}')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.axvline(x=t_star, color='red', linestyle='--', alpha=0.5, label=f't* ≈ {t_star:.2f}')
ax.set_xlabel('t (near phase boundary)', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title(f'Thermal Broadening\nnear t* ≈ {t_star:.2f}', fontsize=14)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Right: Thermal width vs 1/β
ax = axes[2]
widths = []
test_betas = np.logspace(np.log10(0.5), np.log10(100), 50)
for beta in test_betas:
    sms = np.array([soft_margin(beta, make_W(t)) for t in ts])
    diffs = np.abs(np.array(sms) - np.array(trop_margins))
    threshold = 0.05
    sig = np.where(diffs > threshold)[0]
    if len(sig) > 0:
        w = ts[sig[-1]] - ts[sig[0]]
    else:
        w = 0.0
    widths.append(w)

widths = np.array(widths)
products = test_betas * widths

ax.plot(test_betas, widths, 'b-', linewidth=2.5, label='Transition width')
ax.plot(test_betas, 2.0 / test_betas, 'r--', linewidth=2, label='Reference: 2/β')
ax.set_xlabel('β (inverse temperature)', fontsize=13)
ax.set_ylabel('Transition width', fontsize=13)
ax.set_title('Thermal Width Law:\nwidth ~ 1/β', fontsize=14)
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")
