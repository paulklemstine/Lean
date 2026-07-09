"""Bar chart of the number of d-balanced partitions of n (d=2, e=3)."""
from typing import List, Iterator
import matplotlib.pyplot as plt


def partitions(n: int) -> Iterator[List[int]]:
    def gen(n: int, cap: int) -> Iterator[List[int]]:
        if n == 0:
            yield []
            return
        for first in range(min(n, cap), 0, -1):
            for rest in gen(n - first, first):
                yield [first] + rest
    yield from gen(n, n)


def conjugate(lam: List[int]) -> List[int]:
    if not lam:
        return []
    return [sum(1 for p in lam if p > j) for j in range(lam[0])]


def is_d_balanced(lam: List[int], d: int, e: int) -> bool:
    conj = conjugate(lam)
    for i, part in enumerate(lam):
        for j in range(part):
            arm = lam[i] - (j + 1)
            leg = conj[j] - (i + 1)
            if (arm + leg + 1) % e == 0 and arm % d != 0:
                return False
    return True


def is_leg_d_balanced(lam: List[int], d: int, e: int) -> bool:
    conj = conjugate(lam)
    for i, part in enumerate(lam):
        for j in range(part):
            arm = lam[i] - (j + 1)
            leg = conj[j] - (i + 1)
            if (arm + leg + 1) % e == 0 and leg % d != 0:
                return False
    return True


d, e, N = 2, 3, 20
ns = list(range(N + 1))
arm_counts = [sum(is_d_balanced(l, d, e) for l in partitions(n)) for n in ns]
leg_counts = [sum(is_leg_d_balanced(l, d, e) for l in partitions(n)) for n in ns]

fig, ax = plt.subplots(figsize=(10, 5))
w = 0.4
ax.bar([n - w / 2 for n in ns], arm_counts, width=w, label="d-balanced")
ax.bar([n + w / 2 for n in ns], leg_counts, width=w, label="leg-d-balanced")
ax.set_xlabel("n = size of partition")
ax.set_ylabel("count")
ax.set_title(f"Conjugation bijection: #d-balanced = #leg-d-balanced  (d={d}, e={e})")
ax.legend()
plt.tight_layout()
plt.savefig("balance_counts.png", dpi=150)
print("wrote balance_counts.png")
