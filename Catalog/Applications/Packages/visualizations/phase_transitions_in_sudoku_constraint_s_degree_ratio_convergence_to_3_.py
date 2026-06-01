import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def ratio(n): return (3*n**2 - 2*n - 1) / (2*(n**2 - 1))

ns = np.arange(2, 200)
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(ns, [ratio(n) for n in ns], 'b-', linewidth=2)
ax.axhline(y=1.5, color='r', linestyle='--', label='Limit = 3/2')
ax.set_xlabel('n'); ax.set_ylabel('Degree Ratio')
ax.set_title('Sudoku/Latin Degree Ratio → 3/2'); ax.legend()
plt.tight_layout(); plt.savefig('viz_ratio_convergence.png', dpi=150)