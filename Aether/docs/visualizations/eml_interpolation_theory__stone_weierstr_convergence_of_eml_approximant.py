from __future__ import annotations
import math
from typing import Callable, List
import matplotlib.pyplot as plt

def pw_lin_interp(f: Callable[[float], float], n: int, x: float) -> float:
    k = min(n - 1, math.floor(n * x)); a = k / n; b = (k + 1) / n
    return f(a) + (f(b) - f(a)) / (b - a) * (x - a)

def eml_quad_approx(h: float, x: float) -> float:
    return (2.0 / h ** 2) * (math.exp(h * x) - 1.0 - h * x)

def sup_err(approx, target, g=2001):
    return max(abs(approx(i/(g-1)) - target(i/(g-1))) for i in range(g))

xs = [i / 1000 for i in range(1001)]
f = lambda x: abs(x - 1.0/3.0)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.plot(xs, [f(x) for x in xs], 'k-', lw=2, label='f(x)=|x-1/3|')
for n in (2, 4, 8):
    ax1.plot(xs, [pw_lin_interp(f, n, x) for x in xs], '--', label=f'n={n}')
ax1.set_title('Piecewise-linear EML interpolant'); ax1.legend()
ns = [2**k for k in range(0, 9)]
sq = lambda x: x*x
pwl = [sup_err(lambda x: pw_lin_interp(sq, n, x), sq) for n in ns]
smo = [sup_err(lambda x: eml_quad_approx(1.0/n, x), sq) for n in ns]
ax2.loglog(ns, pwl, 'o-', label='pw-linear error')
ax2.loglog(ns, [2.0/n for n in ns], 'k:', label='bound 2/n')
ax2.loglog(ns, smo, 's-', label='single-exp error')
ax2.loglog(ns, [4.0/(9*n) for n in ns], 'r:', label='bound 4/(9n)')
ax2.set_xlabel('width n'); ax2.set_ylabel('sup error')
ax2.set_title('Jackson rate O(1/n) for x^2'); ax2.legend()
plt.tight_layout(); plt.savefig('eml_convergence.png', dpi=150)
print('saved eml_convergence.png')
