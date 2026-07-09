import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def expected_isolated(n: int, p: float) -> float:
    return n * (1.0 - p) ** (n - 1)

def expected_triangles(n: int, p: float) -> float:
    return math.comb(n, 3) * p ** 3

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

for n in (100, 1000, 10000):
    ps = np.linspace(0.2 * math.log(n) / n, 3 * math.log(n) / n, 400)
    ax1.plot(ps * n / math.log(n),
             [expected_isolated(n, p) for p in ps], label=f'n={n}')
ax1.axhline(1.0, color='k', ls=':', lw=1)
ax1.set_xlabel('p / (ln n / n)')
ax1.set_ylabel('E[# isolated vertices]')
ax1.set_title('Connectivity threshold p = ln(n)/n')
ax1.legend()

for n in (100, 1000, 10000):
    factors = np.linspace(0.1, 4.0, 400)
    ax2.plot(factors,
             [expected_triangles(n, f / n) for f in factors], label=f'n={n}')
ax2.axhline(1.0, color='k', ls=':', lw=1)
ax2.set_xlabel('n p')
ax2.set_ylabel('E[# triangles]')
ax2.set_title('Triangle / giant-component scale p = 1/n')
ax2.legend()

fig.tight_layout()
fig.savefig('erdos_renyi_thresholds.png', dpi=150)
print('wrote erdos_renyi_thresholds.png')
