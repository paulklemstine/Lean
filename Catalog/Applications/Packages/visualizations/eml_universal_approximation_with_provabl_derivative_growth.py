import matplotlib.pyplot as plt
import math

def iterated_exp(n, x):
    val = x
    for _ in range(n): val = math.exp(min(val, 700))
    return val

ns = range(1, 8)
xs = [0.0, 0.5, 1.0]
fig, ax = plt.subplots(figsize=(10, 6))
for x in xs:
    vals = []
    for n in ns:
        prod = 1.0; v = x
        for k in range(n): prod *= math.exp(v); v = math.exp(min(v, 700))
        vals.append(min(prod, 1e300))
    ax.semilogy(list(ns), vals, 'o-', lw=2, label=f'x={x}')
ax.set_xlabel('n (depth)'); ax.set_ylabel('|d/dx[exp^n(x)]|')
ax.set_title('Derivative Product Formula'); ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('deriv_growth.png', dpi=150); plt.close()