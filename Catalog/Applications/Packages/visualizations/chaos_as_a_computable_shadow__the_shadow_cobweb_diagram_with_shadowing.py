"""
Visualization 3: Cobweb Diagrams and Pseudo-orbit Shadowing

Shows:
1. A cobweb diagram of the logistic map with a true orbit and a shadowing pseudo-orbit
2. The shadowing distance at each step
This makes the abstract concept of "shadowing" visually concrete.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def logistic(x):
    return 4.0 * x * (1.0 - x)


fig, axes = plt.subplots(1, 2, figsize=(15, 6.5))

# ---- Panel 1: Cobweb diagram with true orbit and pseudo-orbit ----
ax = axes[0]

# Draw f(x) and y=x
x = np.linspace(0, 1, 1000)
ax.plot(x, logistic(x), 'b-', linewidth=2, label='f(x) = 4x(1-x)')
ax.plot(x, x, 'k--', alpha=0.4, linewidth=1)

# True orbit (cobweb)
x0_true = 0.2
n_steps = 25
xt = x0_true
cobweb_x = [xt]
cobweb_y = [0]

for _ in range(n_steps):
    fx = logistic(xt)
    cobweb_x.extend([xt, fx])
    cobweb_y.extend([fx, fx])
    xt = fx
    cobweb_x.append(xt)
    cobweb_y.append(xt)

ax.plot(cobweb_x, cobweb_y, 'g-', alpha=0.5, linewidth=0.8, label='True orbit cobweb')

# Pseudo-orbit (with perturbations)
np.random.seed(123)
delta = 0.03  # Large delta for visibility
xp = x0_true
pseudo_points = [xp]
for _ in range(n_steps):
    xp = logistic(xp) + np.random.uniform(-delta, delta)
    xp = np.clip(xp, 0, 1)
    pseudo_points.append(xp)

# Draw pseudo-orbit cobweb
xp = pseudo_points[0]
pcob_x = [xp]
pcob_y = [0]
for i in range(n_steps):
    fx = pseudo_points[i + 1]
    pcob_x.extend([pseudo_points[i], pseudo_points[i]])
    pcob_y.extend([fx, fx])
    pcob_x.append(fx)
    pcob_y.append(fx)

ax.plot(pcob_x, pcob_y, 'r-', alpha=0.5, linewidth=0.8, label=f'Pseudo-orbit (δ={delta})')

# Mark key points
ax.plot(x0_true, 0, 'go', markersize=10, zorder=5)
ax.plot(x0_true, 0, 'ro', markersize=6, zorder=5)

ax.set_xlabel('x', fontsize=13)
ax.set_ylabel('f(x)', fontsize=13)
ax.set_title('Cobweb Diagram: True vs Pseudo-Orbit\nLogistic Map f(x) = 4x(1-x)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.2)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.set_aspect('equal')

# ---- Panel 2: Shadowing distance visualization ----
ax = axes[1]

# Compute true orbit
true_orbit = [x0_true]
for _ in range(n_steps):
    true_orbit.append(logistic(true_orbit[-1]))
true_orbit = np.array(true_orbit)
pseudo_orbit = np.array(pseudo_points)

# Shadowing distance
shadow_dist = np.abs(true_orbit - pseudo_orbit)

iters = range(n_steps + 1)
ax.bar(iters, shadow_dist, color='purple', alpha=0.6, label='|x_true - x_pseudo|')
ax.axhline(y=delta, color='red', linestyle='--', linewidth=2,
           label=f'δ = {delta}')
ax.axhline(y=4 * delta, color='orange', linestyle='--', linewidth=2,
           label=f'4δ = {4*delta} (shadowing bound)')

# Also plot the orbits themselves
ax2 = ax.twinx()
ax2.plot(iters, true_orbit, 'g-o', markersize=4, alpha=0.6, label='True orbit')
ax2.plot(iters, pseudo_orbit, 'r-s', markersize=3, alpha=0.6, label='Pseudo-orbit')
ax2.set_ylabel('Orbit value', fontsize=12, color='gray')
ax2.tick_params(axis='y', labelcolor='gray')
ax2.legend(fontsize=9, loc='upper right')

ax.set_xlabel('Iteration', fontsize=13)
ax.set_ylabel('Shadowing distance', fontsize=13)
ax.set_title('Pointwise Shadowing Distance\nat Each Iteration',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.2)

plt.suptitle('The Shadowing Lemma: Pseudo-Orbits Follow True Orbits',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_cobweb.png', dpi=150, bbox_inches='tight')
print("Saved viz_cobweb.png")
