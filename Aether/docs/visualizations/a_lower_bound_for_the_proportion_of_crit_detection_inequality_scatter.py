"""Scatter illustrating M1^2 <= |onLine| * M2 across random weightings."""
import random
import matplotlib.pyplot as plt

random.seed(0)
xs, ys = [], []
for _ in range(400):
    k = random.randint(1, 20)
    w = [random.uniform(0, 2) for _ in range(k)]
    m1 = sum(w)
    m2 = sum(x * x for x in w)
    xs.append(k * m2)          # RHS bound
    ys.append(m1 * m1)         # LHS

fig, ax = plt.subplots(figsize=(7, 7))
ax.scatter(xs, ys, s=10, alpha=0.5, color="#8145b0")
lim = max(max(xs), max(ys))
ax.plot([0, lim], [0, lim], "r--", label="equality (uniform weights)")
ax.set_xlabel("|onLine| * M2  (upper bound)")
ax.set_ylabel("M1^2  (first moment squared)")
ax.set_title("Cauchy--Schwarz detection inequality: M1^2 <= |onLine| M2")
ax.legend()
plt.tight_layout()
plt.savefig("cs_scatter.png", dpi=150)
print("wrote cs_scatter.png")
