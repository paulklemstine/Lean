import numpy as np
import matplotlib.pyplot as plt
from math import comb, log

def q_ary_entropy(rho: float, q: int) -> float:
    if rho <= 0.0: return 0.0
    if rho >= 1.0: return log(q - 1, q)
    return rho*log(q-1,q) - rho*log(rho,q) - (1-rho)*log(1-rho,q)

def ball_volume(n: int, q: int, r: int) -> int:
    return sum(comb(n, i) * (q - 1) ** i for i in range(r + 1))

q = 2
rhos = np.linspace(0.001, 0.5, 200)
Hq = [q_ary_entropy(r, q) for r in rhos]

plt.figure(figsize=(9, 5))
plt.plot(rhos, Hq, 'k-', lw=2, label=r'$H_q(\rho)$ (limit)')
for n in (16, 64, 256):
    emp = [log(ball_volume(n, q, int(r*n)), q)/n for r in rhos if int(r*n) >= 1]
    rr = [r for r in rhos if int(r*n) >= 1]
    plt.plot(rr, emp, '--', label=fr'$(1/n)\log_q|B_{{\rho n}}|,\ n={n}$')
plt.xlabel(r'relative radius $\rho$'); plt.ylabel('normalized log-volume')
plt.title('Hamming-ball volume converges to the q-ary entropy (q=2)')
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig('entropy_threshold.png', dpi=150)
print('saved entropy_threshold.png')
