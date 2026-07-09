import matplotlib.pyplot as plt
from functools import reduce
from math import comb, gcd
from typing import Dict

def binom_gcd(k: int) -> int:
    return reduce(gcd, (comb(q * k, k) for q in range(2, k + 2)))

def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}; d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1; n //= d
        d += 1
    if n > 1: f[n] = f.get(n, 0) + 1
    return f

def stephan_P(n: int) -> int:
    return max((p ** a for p, a in factorize(n).items()), default=1)

def ilog(p: int, m: int) -> int:
    e = 0
    while m >= 1 and p ** (e + 1) <= m: e += 1
    return e

def corrected(k: int) -> int:
    n = k + 1; best = 1
    for p, a in factorize(n).items():
        m = n // (p ** a)
        best = max(best, p ** max(0, a - ilog(p, m)))
    return best

ks = list(range(2, 61))
D = [binom_gcd(k) for k in ks]
S = [stephan_P(k + 1) for k in ks]
C = [corrected(k) for k in ks]
fails = [k for k in ks if stephan_P(k + 1) != binom_gcd(k)]

plt.figure(figsize=(11, 6))
plt.plot(ks, S, 'o--', color='crimson', label='Stephan P(k+1)', alpha=0.7)
plt.plot(ks, C, 's-', color='steelblue', label='corrected formula', alpha=0.7)
plt.plot(ks, D, 'k.', label='true D(k)')
for k in fails:
    plt.axvline(k, color='gray', lw=0.5, alpha=0.4)
plt.scatter(fails, [stephan_P(k + 1) for k in fails], color='crimson',
            s=90, facecolors='none', label='Stephan failures')
plt.yscale('log')
plt.xlabel('k'); plt.ylabel('value (log scale)')
plt.title('Binomial GCD A080170: D(k) vs Stephan vs corrected law')
plt.legend(); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('a080170_comparison.png', dpi=150)
print('saved a080170_comparison.png')
