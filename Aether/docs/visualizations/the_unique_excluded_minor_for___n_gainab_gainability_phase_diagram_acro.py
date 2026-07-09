import matplotlib.pyplot as plt
import numpy as np

N_MAX, K_MAX = 10, 12
grid = np.zeros((K_MAX, N_MAX))
for n in range(1, N_MAX + 1):
    for k in range(1, K_MAX + 1):
        grid[k - 1, n - 1] = 1.0 if k <= n else 0.0

fig, ax = plt.subplots(figsize=(7, 7))
ax.imshow(grid, origin='lower', cmap='RdYlGn', extent=[0.5, N_MAX + 0.5, 0.5, K_MAX + 0.5], aspect='auto')
xs = np.arange(0.5, N_MAX + 1.5)
ax.plot(xs, xs, 'b--', lw=2, label='threshold k = n')
ax.plot(xs, xs + 1, 'k-', lw=2, label='excluded minor (n+1)K2')
ax.set_xlabel('clock size n  (group Z/n)')
ax.set_ylabel('number of parallel edges k')
ax.set_title('Z/n-gainability of the parallel class kK2')
ax.legend(loc='lower right')
plt.tight_layout()
plt.savefig('gainability_phase_diagram.png', dpi=150)
print('wrote gainability_phase_diagram.png')