"""Visualization: digit-length conservation vs generic products."""
import matplotlib.pyplot as plt
from typing import List


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out


def dlen(b: int, n: int) -> int:
    return len(digits(b, n))


def shares_all_digits(b: int, x: int, y: int) -> bool:
    return sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, x * y))


gen_short = gen_full = shar = 0
for x in range(10, 100):
    for y in range(x, 100):
        full = dlen(10, x) + dlen(10, y)
        if dlen(10, x * y) == full:
            gen_full += 1
        else:
            gen_short += 1
        if shares_all_digits(10, x, y) and dlen(10, x * y) == full:
            shar += 1

plt.figure(figsize=(6, 4))
plt.bar(["generic\nlen = m+n", "generic\nlen = m+n-1", "digit-sharing\n(all len=m+n)"],
        [gen_full, gen_short, shar],
        color=["#4c72b0", "#c44e52", "#55a868"])
plt.ylabel("count of factor pairs (2-digit x 2-digit)")
plt.title("Digit-sharing products never lose a digit")
plt.tight_layout(); plt.savefig("length_conservation.png", dpi=120)
print("wrote length_conservation.png")
