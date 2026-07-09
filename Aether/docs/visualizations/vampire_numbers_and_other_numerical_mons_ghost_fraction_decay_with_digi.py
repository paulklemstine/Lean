import matplotlib.pyplot as plt
from collections import Counter
def Dset(n): return set(str(n))
ghost, total = Counter(), Counter()
for x in range(10, 1000):
    for y in range(x, 1000):
        v=x*y; total[len(str(v))]+=1
        if not (Dset(v) & (Dset(x)|Dset(y))): ghost[len(str(v))]+=1
Ls=sorted(L for L in total if total[L] > 50)
fr=[ghost[L]/total[L] for L in Ls]
plt.semilogy(Ls, fr, 'o-', color='slateblue')
plt.xlabel('digit length of v'); plt.ylabel('ghost fraction (log)')
plt.title('Geometric decay of ghost density'); plt.tight_layout()
plt.savefig('ghost_decay.png', dpi=150)
