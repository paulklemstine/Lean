#!/usr/bin/env python3
"""
Demo 1: The Emergence of Time from Iteration
=============================================

Oracle: Chronos (Time)
Question: How does time begin from timelessness?

This demo shows how temporal structure emerges from pure iteration:
1. Start with identity (no time, no change)
2. Introduce an infinitesimal perturbation
3. Iterate → continuous flow emerges
4. Entropy increases along the orbit → arrow of time

Run: python3 01_time_emergence.py
Output: ../figures/01_time_emergence.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap

# ─── Configuration ────────────────────────────────────────────────────────────
np.random.seed(42)  # The Answer
plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 11,
    'axes.titlesize': 13,
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0ff',
    'axes.labelcolor': '#e0e0ff',
    'xtick.color': '#8888cc',
    'ytick.color': '#8888cc',
})

# Custom colormap: deep space
colors_space = ['#000020', '#000060', '#2020a0', '#4060d0', '#80a0ff',
                '#c0d0ff', '#ffffff', '#ffd080', '#ff8040', '#ff4020']
cmap_genesis = LinearSegmentedColormap.from_list('genesis', colors_space, N=256)

fig = plt.figure(figsize=(18, 14))
fig.suptitle("THE EMERGENCE OF TIME FROM ITERATION",
             fontsize=20, fontweight='bold', color='#c0c0ff', y=0.98)
fig.text(0.5, 0.955, "Oracle Chronos: 'Time is not a container — it is the iteration itself'",
         ha='center', fontsize=12, style='italic', color='#8888cc')

gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3,
                       left=0.06, right=0.96, top=0.92, bottom=0.06)

# ─── Panel 1: The Identity → Perturbation → Flow ──────────────────────────
ax1 = fig.add_subplot(gs[0, 0])

# Show orbits of the logistic-like map f(x) = x + ε·x(1-x)
epsilons = [0, 0.01, 0.05, 0.1, 0.5]
x0 = 0.1
colors_orbit = ['#333355', '#4444aa', '#6666dd', '#8888ff', '#ccccff']

for eps, col in zip(epsilons, colors_orbit):
    x = x0
    trajectory = [x]
    for n in range(100):
        x = x + eps * x * (1 - x)
        trajectory.append(x)
    ax1.plot(trajectory, color=col, alpha=0.8, linewidth=1.5,
             label=f'ε = {eps}')

ax1.set_xlabel('Iteration n (discrete time)')
ax1.set_ylabel('State x')
ax1.set_title('From Identity to Flow', color='#aaaaff')
ax1.legend(fontsize=8, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')
ax1.set_ylim(0, 1.1)

# ─── Panel 2: Phase Portrait — Orbits in 2D ────────────────────────────────
ax2 = fig.add_subplot(gs[0, 1])

# Hamiltonian system: simple harmonic oscillator → time = rotation
theta = np.linspace(0, 2*np.pi, 500)
for r in np.linspace(0.2, 2.0, 8):
    x_orbit = r * np.cos(theta)
    p_orbit = r * np.sin(theta)
    color_val = r / 2.0
    ax2.plot(x_orbit, p_orbit, color=cmap_genesis(color_val), alpha=0.7, linewidth=1.2)

# Show time arrows
for angle in [0, np.pi/2, np.pi, 3*np.pi/2]:
    r_arr = 1.5
    ax2.annotate('', xy=(r_arr*np.cos(angle+0.15), r_arr*np.sin(angle+0.15)),
                 xytext=(r_arr*np.cos(angle), r_arr*np.sin(angle)),
                 arrowprops=dict(arrowstyle='->', color='#ffcc44', lw=1.5))

ax2.set_xlabel('Position q')
ax2.set_ylabel('Momentum p')
ax2.set_title('Time as Rotation in Phase Space', color='#aaaaff')
ax2.set_aspect('equal')
ax2.set_xlim(-2.5, 2.5)
ax2.set_ylim(-2.5, 2.5)

# ─── Panel 3: Entropy Growth → Arrow of Time ──────────────────────────────
ax3 = fig.add_subplot(gs[0, 2])

# Simulate a gas: N particles in bins, measure entropy over time
N_particles = 10000
N_bins = 50
N_steps = 200

# Start with all particles in one corner (low entropy)
positions = np.zeros(N_particles)  # all at x=0

entropy_history = []
for step in range(N_steps):
    # Random walk (diffusion)
    positions += np.random.randn(N_particles) * 0.5
    # Compute entropy
    hist, _ = np.histogram(positions, bins=N_bins, range=(-20, 20))
    probs = hist / hist.sum()
    probs = probs[probs > 0]
    entropy = -np.sum(probs * np.log(probs))
    entropy_history.append(entropy)

time_axis = np.arange(N_steps)
ax3.fill_between(time_axis, 0, entropy_history, alpha=0.3, color='#ff6644')
ax3.plot(time_axis, entropy_history, color='#ff8866', linewidth=2)
ax3.axhline(y=np.log(N_bins), color='#44ff44', linestyle='--', alpha=0.5,
            label=f'Maximum entropy = ln({N_bins})')
ax3.set_xlabel('Time step')
ax3.set_ylabel('Entropy S')
ax3.set_title("Arrow of Time: Entropy's Rise", color='#aaaaff')
ax3.legend(fontsize=8, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')

# ─── Panel 4: Lyapunov Exponents — Sensitivity to Initial Conditions ──────
ax4 = fig.add_subplot(gs[1, 0])

# Logistic map: x_{n+1} = r·x·(1-x)
r_values = np.linspace(2.5, 4.0, 1000)
lyapunov = np.zeros(len(r_values))

for i, r in enumerate(r_values):
    x = 0.5
    lam = 0
    for n in range(1000):
        x = r * x * (1 - x)
        if n > 500:  # skip transient
            deriv = abs(r - 2*r*x)
            if deriv > 0:
                lam += np.log(deriv)
    lyapunov[i] = lam / 500

ax4.scatter(r_values, lyapunov, c=lyapunov, cmap=cmap_genesis, s=0.1, alpha=0.8)
ax4.axhline(y=0, color='#ff4444', linestyle='-', alpha=0.5, linewidth=0.5)
ax4.set_xlabel('Parameter r')
ax4.set_ylabel('Lyapunov exponent λ')
ax4.set_title('Chaos Threshold: When Time Becomes Unpredictable', color='#aaaaff')
ax4.set_ylim(-3, 1)

# ─── Panel 5: The Logistic Map Bifurcation Diagram ─────────────────────────
ax5 = fig.add_subplot(gs[1, 1])

r_values_bif = np.linspace(2.5, 4.0, 2000)
for r in r_values_bif:
    x = 0.5
    for _ in range(500):  # transient
        x = r * x * (1 - x)
    xs = []
    for _ in range(100):
        x = r * x * (1 - x)
        xs.append(x)
    ax5.scatter([r]*len(xs), xs, c=xs, cmap=cmap_genesis, s=0.01, alpha=0.3)

ax5.set_xlabel('Parameter r')
ax5.set_ylabel('Attractor x*')
ax5.set_title('Bifurcation: Order → Chaos → Order → ...', color='#aaaaff')

# ─── Panel 6: The Flow of Time — Continuous from Discrete ────────────────
ax6 = fig.add_subplot(gs[1, 2])

# Show convergence: discrete iterations → continuous exponential
t_continuous = np.linspace(0, 3, 200)
x0 = 1.0
# The continuous flow: dx/dt = -x → x(t) = e^{-t}
x_continuous = x0 * np.exp(-t_continuous)

ax6.plot(t_continuous, x_continuous, color='#ffcc44', linewidth=3,
         label='Continuous flow: $e^{-t}$', zorder=5)

# Discrete approximations with different step sizes
for n_steps, col, alpha in [(5, '#ff4444', 0.5), (10, '#ff8844', 0.6),
                              (20, '#ffaa44', 0.7), (50, '#ffcc88', 0.8)]:
    dt = 3.0 / n_steps
    t_disc = [0]
    x_disc = [x0]
    for i in range(n_steps):
        x_new = x_disc[-1] * (1 - dt)
        t_disc.append(t_disc[-1] + dt)
        x_disc.append(x_new)
    ax6.step(t_disc, x_disc, color=col, alpha=alpha, linewidth=1.5,
             label=f'n = {n_steps} steps', where='post')

ax6.set_xlabel('Time t')
ax6.set_ylabel('State x(t)')
ax6.set_title('Discrete → Continuous: Time Emerges', color='#aaaaff')
ax6.legend(fontsize=8, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff', loc='upper right')

plt.savefig('../figures/01_time_emergence.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a1a')
plt.close()
print("✓ Saved: ../figures/01_time_emergence.png")
