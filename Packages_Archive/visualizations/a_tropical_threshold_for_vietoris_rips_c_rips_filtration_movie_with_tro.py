import itertools, math
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon

pts = [(0,0),(1,0),(0.2,0.9),(1.1,1.0),(0.5,0.4)]
n = len(pts)
def d(i,j):
    return math.hypot(pts[i][0]-pts[j][0], pts[i][1]-pts[j][1])
tbs = max(d(i,j) for i in range(n) for j in range(i+1,n))
scales = [0.4, 0.7, 1.0, tbs]
fig, axes = plt.subplots(1, len(scales), figsize=(4*len(scales), 4))
for ax, eps in zip(axes, scales):
    for tri in itertools.combinations(range(n), 3):
        if all(d(a,b) <= eps for a,b in itertools.combinations(tri,2)):
            ax.add_patch(Polygon([pts[t] for t in tri], alpha=0.18, color='tab:blue'))
    for i,j in itertools.combinations(range(n),2):
        if d(i,j) <= eps:
            ax.plot([pts[i][0],pts[j][0]],[pts[i][1],pts[j][1]],'k-',lw=1)
    ax.scatter([p[0] for p in pts],[p[1] for p in pts],c='crimson',zorder=3)
    ax.set_title(f'eps={eps:.3f}' + ('  (complete)' if eps>=tbs-1e-9 else ''))
    ax.set_aspect('equal'); ax.axis('off')
fig.suptitle(f'tropBirthSum = diameter = {tbs:.3f}')
plt.tight_layout(); plt.savefig('rips_filtration.png', dpi=130)
print('wrote rips_filtration.png')
