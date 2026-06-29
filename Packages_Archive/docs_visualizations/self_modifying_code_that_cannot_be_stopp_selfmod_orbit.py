import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def orbit(f, start, max_steps=30):
    path = [start]
    x = start
    for _ in range(max_steps):
        x = f[x]
        path.append(x)
        if x in path[:-1]:
            break
    return path

n = 10
f = [3, 7, 5, 1, 9, 2, 8, 4, 0, 6]
path = orbit(f, 0)

fig, ax = plt.subplots(1, 1, figsize=(10, 6))
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
xs = np.cos(angles)
ys = np.sin(angles)

for i in range(n):
    color = 'lightblue' if i not in path else 'orange'
    ax.plot(xs[i], ys[i], 'o', markersize=30, color=color, zorder=3)
    ax.text(xs[i], ys[i], str(i), ha='center', va='center', fontsize=14, fontweight='bold', zorder=4)

for idx in range(len(path) - 1):
    i, j = path[idx], path[idx + 1]
    dx = xs[j] - xs[i]
    dy = ys[j] - ys[i]
    ax.annotate('', xy=(xs[j], ys[j]), xytext=(xs[i], ys[i]),
                arrowprops=dict(arrowstyle='->', color='red', lw=2,
                                connectionstyle='arc3,rad=0.2'))
    ax.text((xs[i]+xs[j])/2 + 0.05, (ys[i]+ys[j])/2 + 0.05,
            str(idx+1), fontsize=9, color='red')

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title(f'Self-modification orbit on {{0,...,{n-1}}}\nPath: {" -> ".join(map(str, path))}', fontsize=13)
ax.axis('off')
plt.savefig('selfmod_orbit.png', dpi=150, bbox_inches='tight')
print('Saved selfmod_orbit.png')