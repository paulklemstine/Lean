import numpy as np
import matplotlib.pyplot as plt

def fit_circle(pts):
    A = np.array([[x, y, 1.0] for (x, y) in pts[:3]])
    b = np.array([-(x*x + y*y) for (x, y) in pts[:3]])
    D, E, F = np.linalg.solve(A, b)
    cx, cy = -D/2, -E/2
    r = np.sqrt(cx*cx + cy*cy - F)
    return cx, cy, r

def panel(ax, abs4, title):
    xs = np.linspace(-4, 4, 400)
    ax.plot(xs, xs**2, 'k-', lw=1, label='y = x^2')
    pts = [(t, t*t) for t in abs4]
    cx, cy, r = fit_circle(pts)
    th = np.linspace(0, 2*np.pi, 300)
    ax.plot(cx + r*np.cos(th), cy + r*np.sin(th), 'b--', lw=1)
    for (x, y) in pts:
        ax.plot(x, y, 'ro')
    ax.set_title(f'{title}  (sum={sum(abs4):+.1f})')
    ax.set_aspect('equal'); ax.grid(True, alpha=0.3)

fig, axes = plt.subplots(1, 2, figsize=(12, 5))
panel(axes[0], [-3, -1, 1, 3], 'Concyclic')
panel(axes[1], [1, 2, 3, 4], 'Not concyclic')
plt.tight_layout(); plt.savefig('concyclic.png', dpi=150)
print('wrote concyclic.png')
