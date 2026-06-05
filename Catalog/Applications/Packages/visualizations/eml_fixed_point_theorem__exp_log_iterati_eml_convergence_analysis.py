import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def eml_op(a, c, x):
    return math.exp(a) * math.log(x + c)

def iterate_eml(a, c, x0, n):
    h = [x0]
    x = x0
    for _ in range(n):
        x = eml_op(a, c, x)
        h.append(x)
    return h

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('EML Fixed-Point Iteration', fontsize=16)
a, c = 0.5, 3.0
xs = iterate_eml(a, c, 1.0, 200)
xstar = xs[-1]
for x0 in [0.5, 2.0, 5.0, 15.0]:
    h = iterate_eml(a, c, x0, 30)
    errs = [max(abs(v - xstar), 1e-16) for v in h]
    axes[0,0].semilogy(errs, 'o-', ms=3, label=f'x0={x0}')
K = math.exp(a)/c
axes[0,0].semilogy([30*K**n for n in range(31)], 'k--', alpha=0.5, label=f'K^n')
axes[0,0].set_title('Convergence')
axes[0,0].legend(fontsize=8)
axes[0,0].grid(True, alpha=0.3)
xr = np.linspace(0, 5, 200)
yr = [eml_op(a, c, x) for x in xr]
axes[0,1].plot(xr, yr, 'b-', lw=2)
axes[0,1].plot(xr, xr, 'k--')
axes[0,1].plot(xstar, xstar, 'ro', ms=8)
axes[0,1].set_title('Cobweb')
axes[0,1].grid(True, alpha=0.3)
ar = np.linspace(0.01, 2.5, 200)
for cv in [2, 3, 5, 10]:
    axes[1,0].plot(ar, [math.exp(av)/cv for av in ar], label=f'c={cv}')
axes[1,0].axhline(1, color='r', ls='--')
axes[1,0].set_title('K vs a')
axes[1,0].set_ylim(0, 3)
axes[1,0].legend(fontsize=8)
axes[1,0].grid(True, alpha=0.3)
av2 = np.linspace(0.01, 1.08, 100)
fps = []
for av in av2:
    h = iterate_eml(av, 3.0, 1.0, 500)
    fps.append(h[-1])
axes[1,1].plot(av2, fps, 'b-', lw=2)
axes[1,1].set_title('Fixed point vs a')
axes[1,1].grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('eml_convergence.png', dpi=150)
print('Saved eml_convergence.png')