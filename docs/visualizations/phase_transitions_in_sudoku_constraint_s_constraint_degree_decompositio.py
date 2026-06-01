import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def sudoku_degree(n): return 3*n**2 - 2*n - 1
def latin_degree(n): return 2*(n**2 - 1)
def box_extra(n): return (n-1)**2

ns = np.arange(2, 20)
fig, ax = plt.subplots(figsize=(10, 6))
ax.bar(ns-0.2, [latin_degree(n) for n in ns], 0.4, label='Latin Square', color='#2196F3')
ax.bar(ns+0.2, [box_extra(n) for n in ns], 0.4, bottom=[latin_degree(n) for n in ns], label='Box Extra', color='#FF5722')
ax.plot(ns, [sudoku_degree(n) for n in ns], 'ko-', label='Sudoku Total')
ax.set_xlabel('Box size n'); ax.set_ylabel('Constraint Degree')
ax.set_title('Sudoku = Latin Square + Box Constraints'); ax.legend()
plt.tight_layout(); plt.savefig('viz_degree_decomposition.png', dpi=150)