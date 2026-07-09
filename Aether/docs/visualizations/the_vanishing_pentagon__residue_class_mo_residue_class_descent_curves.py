"""Line plot of the five residue-class threads k -> sigma5(5k+r)."""
import cmath, math
from itertools import product
import matplotlib.pyplot as plt

ZETA = cmath.exp(2j * math.pi / 5)

def sigma5(n):
    best = math.inf
    for c in product(range(n + 1), repeat=5):
        if sum(c) == n:
            best = min(best, abs(sum(a * ZETA ** r for r, a in enumerate(c))))
    return best

KMAX = 3
plt.figure(figsize=(7, 5))
for r in range(5):
    ks = list(range(KMAX + 1))
    ys = [sigma5(5 * k + r) for k in ks]
    plt.plot(ks, ys, marker="o", label=f"r={r}")
plt.xlabel("k"); plt.ylabel("sigma5(5k + r)")
plt.title("Residue-class monotonicity of sigma5")
plt.legend(); plt.grid(True, alpha=0.3)
plt.savefig("residue_threads.png", dpi=150)
