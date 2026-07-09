import numpy as np
import matplotlib.pyplot as plt

d = np.arange(1, 41)
linear = 2 * (d - 1)
plateau = np.full_like(d, 28)
envelope = np.maximum(plateau, linear)

plt.figure(figsize=(8, 5))
plt.plot(d, plateau, '--', label='constant plateau = 28')
plt.plot(d, linear, '--', label='linear term = 2(d-1)')
plt.plot(d, envelope, lw=3, label='max(28, 2(d-1))')
plt.axvline(15, color='gray', ls=':', label='crossover d = 15')
plt.scatter([15], [28], zorder=5)
plt.xlabel('dimension d')
plt.ylabel('bound on number of equiangular 1/3 lines')
plt.title('N_{1/3}(d) <= max(28, 2(d-1))')
plt.legend()
plt.tight_layout()
plt.savefig('balla_crossover.png', dpi=150)
print('saved balla_crossover.png')
