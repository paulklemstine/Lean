"""Visualization: growth of p(n) = the size of the S_n character table."""
import matplotlib.pyplot as plt
from typing import List, Tuple

Partition = Tuple[int, ...]


def partitions(n: int, max_part: int = None) -> List[Partition]:
    if max_part is None:
        max_part = n
    if n == 0:
        return [()]
    out = []
    for k in range(min(n, max_part), 0, -1):
        for rest in partitions(n - k, k):
            out.append((k,) + rest)
    return out


ns = list(range(1, 16))
pn = [len(partitions(n)) for n in ns]

fig, ax = plt.subplots(figsize=(9, 5))
ax.plot(ns, pn, "o-", color="#2a6fdb", lw=2, ms=7)
for n in (3, 4, 5):
    ax.annotate(f"p({n})={len(partitions(n))}", (n, len(partitions(n))),
                textcoords="offset points", xytext=(6, 10), fontsize=11,
                color="#b8002e")
ax.set_title("Size of the S_n character table = p(n) (number of partitions of n)")
ax.set_xlabel("n")
ax.set_ylabel("p(n)  =  rows = columns of the character table of S_n")
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("partition_growth.png", dpi=150)
print("wrote partition_growth.png")
