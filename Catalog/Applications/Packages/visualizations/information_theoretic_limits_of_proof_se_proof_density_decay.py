import math
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available')
    exit()
ns = list(range(1, 51))
V = 1000
b = 2
densities = [V / (b ** n) for n in ns]
fig, ax = plt.subplots(figsize=(10, 6))
ax.semilogy(ns, densities, 'g-^', linewidth=2)
ax.set_xlabel('Proof length n')
ax.set_ylabel('Proof density (log scale)')
ax.set_title('Proof Density Exponential Decay')
ax.grid(True, alpha=0.3)
plt.savefig('density_decay.png', dpi=150)
print('Saved density_decay.png')