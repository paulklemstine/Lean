"""How far (a^n+1)(b^n+1) sits above the nearest perfect square below it."""
import matplotlib.pyplot as plt
from math import gcd, isqrt

def gap_to_square(N: int) -> int:
    r = isqrt(N)
    return N - r * r  # 0 would mean N is a perfect square

xs, ys, cs = [], [], []
for a in range(2, 40):
    for b in range(a + 1, 40):
        if gcd(a, b) != 1:
            continue
        for n in (3, 5, 7, 9):
            N = (a**n + 1) * (b**n + 1)
            xs.append(a + b)
            ys.append(gap_to_square(N) / (2 * isqrt(N) + 1))  # normalized gap in [0,1)
            cs.append(n)

plt.figure(figsize=(8, 5))
sc = plt.scatter(xs, ys, c=cs, cmap="viridis", s=10, alpha=0.6)
plt.colorbar(sc, label="odd exponent n")
plt.xlabel("a + b"); plt.ylabel("normalized distance to nearest lower square")
plt.title("Products never land on a square (normalized gap > 0)")
plt.tight_layout()
plt.savefig("square_gap.png", dpi=150)
print("saved square_gap.png")
