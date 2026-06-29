import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def hypercube_betti1(n):
    return n * 2**(n-1) - 2**n + 1 if n > 0 else 0

ns = list(range(1, 13))
bettis = [hypercube_betti1(n) for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Linear scale
ax1.bar(ns, bettis, color=['#2196F3' if b <= 1 else '#4CAF50' for b in bettis], edgecolor='black')
ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='k = 1 threshold')
ax1.set_xlabel('Hypercube dimension n')
ax1.set_ylabel('β₁ = logical qubits k')
ax1.set_title('Hypercube CSS Code: Logical Qubits vs Dimension')
ax1.legend()
ax1.set_xticks(ns)

# Log scale
ax2.semilogy(ns, bettis, 'o-', color='#4CAF50', markersize=8)
ax2.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='k = 1 threshold')
ax2.set_xlabel('Hypercube dimension n')
ax2.set_ylabel('β₁ (log scale)')
ax2.set_title('Exponential Growth of Logical Qubits')
ax2.legend()
ax2.set_xticks(ns)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('hypercube_betti_growth.png', dpi=150, bbox_inches='tight')
print('Saved hypercube_betti_growth.png')