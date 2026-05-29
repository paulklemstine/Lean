"""
Visualization 2: Topological Conjugacy between Tent Map and Logistic Map

Shows the conjugacy h(y) = sin²(πy/2) that transforms the tent map
T(y) = 2·min(y, 1-y) into the logistic map f(x) = 4x(1-x).
Demonstrates that h ∘ T = f ∘ h, the key bridge that transfers
shadowing from the piecewise-linear tent map to the nonlinear logistic map.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def logistic(x):
    return 4 * x * (1 - x)


def tent(y):
    return 2 * np.minimum(y, 1 - y)


def conjugacy(y):
    return np.sin(np.pi * y / 2) ** 2


fig, axes = plt.subplots(2, 2, figsize=(13, 11))

# Panel 1: The conjugacy function h(y) = sin²(πy/2)
ax = axes[0, 0]
y = np.linspace(0, 1, 1000)
ax.plot(y, conjugacy(y), 'b-', linewidth=2.5)
ax.plot(y, y, 'k--', alpha=0.3, label='y = x (identity)')
ax.set_xlabel('y (tent map space)', fontsize=12)
ax.set_ylabel('h(y) = sin²(πy/2)', fontsize=12)
ax.set_title('The Conjugacy Function', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# Panel 2: Tent map vs Logistic map
ax = axes[0, 1]
x = np.linspace(0, 1, 1000)
ax.plot(x, tent(x), 'r-', linewidth=2.5, label='Tent: T(y) = 2·min(y, 1-y)')
ax.plot(x, logistic(x), 'b-', linewidth=2.5, label='Logistic: f(x) = 4x(1-x)')
ax.plot(x, x, 'k--', alpha=0.3, label='y = x')
ax.set_xlabel('Input', fontsize=12)
ax.set_ylabel('Output', fontsize=12)
ax.set_title('Tent Map vs Logistic Map', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# Panel 3: Verification of conjugacy equation h(T(y)) = f(h(y))
ax = axes[1, 0]
y = np.linspace(0.001, 0.999, 500)
lhs = conjugacy(tent(y))  # h(T(y))
rhs = logistic(conjugacy(y))  # f(h(y))
error = np.abs(lhs - rhs)

ax.semilogy(y, error, 'purple', linewidth=2)
ax.axhline(y=np.finfo(np.float64).eps, color='red', linestyle='--',
           label=f'Machine epsilon = {np.finfo(np.float64).eps:.1e}')
ax.set_xlabel('y', fontsize=12)
ax.set_ylabel('|h(T(y)) - f(h(y))|', fontsize=12)
ax.set_title('Conjugacy Equation Verification\nh ∘ T = f ∘ h', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 4: Orbits comparison — tent orbit mapped through h vs logistic orbit
ax = axes[1, 1]
y0 = 0.3
n_steps = 50

# Tent map orbit
tent_orbit = [y0]
for _ in range(n_steps):
    tent_orbit.append(2 * min(tent_orbit[-1], 1 - tent_orbit[-1]))
tent_orbit = np.array(tent_orbit)

# Conjugated orbit: h(tent orbit)
conj_orbit = conjugacy(tent_orbit)

# Direct logistic orbit from h(y0)
x0 = conjugacy(np.array([y0]))[0]
log_orbit = [x0]
for _ in range(n_steps):
    log_orbit.append(4 * log_orbit[-1] * (1 - log_orbit[-1]))
log_orbit = np.array(log_orbit)

ax.plot(range(n_steps + 1), conj_orbit, 'b-o', markersize=4, linewidth=1.5,
        label='h(tent orbit)', alpha=0.8)
ax.plot(range(n_steps + 1), log_orbit, 'r--x', markersize=4, linewidth=1.5,
        label='logistic orbit', alpha=0.8)
ax.set_xlabel('Iteration', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Conjugated Tent Orbit = Logistic Orbit', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Topological Conjugacy: Tent Map ↔ Logistic Map\n'
             'via h(y) = sin²(πy/2)', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_conjugacy.png', dpi=150, bbox_inches='tight')
print("Saved viz_conjugacy.png")
