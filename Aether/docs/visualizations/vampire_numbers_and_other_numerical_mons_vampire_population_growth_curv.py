"""Visualization: vampire counts per even digit-length."""
import matplotlib.pyplot as plt
from typing import List, Tuple


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out


def shares_all_digits(b: int, x: int, y: int) -> bool:
    return sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, x * y))


def vampires(k: int) -> int:
    lo, hi = 10 ** (k - 1), 10 ** k - 1
    found = set()
    for x in range(lo, hi + 1):
        if x % 3 == 1:
            continue
        for y in range(x, hi + 1):
            if y % 3 == 1 or (x % 10 == 0 and y % 10 == 0):
                continue
            v = x * y
            if (x + y) % 9 != v % 9:
                continue
            if shares_all_digits(10, x, y):
                found.add(v)
    return len(found)


ks: List[int] = [1, 2, 3]
counts: List[int] = [vampires(k) for k in ks]
plt.figure(figsize=(6, 4))
plt.plot([2 * k for k in ks], counts, "o-")
plt.xlabel("number of digits of vampire (2k)")
plt.ylabel("count of vampires")
plt.title("Growth of the vampire population")
plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("vampire_growth.png", dpi=120)
print("wrote vampire_growth.png")
