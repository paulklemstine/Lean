import math
import numpy as np
import matplotlib.pyplot as plt

R, C, L, rho, delta = 0.05, 8192*math.log(2), 1.6, 0.1, 0.05
ns = np.logspace(2, 9, 200)
robust = np.full_like(ns, L*rho)
penalty = np.sqrt((C + math.log(1/delta)) / (2*ns))
fig, ax = plt.subplots(figsize=(9, 5))
ax.stackplot(ns, robust, penalty,
             labels=['robustness term  L*rho',
                     'capacity penalty  sqrt((C+ln(1/d))/(2n))'],
             colors=['#d1495b', '#30638e'], alpha=0.85)
ax.set_xscale('log')
ax.set_xlabel('sample size n (log scale)')
ax.set_ylabel('excess over clean empirical risk R')
ax.set_title('Perturbed gap = robustness floor + vanishing capacity penalty')
ax.legend(loc='upper right')
ax.axhline(L*rho, ls='--', color='black', lw=1)
ax.text(1e7, L*rho*1.05, 'irreducible floor L*rho', fontsize=9)
plt.tight_layout()
plt.savefig('gap_decomposition.png', dpi=150)
print('saved gap_decomposition.png')
