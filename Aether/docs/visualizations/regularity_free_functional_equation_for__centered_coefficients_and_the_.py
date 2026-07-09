import matplotlib.pyplot as plt
from typing import List

def centered(n: int) -> List[int]:
    return [2 * i + 1 - n for i in range(n)]

def period_exp(lam: List[int]) -> int:
    n = len(lam)
    return sum((2 * i + 1 - n) * lam[i] for i in range(n))

def moment(lam: List[int]) -> int:
    return sum(i * lam[i] for i in range(len(lam)))

def twist(k: int, lam: List[int]) -> List[int]:
    return [x + k for x in lam]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
for n in (3, 5, 7):
    ax1.plot(range(n), centered(n), marker='o', label=f'n={n} (sum={sum(centered(n))})')
ax1.axhline(0, color='gray', lw=0.8)
ax1.set_title('Centered coefficients c_i = 2i+1-n')
ax1.set_xlabel('index i'); ax1.set_ylabel('coefficient'); ax1.legend()

L = [4, 2, -1, -3, -5]
ks = list(range(-8, 9))
ax2.plot(ks, [period_exp(twist(k, L)) for k in ks], marker='o', label='centered e (invariant)')
ax2.plot(ks, [moment(twist(k, L)) for k in ks], marker='s', label='uncentered moment (drifts)')
ax2.set_title('Twist sweep for L = ' + str(L))
ax2.set_xlabel('twist k'); ax2.set_ylabel('value'); ax2.legend()

plt.tight_layout(); plt.savefig('betti_whittaker_invariance.png', dpi=150)
print('wrote betti_whittaker_invariance.png')
