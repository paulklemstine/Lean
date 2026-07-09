import math
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015329

def harmonic(n: int) -> float:
    return sum(1.0 / k for k in range(1, n + 1))

ns = list(range(1, 60))
a = [harmonic(n) - math.log(n + 1) for n in ns]
b = [harmonic(n) - math.log(n) for n in ns]
err_lo = [GAMMA - harmonic(n) + math.log(n + 1) for n in ns]
err_hi = [harmonic(n) - math.log(n) - GAMMA for n in ns]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(9, 9))
ax1.plot(ns, a, 'o-', label=r'$a_n = H_n - \ln(n+1)$', ms=3)
ax1.plot(ns, b, 's-', label=r'$b_n = H_n - \ln n$', ms=3)
ax1.axhline(GAMMA, color='k', ls='--', label=r'$\gamma$')
ax1.set_xlabel('n'); ax1.set_ylabel('value'); ax1.legend()
ax1.set_title('The bracket closes onto gamma')

ax2.loglog(ns, err_lo, 'o-', label=r'$\gamma - a_n$', ms=3)
ax2.loglog(ns, err_hi, 's-', label=r'$b_n - \gamma$', ms=3)
ax2.loglog(ns, [1.0 / n for n in ns], 'k--', label='1/n')
ax2.loglog(ns, [1.0 / (n + 1) for n in ns], 'k:', label='1/(n+1)')
ax2.set_xlabel('n'); ax2.set_ylabel('error'); ax2.legend()
ax2.set_title('Errors squeezed between 1/(n+1) and 1/n')

plt.tight_layout(); plt.savefig('gamma_convergence.png', dpi=150)
print('saved gamma_convergence.png')
