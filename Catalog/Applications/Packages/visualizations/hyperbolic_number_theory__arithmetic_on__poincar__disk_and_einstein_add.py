"""
Visualization 1: The Poincaré Disk and Einstein Addition
=========================================================
Visualizes the Einstein velocity addition group on the Poincaré disk.
Shows how vectors add hyperbolically (smaller than Euclidean addition)
and how the disk boundary acts as a "speed of light" barrier.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def einstein_add_2d(z1, z2):
    """Einstein (Möbius) addition in the Poincaré disk model.
    z1, z2 are complex numbers with |z| < 1."""
    num = z1 + z2
    denom = 1 + np.conj(z1) * z2
    return num / denom


def draw_hyperbolic_geodesic(ax, z1, z2, n_points=100, **kwargs):
    """Draw a geodesic (circular arc) between two points in the Poincaré disk."""
    t = np.linspace(0, 1, n_points)
    # Parametrize the geodesic via Möbius interpolation
    points = []
    for ti in t:
        # Linear interpolation in rapidity space (approximate)
        z = z1 * (1 - ti) + z2 * ti
        if abs(z) < 0.999:
            points.append(z)
    if points:
        xs = [p.real for p in points]
        ys = [p.imag for p in points]
        ax.plot(xs, ys, **kwargs)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Einstein addition vectors
ax = axes[0]
ax.set_title("Einstein Addition on (-1, 1)\n$a \\oplus b = (a+b)/(1+ab)$", fontsize=13)

# Draw the interval
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.axvline(x=-1, color='red', linewidth=2, linestyle='--', alpha=0.5, label='Speed of light')
ax.axvline(x=1, color='red', linewidth=2, linestyle='--', alpha=0.5)

# Plot Einstein additions
pairs = [(0.3, 0.4), (0.5, 0.5), (0.7, 0.7), (0.9, 0.9)]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for i, (a, b) in enumerate(pairs):
    result = (a + b) / (1 + a * b)
    naive = a + b
    y_offset = (i + 1) * 0.15

    ax.plot([0, a], [y_offset, y_offset], 'o-', color=colors[i], linewidth=2, markersize=6)
    ax.plot([a, result], [y_offset, y_offset], 's-', color=colors[i], linewidth=2,
            markersize=8, alpha=0.7, label=f'{a} ⊕ {b} = {result:.3f}')
    if naive < 1.2:
        ax.plot(naive, y_offset, 'x', color=colors[i], markersize=10, markeredgewidth=2)

ax.set_xlim(-1.3, 1.3)
ax.set_ylim(-0.1, 0.9)
ax.legend(fontsize=9, loc='upper left')
ax.set_xlabel('Velocity (units of c)')

# Panel 2: Poincaré disk with orbit points
ax = axes[1]
ax.set_title("SL₂(ℤ) Orbit Points\nin the Poincaré Disk", fontsize=13)

# Draw unit circle
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.05, color='blue')

# Generate orbit points using Möbius transformations
np.random.seed(42)
points = [complex(0, 0)]  # Origin

# Apply S and T generators iteratively
def moebius_S(z):
    """S generator: z → -1/z (with disk model adjustment)"""
    if abs(z) < 0.001:
        return complex(0.5, 0)
    w = -1.0 / z if abs(z) > 0.01 else complex(0, 0)
    return w / (1 + abs(w)) * 0.9  # project to disk

def moebius_T(z, n=1):
    """T generator: translation"""
    shift = complex(0.3 * n, 0.1 * n)
    return einstein_add_2d(z, shift * 0.3)

# Build orbit
orbit = set()
orbit.add(complex(0, 0))
generators = [complex(0.4, 0), complex(-0.4, 0), complex(0, 0.4), complex(0, -0.4),
              complex(0.3, 0.3), complex(-0.3, 0.3)]

current_layer = {complex(0, 0)}
for depth in range(3):
    next_layer = set()
    for z in current_layer:
        for g in generators:
            w = einstein_add_2d(z, g)
            if abs(w) < 0.98:
                orbit.add(w)
                next_layer.add(w)
    current_layer = next_layer

# Color by distance from origin
for z in orbit:
    r = abs(z)
    color = plt.cm.viridis(r / 1.0)
    size = 30 if r < 0.1 else 15
    ax.plot(z.real, z.imag, 'o', color=color, markersize=size ** 0.5 + 2, alpha=0.8)

ax.plot(0, 0, 'r*', markersize=15, zorder=5, label='Origin')
ax.set_xlim(-1.2, 1.2)
ax.set_ylim(-1.2, 1.2)
ax.set_aspect('equal')
ax.legend(fontsize=10)

# Panel 3: Chebyshev trace growth
ax = axes[2]
ax.set_title("Chebyshev Trace Growth\n$\\mathrm{tr}(A^n)$ by initial trace", fontsize=13)

def chebyshev_trace_seq(t, max_n):
    result = [2, t]
    for i in range(2, max_n + 1):
        result.append(t * result[-1] - result[-2])
    return result

max_n = 8
for t, color, label in [(2, '#2196F3', 't=2 (parabolic)'),
                         (3, '#4CAF50', 't=3 (hyperbolic)'),
                         (4, '#FF9800', 't=4'),
                         (5, '#E91E63', 't=5')]:
    seq = chebyshev_trace_seq(t, max_n)
    ax.semilogy(range(max_n + 1), [max(1, abs(v)) for v in seq],
                'o-', color=color, linewidth=2, markersize=6, label=label)

ax.set_xlabel('Power n')
ax.set_ylabel('|tr(Aⁿ)| (log scale)')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_poincare_disk.png")
