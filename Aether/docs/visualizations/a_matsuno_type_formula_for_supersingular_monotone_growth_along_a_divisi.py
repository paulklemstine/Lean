"""Step plot showing monotone growth of Lambda along a chain of nested levels."""
import matplotlib.pyplot as plt
from typing import Callable, List


def v2(n: int) -> int:
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def prime_factors(n: int) -> List[int]:
    out: List[int] = []
    d, m = 2, n
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def local_term(ell: int, conductor: int, order: Callable[[int], int]) -> int:
    depth = v2((ell * ell - 1) // 8)
    if conductor % ell == 0:
        return 2 ** depth
    if order(ell) % 2 == 0:
        return 2 ** (depth + 1)
    return 0


def lam(D: int, conductor: int, order: Callable[[int], int]) -> int:
    return sum(local_term(ell, conductor, order) for ell in prime_factors(D)) if D > 1 else 0


conductor, order = 10, (lambda ell: ell - 1)
chain = [1, 3, 3 * 7, 3 * 7 * 17, 3 * 7 * 17 * 31, 3 * 7 * 17 * 31 * 127]
vals = [lam(d, conductor, order) for d in chain]
plt.figure(figsize=(9, 5))
plt.step(range(len(chain)), vals, where="post", marker="o", color="#3b6ea5")
plt.xticks(range(len(chain)), [str(d) for d in chain], rotation=30)
plt.xlabel("level d (nested tower)")
plt.ylabel("Lambda(d)")
plt.title("Monotone growth of the invariant along a divisibility tower")
plt.tight_layout()
plt.savefig("monotone_tower.png", dpi=150)
print("wrote monotone_tower.png")
