import numpy as np
import matplotlib.pyplot as plt

phi = (1 + np.sqrt(5)) / 2
Ns = np.unique(np.logspace(0.5, 6, 200).astype(int))
rho = np.floor(Ns * phi) / Ns
fig, ax = plt.subplots(figsize=(9, 5))
ax.plot(Ns, rho, 'b.', ms=4, label=r'$\rho_N = \lfloor N\varphi\rfloor/N$')
ax.axhline(phi, color='k', lw=1, label=r'$\varphi$')
ax.plot(Ns, phi - 1/Ns, 'r--', lw=1, label=r'$\varphi - 1/N$')
ax.set_xscale('log'); ax.set_xlabel('N'); ax.set_ylabel('tile density')
ax.set_title('Beatty tile density converges to the golden ratio')
ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('density.png', dpi=150)
print('wrote density.png')
