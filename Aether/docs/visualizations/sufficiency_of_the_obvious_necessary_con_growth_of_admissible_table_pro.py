"""Bar chart of the number of admissible table profiles as a function of the
number of couples n. Requires matplotlib."""
from __future__ import annotations
from typing import List, Tuple
import matplotlib.pyplot as plt


def admissible(n: int, max_tables: int = 3) -> List[Tuple[int, List[int]]]:
    total = 2 * n * (n - 1)
    out = []
    def rec(start: int, cur: List[int]) -> None:
        if cur:
            s = n - sum(cur)
            if s >= 0 and all(mi >= 2 and total % mi == 0 for mi in cur):
                out.append((s, list(cur)))
        if len(cur) >= max_tables:
            return
        for mi in range(start, n - sum(cur) + 1):
            if mi >= 2:
                rec(mi, cur + [mi])
    rec(2, [])
    return out


if __name__ == "__main__":
    ns = list(range(4, 13))
    counts = [len(admissible(n)) for n in ns]
    plt.bar(ns, counts, color="teal")
    plt.xlabel("number of couples n"); plt.ylabel("admissible profiles")
    plt.title("Admissible table profiles vs n (up to 3 round tables)")
    plt.tight_layout(); plt.savefig("profiles.png", dpi=150)
    print("wrote profiles.png")
