import matplotlib.pyplot as plt
import numpy as np

ns = np.arange(5, 201, 5)
gaps = 1 - np.cos(2*np.pi/ns)
epsilon = 0.01

classical = (1/gaps) * (np.log(ns) + np.log(1/epsilon))
quantum = np.sqrt(1/gaps) * (np.log(ns) + np.log(1/epsilon))
speedup = classical / quantum

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.loglog(ns, classical, 'r-', linewidth=2, label='Classical')
ax1.loglog(ns, quantum, 'b-', linewidth=2, label='Quantum')
ax1.set_xlabel('Group size n', fontsize=14)
ax1.set_ylabel('Mixing time', fontsize=14)
ax1.set_title('Mixing Times on Cyclic Groups', fontsize=16)
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3)

ax2.plot(ns, speedup, 'g-', linewidth=2, label=r'$\sqrt{1/\gamma}$')
ax2.plot(ns, np.sqrt(1/gaps), 'k--', linewidth=1, label='Theoretical')
ax2.set_xlabel('Group size n', fontsize=14)
ax2.set_ylabel('Speedup ratio', fontsize=14)
ax2.set_title('Quantum Speedup Ratio', fontsize=16)
ax2.legend(fontsize=12)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_times.png', dpi=150)
plt.show()