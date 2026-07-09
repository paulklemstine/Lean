import random
import matplotlib.pyplot as plt

def tsha(h, m):
    return min(mi + hi for mi, hi in zip(m, h))

def sup_norm(m, mp):
    return max(abs(a - b) for a, b in zip(m, mp))

rng = random.Random(0)
k, xs, ys = 32, [], []
for _ in range(3000):
    h = [rng.uniform(-10, 10) for _ in range(k)]
    m = [rng.uniform(-10, 10) for _ in range(k)]
    mp = [rng.uniform(-10, 10) for _ in range(k)]
    xs.append(sup_norm(m, mp))
    ys.append(abs(tsha(h, m) - tsha(h, mp)))

lim = max(xs)
plt.figure(figsize=(6, 6))
plt.scatter(xs, ys, s=4, alpha=0.3, label="random pairs")
plt.plot([0, lim], [0, lim], "r-", label="y = x (Lipschitz bound)")
plt.xlabel(r"$\|m - m'\|_\infty$")
plt.ylabel(r"$|TSHA(h,m) - TSHA(h,m')|$")
plt.title("Tropical hash is 1-Lipschitz")
plt.legend()
plt.tight_layout()
plt.savefig("lipschitz_cloud.png", dpi=150)
print("saved lipschitz_cloud.png")
