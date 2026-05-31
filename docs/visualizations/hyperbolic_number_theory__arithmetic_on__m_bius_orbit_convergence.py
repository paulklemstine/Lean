import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def moebius_add(a, b):
    return (a + b) / (1 + a * b)

def moebius_orbit(g, n):
    orbit = [0.0]
    for _ in range(n):
        orbit.append(moebius_add(g, orbit[-1]))
    return orbit

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for ax, g in zip(axes, [0.2, 0.5, 0.8]):
    orbit = moebius_orbit(g, 30)
    ns = list(range(31))
    ax.scatter(ns, orbit, c=ns, cmap='viridis', s=50, zorder=3)
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5)
    ax.plot(ns, orbit, 'b-', alpha=0.3)
    ax.set_title(f'g = {g}')
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('viz_orbit.png', dpi=150)
