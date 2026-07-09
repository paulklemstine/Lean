import matplotlib.pyplot as plt
from math import isqrt

def order(u): return u * (3 * u + 2)
def is_square(n): 
    r = isqrt(n); return r * r == n

U = 60
xs = list(range(U + 1))
adm = [u for u in xs if is_square(order(u))]

fig, ax = plt.subplots(figsize=(11, 2.4))
ax.scatter(xs, [0]*len(xs), s=12, color="lightgray", label="all indices")
ax.scatter(adm, [0]*len(adm), s=90, color="crimson", zorder=3, label="admissible (Pell)")
for u in adm:
    ax.annotate(str(u), (u, 0), textcoords="offset points", xytext=(0, 10), ha="center")
ax.set_yticks([]); ax.set_xlabel("index u")
ax.set_title("Admissible design indices are a sparse Pell orbit")
ax.legend(loc="upper right")
plt.tight_layout(); plt.savefig("sparsity.png", dpi=150)
print("saved sparsity.png")
