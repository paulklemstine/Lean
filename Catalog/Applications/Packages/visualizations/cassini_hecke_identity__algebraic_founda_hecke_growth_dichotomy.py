import matplotlib.pyplot as plt
import numpy as np

def hecke_seq(a, q, n):
    if n == 0: return 1
    if n == 1: return a
    h0, h1 = 1, a
    for _ in range(2, n + 1):
        h0, h1 = h1, a * h1 - q * h0
    return h1

fig, ax = plt.subplots(figsize=(10, 6))
ns = list(range(20))
for a, q, label in [(2,1,'boundary a²=4q'), (2,2,'Ramanujan'), (3,1,'non-Ramanujan'), (1,-1,'Fibonacci')]:
    vals = [abs(hecke_seq(a, q, n)) for n in ns]
    ax.semilogy(ns, [max(v, 0.1) for v in vals], 'o-', label=f'{label} (a={a},q={q})', markersize=4)
ax.set_xlabel('n'); ax.set_ylabel('|h(n)|'); ax.set_title('Hecke Sequence Growth Dichotomy')
ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('growth_dichotomy.png', dpi=150); plt.close()