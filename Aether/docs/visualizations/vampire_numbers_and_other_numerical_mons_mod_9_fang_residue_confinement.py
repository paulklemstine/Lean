import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
def M(n): return Counter(str(n))
grid=np.zeros((9,9))
for a in range(9):
    for b in range(9):
        if ((a-1)*(b-1))%9 == 1%9: grid[a,b]=0.5
for x in range(10,100):
    for y in range(x,100):
        v=x*y
        if len(str(v))==4 and M(v)==M(x)+M(y): grid[x%9,y%9]=1.0
plt.imshow(grid, origin='lower', cmap='magma')
plt.xlabel('y mod 9'); plt.ylabel('x mod 9')
plt.title('Admissible residues (mid) and real fangs (bright)')
plt.colorbar(); plt.tight_layout(); plt.savefig('residue_heatmap.png', dpi=150)
