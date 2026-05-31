import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 4, figsize=(20, 5))
bound = 6
for ax, n in zip(axes, [1, 2, 3, 5]):
    for x in range(-bound, bound+1):
        for y in range(-bound, bound+1):
            vals = [n*x, n*y, 0]
            m = min(vals)
            if sum(1 for v in vals if v == m) >= 2:
                c = 'blue' if x==y and x<=0 else ('green' if x==0 and y>=0 else ('red' if y==0 and x>=0 else 'purple'))
                ax.plot(x, y, 'o', color=c, ms=6)
    ax.set_xlim(-7, 7); ax.set_ylim(-7, 7); ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
    ax.set_title(f'n = {n}')
fig.suptitle('Degree Independence of Tropical Fermat Varieties', fontsize=15)
plt.tight_layout()
plt.savefig('degree_independence.png', dpi=150)
plt.close()