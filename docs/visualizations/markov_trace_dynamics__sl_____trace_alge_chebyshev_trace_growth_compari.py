import matplotlib.pyplot as plt
import math

def cheb_trace(t, n):
    if n == 0: return 2
    if n == 1: return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b

fig, ax = plt.subplots(1, 1, figsize=(10, 6))
ns = list(range(12))
for t in [3, 4, 5, 7]:
    vals = [cheb_trace(t, n) for n in ns]
    bounds = [(t-1)**n for n in ns]
    ax.semilogy(ns, vals, 'o-', label=f't={t}: chebTrace')
    ax.semilogy(ns, bounds, '--', alpha=0.5, label=f't={t}: (t-1)^n bound')
ax.set_xlabel('n', fontsize=14)
ax.set_ylabel('Value (log scale)', fontsize=14)
ax.set_title('Chebyshev Trace Sequence: Exponential Growth', fontsize=16)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('chebyshev_growth.png', dpi=150)
plt.show()