import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401
from itertools import product

def M3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1

fig = plt.figure(figsize=(7, 6))
ax = fig.add_subplot(111, projection='3d')
cells = list(product((0, 1), repeat=3))
for (i, j, k) in cells:
    val = M3(i, j, k)
    color = 'crimson' if val == 1 else 'royalblue'
    ax.scatter(i, j, k, s=600, c=color, depthshade=False,
               edgecolors='black')
    ax.text(i, j, k, f' {val:+d}', fontsize=12, weight='bold')
# draw cube edges (cells differing in exactly one coordinate)
for a in cells:
    for b in cells:
        if sum(x != y for x, y in zip(a, b)) == 1 and a < b:
            ax.plot(*zip(a, b), color='gray', lw=1, alpha=0.6)
ax.set_xlabel('i'); ax.set_ylabel('j'); ax.set_zlabel('k')
ax.set_title('Alternating move M3(i,j,k) = (-1)^(i+j+k)\nred = +1 (even), blue = -1 (odd)')
plt.tight_layout()
plt.savefig('alternating_move_cube.png', dpi=150)
print('wrote alternating_move_cube.png')
