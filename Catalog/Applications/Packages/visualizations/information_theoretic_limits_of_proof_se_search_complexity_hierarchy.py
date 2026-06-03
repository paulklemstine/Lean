import math
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available')
    exit()
ks = list(range(0, 16))
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(ks, [k+1 for k in ks], 'k--', linewidth=2, label='k+1 (linear)')
for b, c in [(2,'blue'),(3,'red'),(5,'green')]:
    ax.semilogy(ks, [b**k for k in ks], f'-o', color=c, linewidth=2, label=f'b^k (b={b})')
ax.set_xlabel('Level k')
ax.set_ylabel('Complexity (log scale)')
ax.set_title('Search Complexity Hierarchy')
ax.legend()
ax.grid(True, alpha=0.3)
plt.savefig('hierarchy.png', dpi=150)
print('Saved hierarchy.png')