"""Visualization: the Donsker-Varadhan landscape.

For a fixed reference law P and observable phi, scatter the objective
int^+ phi dQ - D(Q||P) for many random candidate tropical probabilities Q,
showing that all lie at or below int^+ phi dP and that Q = P attains the max.
"""
import random
import matplotlib.pyplot as plt

def normalize(w):
    m = max(w)
    return [x - m for x in w]

def mpi(phi, w):
    return max(p + wx for p, wx in zip(phi, w))

def relent(wq, wp):
    return max(q - p for q, p in zip(wq, wp))

random.seed(0)
n = 5
wp = normalize([random.uniform(-3, 0) for _ in range(n)])
phi = [random.uniform(-2, 3) for _ in range(n)]
target = mpi(phi, wp)

xs, ys = [], []
for _ in range(2000):
    wq = normalize([random.uniform(-4, 0) for _ in range(n)])
    xs.append(relent(wq, wp))
    ys.append(mpi(phi, wq) - relent(wq, wp))

plt.figure(figsize=(8,5))
plt.scatter(xs, ys, s=6, alpha=0.3, label="candidate laws Q")
plt.axhline(target, color="C3", lw=2,
            label=r"$\int^+\varphi\,dP$ (attained at $Q=P$)")
plt.scatter([0], [target], color="black", zorder=5, label="Q = P")
plt.xlabel(r"$D(Q\Vert P)$")
plt.ylabel(r"$\int^+\varphi\,dQ - D(Q\Vert P)$")
plt.title("Idempotent Donsker-Varadhan: objective <= free energy, max at Q=P")
plt.legend()
plt.tight_layout()
plt.savefig("donsker_varadhan.png", dpi=150)
print("wrote donsker_varadhan.png")
