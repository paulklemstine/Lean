#!/usr/bin/env python3
"""
Visualization: Joke Space Geometry

Shows the geometric structure of jokes in 2D:
- Jokes as triangles (setup → expected → punchline)
- The pun-absurdist spectrum
- Universal joke search (farthest punchline from expected)
- Geodesic vs non-geodesic jokes
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch
import matplotlib

matplotlib.rcParams['font.size'] = 11

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Plot 1: Anatomy of a Joke
ax = axes[0, 0]
setup = np.array([0, 0])
expected = np.array([4, 1])
punchline = np.array([2, 5])

# Draw triangle
triangle = plt.Polygon([setup, expected, punchline],
                       fill=True, facecolor='lightyellow',
                       edgecolor='black', linewidth=1.5)
ax.add_patch(triangle)

# Draw labeled arrows
for start, end, label, color, offset in [
    (setup, expected, 'Tension', 'blue', (0, -0.5)),
    (expected, punchline, 'Humor', 'red', (0.5, 0)),
    (setup, punchline, 'Arc', 'green', (-0.7, 0)),
]:
    mid = (start + end) / 2
    ax.annotate('', xy=end, xytext=start,
               arrowprops=dict(arrowstyle='->', color=color, lw=2.5))
    ax.annotate(label, xy=mid + np.array(offset),
               fontsize=12, color=color, fontweight='bold', ha='center')

# Label points
for pt, label, offset in [
    (setup, 'Setup\n(0, 0)', (-0.3, -0.5)),
    (expected, 'Expected\n(4, 1)', (0.3, -0.7)),
    (punchline, 'Punchline\n(2, 5)', (-0.3, 0.3)),
]:
    ax.annotate(label, xy=pt + np.array(offset), fontsize=10, ha='center')

ax.plot(*setup, 'ko', markersize=8)
ax.plot(*expected, 'bs', markersize=8)
ax.plot(*punchline, 'r^', markersize=10)

t = np.linalg.norm(setup - expected)
h = np.linalg.norm(expected - punchline)
a = np.linalg.norm(setup - punchline)
ax.set_title(f'Anatomy of a Joke\nT={t:.2f}, H={h:.2f}, A={a:.2f}')
ax.set_xlim(-1.5, 6)
ax.set_ylim(-1.5, 6.5)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Plot 2: Pun-Absurdist Spectrum
ax = axes[0, 1]
np.random.seed(42)
n_jokes = 100
setups_2d = np.zeros((n_jokes, 2))
expecteds_2d = np.random.randn(n_jokes, 2) * 1.5 + np.array([3, 0])
punchlines_2d = np.random.randn(n_jokes, 2) * 3 + np.array([1, 2])

humors_2d = np.linalg.norm(expecteds_2d - punchlines_2d, axis=1)
threshold = np.median(humors_2d)

puns_mask = humors_2d < threshold
absurdist_mask = ~puns_mask

ax.scatter(expecteds_2d[puns_mask, 0], expecteds_2d[puns_mask, 1],
          c='blue', s=30, alpha=0.5, label=f'Puns (H < {threshold:.1f})')
ax.scatter(punchlines_2d[puns_mask, 0], punchlines_2d[puns_mask, 1],
          c='lightblue', s=30, alpha=0.5, marker='^')

ax.scatter(expecteds_2d[absurdist_mask, 0], expecteds_2d[absurdist_mask, 1],
          c='red', s=30, alpha=0.5, label=f'Absurdist (H ≥ {threshold:.1f})')
ax.scatter(punchlines_2d[absurdist_mask, 0], punchlines_2d[absurdist_mask, 1],
          c='lightsalmon', s=30, alpha=0.5, marker='^')

# Draw some connections
for i in range(0, n_jokes, 5):
    color = 'blue' if puns_mask[i] else 'red'
    ax.plot([expecteds_2d[i, 0], punchlines_2d[i, 0]],
           [expecteds_2d[i, 1], punchlines_2d[i, 1]],
           color=color, alpha=0.2, linewidth=0.5)

ax.set_title('Pun-Absurdist Spectrum\n(squares=expected, triangles=punchline)')
ax.legend(fontsize=9)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.grid(True, alpha=0.3)

# Plot 3: Universal Joke Search
ax = axes[1, 0]
expected_pt = np.array([0.0, 0.0])
np.random.seed(123)
candidates = np.random.randn(30, 2) * 3

distances = np.linalg.norm(candidates - expected_pt, axis=1)
best_idx = np.argmax(distances)

# Draw circles showing distance levels
for r in [2, 4, 6, 8]:
    circle = plt.Circle(expected_pt, r, fill=False, color='gray',
                       linestyle='--', alpha=0.3)
    ax.add_patch(circle)

ax.scatter(candidates[:, 0], candidates[:, 1], c=distances, cmap='YlOrRd',
          s=60, edgecolors='black', linewidth=0.5, zorder=3)
ax.scatter(*expected_pt, c='blue', s=200, marker='*', zorder=5,
          label='Expected', edgecolors='black')
ax.scatter(*candidates[best_idx], c='red', s=200, marker='*', zorder=5,
          label=f'Universal (H={distances[best_idx]:.2f})', edgecolors='black')

# Draw line to universal joke
ax.plot([expected_pt[0], candidates[best_idx, 0]],
       [expected_pt[1], candidates[best_idx, 1]],
       'r-', linewidth=2, alpha=0.7)

ax.set_title('Universal Joke Search\n(farthest punchline from expected)')
ax.legend(fontsize=9)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Plot 4: Geodesic vs Non-Geodesic Jokes
ax = axes[1, 1]
np.random.seed(456)

# Create geodesic jokes (expected on line from setup to punchline)
n_geo = 15
setups_g = np.zeros((n_geo, 2))
punchlines_g = np.random.randn(n_geo, 2) * 4
# Expected is a random point on the segment
t_params = np.random.uniform(0.2, 0.8, n_geo)
expecteds_g = setups_g + t_params[:, None] * (punchlines_g - setups_g)

# Create non-geodesic jokes (expected off the line)
n_nongeo = 15
setups_ng = np.zeros((n_nongeo, 2))
punchlines_ng = np.random.randn(n_nongeo, 2) * 4
expecteds_ng = np.random.randn(n_nongeo, 2) * 2

for i in range(n_geo):
    color = 'green'
    ax.plot([setups_g[i, 0], expecteds_g[i, 0], punchlines_g[i, 0]],
           [setups_g[i, 1], expecteds_g[i, 1], punchlines_g[i, 1]],
           color=color, alpha=0.4, linewidth=1)
    ax.plot(*punchlines_g[i], 'g^', markersize=6, alpha=0.6)

for i in range(n_nongeo):
    color = 'purple'
    ax.plot([setups_ng[i, 0], expecteds_ng[i, 0], punchlines_ng[i, 0]],
           [setups_ng[i, 1], expecteds_ng[i, 1], punchlines_ng[i, 1]],
           color=color, alpha=0.4, linewidth=1)
    ax.plot(*punchlines_ng[i], 'm^', markersize=6, alpha=0.6)

ax.plot([], [], 'g-', linewidth=2, label='Geodesic (T+H=A)')
ax.plot([], [], 'm-', linewidth=2, label='Non-geodesic (T+H>A)')
ax.plot(0, 0, 'ko', markersize=10, label='Setup (origin)')

ax.set_title('Geodesic vs Non-Geodesic Jokes\n(green = geodesic, purple = non-geodesic)')
ax.legend(fontsize=9)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('joke_space.png', dpi=150, bbox_inches='tight')
print("Saved joke_space.png")
