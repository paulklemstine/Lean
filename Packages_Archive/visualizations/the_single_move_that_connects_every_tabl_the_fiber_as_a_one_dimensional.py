import matplotlib.pyplot as plt
from itertools import product

CELLS = list(product((0, 1), repeat=3))

def M3(i, j, k):
    return 1 if (i + j + k) % 2 == 0 else -1

u = {(0,0,0):1,(0,0,1):2,(0,1,0):2,(0,1,1):1,
     (1,0,0):3,(1,0,1):0,(1,1,0):0,(1,1,1):3}
ts = range(-4, 6)
fig, ax = plt.subplots(figsize=(8, 5))
for c in CELLS:
    ys = [u[c] + t * M3(*c) for t in ts]
    ax.plot(list(ts), ys, marker='o', label=str(c))
feasible = [t for t in ts
            if all(u[c] + t * M3(*c) >= 0 for c in CELLS)]
ax.axhline(0, color='black', lw=1)
ax.axvspan(min(feasible) - 0.5, max(feasible) + 0.5,
           color='gold', alpha=0.25, label='feasible interval')
ax.set_xlabel('M3-coordinate t'); ax.set_ylabel('cell value u[c] + t*M3[c]')
ax.set_title('Cell values along the move line: the fiber is an interval')
ax.legend(fontsize=7, ncol=2)
plt.tight_layout()
plt.savefig('fiber_interval.png', dpi=150)
print('wrote fiber_interval.png')
