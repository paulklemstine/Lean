"""Irwin-Hall density of a sum of n uniforms, built from Eulerian numbers."""
import numpy as np
import matplotlib.pyplot as plt
from math import comb, factorial

def eulerian(n: int, k: int) -> int:
    return int(sum((-1) ** i * comb(n + 1, i) * (k + 1 - i) ** n for i in range(k + 1)))

def irwin_hall_pdf(n: int, x: float) -> float:
    # f(x) = 1/(n-1)! * sum_{k=0}^{floor(x)} (-1)^k C(n,k) (x-k)^{n-1}, 0<=x<=n
    if x < 0 or x > n:
        return 0.0
    return sum((-1) ** k * comb(n, k) * (x - k) ** (n - 1)
               for k in range(int(np.floor(x)) + 1)) / factorial(n - 1)

fig, ax = plt.subplots(figsize=(7, 4.5))
for n in [1, 2, 3, 4, 5]:
    xs = np.linspace(0, n, 500)
    ax.plot(xs, [irwin_hall_pdf(n, x) for x in xs], label=f"n = {n}")
ax.set_title("Sums of n uniform[0,1] variables (piecewise-polynomial, Eulerian-governed)")
ax.set_xlabel("x"); ax.set_ylabel("density"); ax.legend()
plt.tight_layout(); plt.savefig("irwin_hall.png", dpi=150)
print("wrote irwin_hall.png  (Eulerian row for n=4: "
      + str([eulerian(4, k) for k in range(4)]) + ")")
