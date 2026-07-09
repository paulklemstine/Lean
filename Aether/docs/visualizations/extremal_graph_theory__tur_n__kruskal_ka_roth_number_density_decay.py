import matplotlib.pyplot as plt
from itertools import combinations
from typing import FrozenSet

def is_three_ap_free(s: FrozenSet[int]) -> bool:
    for b in s:
        for a in s:
            if a != b and (2 * b - a) in s and (2 * b - a) != b:
                return False
    return True

def roth_number(n: int) -> int:
    for size in range(n, 0, -1):
        for combo in combinations(range(n), size):
            if is_three_ap_free(frozenset(combo)):
                return size
    return 0

Ns = list(range(1, 20))
dens = [roth_number(N) / N for N in Ns]
plt.figure(figsize=(8, 5))
plt.plot(Ns, dens, 'o-', color='crimson')
plt.xlabel('N'); plt.ylabel('r_3(N) / N')
plt.title("Roth's theorem: maximal 3-AP-free density decays to 0")
plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('roth_density.png', dpi=150)
print('saved roth_density.png')
