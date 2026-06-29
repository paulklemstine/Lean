import matplotlib.pyplot as plt
from math import hypot

def euclidean(x, y):
    return hypot(x[0] - y[0], x[1] - y[1])

f = [(0.0, 0.0), (1.0, 2.0), (3.0, 1.0), (4.0, 4.0), (7.0, 3.0)]
n = len(f) - 1
plen = sum(euclidean(f[i], f[i + 1]) for i in range(n))
endp = euclidean(f[0], f[n])

xs, ys = zip(*f)
fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(xs, ys, '-o', color='steelblue', label=f'path (length = {plen:.2f})')
ax.plot([f[0][0], f[n][0]], [f[0][1], f[n][1]], '--', color='crimson',
        label=f'endpoint chord ({endp:.2f})')
for i, p in enumerate(f):
    ax.annotate(f'f({i})', p, textcoords='offset points', xytext=(6, 6))
ax.set_title('Endpoint bound: chord <= path length (hybrid argument)')
ax.legend(); ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('endpoint_bound.png', dpi=150)
print('saved endpoint_bound.png')