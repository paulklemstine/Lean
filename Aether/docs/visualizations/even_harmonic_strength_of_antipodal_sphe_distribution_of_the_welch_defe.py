"""Visualize the Welch defect of random antipodal sets vs. isotropic ones."""
import math, random
import matplotlib.pyplot as plt

def dot(x, y): return sum(a * b for a, b in zip(x, y))
def norm(v):
    s = math.sqrt(sum(c * c for c in v)); return [c / s for c in v]

def welch_defect(X, n):
    E = sum(dot(x, y) ** 2 for x in X for y in X)
    return E - len(X) ** 2 / n

def cross_polytope(n):
    P = []
    for i in range(n):
        e = [0.0] * n; e[i] = 1.0; P.append(e)
        f = [0.0] * n; f[i] = -1.0; P.append(f)
    return P

n = 3
defects = []
for seed in range(200):
    rng = random.Random(seed)
    pairs = [norm([rng.gauss(0, 1) for _ in range(n)]) for _ in range(3)]
    X = pairs + [[-c for c in v] for v in pairs]
    defects.append(welch_defect(X, n))

plt.figure(figsize=(7, 4))
plt.hist(defects, bins=30, color="#4C72B0", alpha=0.85)
plt.axvline(welch_defect(cross_polytope(n), n), color="crimson",
            linewidth=2, label="cross-polytope (defect = 0)")
plt.xlabel("Welch defect  E(X) - |X|^2/n")
plt.ylabel("count")
plt.title("Welch defect of random antipodal sets (n=3)")
plt.legend(); plt.tight_layout(); plt.savefig("welch_defect_hist.png", dpi=150)
print("saved welch_defect_hist.png")
