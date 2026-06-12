import math
import matplotlib.pyplot as plt

def orbit(alpha: float, n: int) -> list:
    return [(k * alpha) % 1.0 for k in range(n)]

fig, axes = plt.subplots(1, 2, figsize=(11, 4))
for ax, (alpha, title) in zip(axes, [(4/5, 'alpha = 4/5 (rational, order 5)'),
                                     (math.sqrt(2), 'alpha = sqrt(2) (irrational, dense)')]):
    pts = orbit(alpha, 300)
    thetas = [2 * math.pi * p for p in pts]
    ax.scatter([math.cos(t) for t in thetas], [math.sin(t) for t in thetas],
               s=12, alpha=0.6)
    ax.add_patch(plt.Circle((0, 0), 1, fill=False, color='gray'))
    ax.set_aspect('equal'); ax.set_title(title); ax.axis('off')
plt.suptitle('Phase-gate orbit on the torus R/Z: the universality dichotomy')
plt.tight_layout(); plt.savefig('orbit_density.png', dpi=150)
print('saved orbit_density.png')
