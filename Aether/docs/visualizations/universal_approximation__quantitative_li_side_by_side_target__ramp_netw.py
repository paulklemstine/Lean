import math
import numpy as np
import matplotlib.pyplot as plt

def relu(x):
    return np.maximum(x, 0.0)

def net(f, n, x):
    total = np.full_like(x, f(0.0))
    for k in range(n):
        s = n * (f((k + 1) / n) - f(k / n))
        total = total + s * (relu(x - k / n) - relu(x - (k + 1) / n))
    return total

def sup_error(f, n, m=4001):
    xs = np.linspace(0, 1, m)
    return float(np.max(np.abs(net(f, n, xs) - f(xs))))

xs = np.linspace(0, 1, 1000)
lip = lambda x: np.abs(x - 1.0 / 3.0)
smo = lambda x: x ** 2
fig, ax = plt.subplots(1, 3, figsize=(15, 4))
n = 8
ax[0].plot(xs, lip(xs), 'k-', label='f(x)=|x-1/3|')
ax[0].plot(xs, net(lip, n, xs), 'r--', label=f'network n={n}')
ax[0].set_title('Lipschitz target (rate L/n)'); ax[0].legend()
ax[1].plot(xs, smo(xs), 'k-', label='f(x)=x^2')
ax[1].plot(xs, net(smo, n, xs), 'b--', label=f'network n={n}')
ax[1].set_title('Smooth target (rate M/n^2)'); ax[1].legend()
ns = [4, 8, 16, 32, 64, 128, 256]
el = [sup_error(lip, k) for k in ns]
es = [sup_error(smo, k) for k in ns]
ax[2].loglog(ns, el, 'ro-', label='|x-1/3| (slope ~ -1)')
ax[2].loglog(ns, es, 'bo-', label='x^2 (slope ~ -2)')
ax[2].set_xlabel('n'); ax[2].set_ylabel('sup error')
ax[2].set_title('Convergence rates'); ax[2].legend()
plt.tight_layout(); plt.savefig('rates.png', dpi=150)
print('wrote rates.png')
