import math
import matplotlib.pyplot as plt
from itertools import combinations

def circ_positions(n):
    return [(math.cos(2*math.pi*i/n), math.sin(2*math.pi*i/n)) for i in range(n)]

def draw(ax, n, adj, title):
    pos = circ_positions(n)
    for a, b in combinations(range(n), 2):
        if adj(a, b):
            xa, ya = pos[a]; xb, yb = pos[b]
            ax.plot([xa, xb], [ya, yb], color='crimson', lw=1.2, zorder=1)
    xs, ys = zip(*pos)
    ax.scatter(xs, ys, s=120, color='navy', zorder=2)
    ax.set_title(title); ax.set_aspect('equal'); ax.axis('off')

pent = lambda a, b: (a - b) % 5 in (1, 4)
mob = lambda a, b: (a - b) % 8 in (1, 7, 4)
QR17 = {1,2,4,8,9,13,15,16}
paley = lambda a, b: (a - b) % 17 in QR17

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
draw(axes[0], 5, pent, 'Pentagon C5  (R(3,3) > 5)')
draw(axes[1], 8, mob, 'Mobius ladder C8(1,4)  (R(3,4) > 8)')
draw(axes[2], 17, paley, 'Paley graph Z/17  (R(4,4) > 17)')
plt.tight_layout(); plt.savefig('ramsey_constructions.png', dpi=150)
print('saved ramsey_constructions.png')
