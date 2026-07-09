import matplotlib.pyplot as plt
import numpy as np

def p14(n):
    return 6 * n * n - 5 * n

# Plot P_14(n) against the lattice of perfect fourth powers, highlighting hits.
ns = np.arange(-2100, 60)
vals = p14(ns)

fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(ns, vals, lw=1.2, color="#3b6fb6", label=r"$P_{14}(n)=6n^2-5n$")

# fourth-power grid lines
for t in range(0, 75):
    y = t ** 4
    if y <= vals.max():
        ax.axhline(y, color="0.85", lw=0.5)

solutions = [(-2000, 70), (0, 0), (1, 1)]
for n, t in solutions:
    ax.scatter([n], [p14(n)], color="#c0392b", zorder=5, s=60)
    ax.annotate(f"$n={n},\ {t}^4$", (n, p14(n)),
                textcoords="offset points", xytext=(8, 8))

ax.set_yscale("symlog")
ax.set_xlabel("n")
ax.set_ylabel(r"$P_{14}(n)$ (symlog)")
ax.set_title("14-gonal numbers meeting perfect fourth powers")
ax.legend()
plt.tight_layout()
plt.savefig("fourteen_gonal_fourth_powers.png", dpi=150)
print("saved fourteen_gonal_fourth_powers.png")
