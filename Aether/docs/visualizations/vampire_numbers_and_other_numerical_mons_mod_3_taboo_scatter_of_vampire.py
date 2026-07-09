"""Visualization: mod-3 taboo scatter of vampire fangs."""
import matplotlib.pyplot as plt
from typing import List, Tuple


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out


def shares_all_digits(b: int, x: int, y: int) -> bool:
    return sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, x * y))


xs: List[int] = []
ys: List[int] = []
for x in range(10, 100):
    for y in range(x, 100):
        if x % 10 == 0 and y % 10 == 0:
            continue
        if shares_all_digits(10, x, y):
            xs.append(x % 3); ys.append(y % 3)

plt.figure(figsize=(6, 6))
plt.scatter([v + 0.1 for v in xs], [v + 0.1 for v in ys], alpha=0.5)
plt.xticks([0, 1, 2]); plt.yticks([0, 1, 2])
plt.xlabel("x mod 3"); plt.ylabel("y mod 3")
plt.title("Vampire fangs never land on residue 1 (mod 3)")
plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("taboo_scatter.png", dpi=120)
print("wrote taboo_scatter.png")
