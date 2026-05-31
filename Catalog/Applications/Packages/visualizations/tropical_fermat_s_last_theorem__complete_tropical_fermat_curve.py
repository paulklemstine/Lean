import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, ax = plt.subplots(1, 1, figsize=(8, 8))
bound = 6
diagonal_x = list(range(-bound, 1))
diagonal_y = list(range(-bound, 1))
ax.plot(diagonal_x, diagonal_y, 'b-', linewidth=3, label='Diagonal: x=y≤0')
ax.plot(list(range(0, bound+1)), [0]*(bound+1), 'r-', linewidth=3, label='x-axis: y=0, x≥0')
ax.plot([0]*(bound+1), list(range(0, bound+1)), 'g-', linewidth=3, label='y-axis: x=0, y≥0')
ax.plot(0, 0, 'ko', markersize=12, zorder=5)
ax.set_xlim(-7, 7)
ax.set_ylim(-7, 7)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_title('Tropical Fermat Curve (all degrees)', fontsize=16)
ax.legend(fontsize=12)
plt.tight_layout()
plt.savefig('tropical_fermat_curve.png', dpi=150)
plt.close()