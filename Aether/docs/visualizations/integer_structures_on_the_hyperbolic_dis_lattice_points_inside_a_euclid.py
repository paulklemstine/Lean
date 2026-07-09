import math
from itertools import product
import matplotlib.pyplot as plt

def lattice_points_in_ball(center, radius):
    c1, c2 = center; r = abs(radius)
    xs = range(math.ceil(c1 - r), math.floor(c1 + r) + 1)
    ys = range(math.ceil(c2 - r), math.floor(c2 + r) + 1)
    return [(m, n) for m, n in product(xs, ys)
            if (m - c1)**2 + (n - c2)**2 < radius**2]

center, R = (0.3, -0.2), 4.0
pts = lattice_points_in_ball(center, R)
fig, ax = plt.subplots(figsize=(6, 6))
th = [i / 200 * 2 * math.pi for i in range(201)]
ax.plot([center[0] + R * math.cos(a) for a in th],
        [center[1] + R * math.sin(a) for a in th], 'k')
ax.scatter([p[0] for p in pts], [p[1] for p in pts], c='crimson', s=25)
ax.set_aspect('equal'); ax.set_title(f"{len(pts)} lattice points in ball R={R}")
plt.savefig("lattice_ball.png", dpi=150); print("saved lattice_ball.png")
