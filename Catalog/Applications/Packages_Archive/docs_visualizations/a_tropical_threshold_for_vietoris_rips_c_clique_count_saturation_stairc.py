import itertools, math
import numpy as np
import matplotlib.pyplot as plt

pts = [(0,0),(1,0),(0.2,0.9),(1.1,1.0),(0.5,0.4)]
n = len(pts)
def d(i,j):
    return math.hypot(pts[i][0]-pts[j][0], pts[i][1]-pts[j][1])
tbs = max(d(i,j) for i in range(n) for j in range(i+1,n))
epss = np.linspace(0, tbs*1.1, 300)
for m in [2,3,4]:
    ys = [sum(1 for s in itertools.combinations(range(n), m)
              if all(d(a,b) <= e for a,b in itertools.combinations(s,2)))
          for e in epss]
    plt.step(epss, ys, where='post', label=f'm={m} (ceiling {math.comb(n,m)})')
plt.axvline(tbs, color='k', ls='--', label=f'tropBirthSum={tbs:.3f}')
plt.xlabel('scale eps'); plt.ylabel('clique count'); plt.legend()
plt.title('Clique-count saturation across dimensions')
plt.tight_layout(); plt.savefig('saturation.png', dpi=130)
print('wrote saturation.png')
