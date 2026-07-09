"""Bar chart of Gegenbauer moments Q_k(X) showing odd moments vanish."""
import math, random
import matplotlib.pyplot as plt

def dot(x, y): return sum(a * b for a, b in zip(x, y))
def gegenbauer(k, t, n):
    lam = (n - 2) / 2.0
    if k == 0: return 1.0
    if k == 1: return 2.0 * lam * t
    c0, c1 = 1.0, 2.0 * lam * t
    for m in range(2, k + 1):
        c2 = (2 * (m - 1 + lam) * t * c1 - (m - 2 + 2 * lam) * c0) / m
        c0, c1 = c1, c2
    return c1

n = 3
rng = random.Random(5)
pairs = []
for _ in range(5):
    v = [rng.gauss(0, 1) for _ in range(n)]
    s = math.sqrt(sum(c * c for c in v)); v = [c / s for c in v]
    pairs.append(v)
X = pairs + [[-c for c in v] for v in pairs]

ks = list(range(0, 8))
Q = [sum(gegenbauer(k, dot(x, y), n) for x in X for y in X) for k in ks]
colors = ["#55A868" if k % 2 == 0 else "#C44E52" for k in ks]
plt.figure(figsize=(7, 4))
plt.bar([str(k) for k in ks], Q, color=colors)
plt.axhline(0, color="black", linewidth=0.8)
plt.xlabel("degree k"); plt.ylabel("Gegenbauer moment Q_k(X)")
plt.title("Odd moments (red) vanish; even moments (green) carry content")
plt.tight_layout(); plt.savefig("gegenbauer_moments.png", dpi=150)
print("saved gegenbauer_moments.png")
