import numpy as np
import matplotlib.pyplot as plt

sizes = np.arange(1, 21)
constant_feasible = np.ones_like(sizes)          # always feasible over C
nonconstant_bound = np.where(sizes <= 6, 1, 0)   # conjectured bound of 6

fig, ax = plt.subplots(figsize=(8, 5))
ax.step(sizes, constant_feasible, where="mid", label="constants over C (always)",
        linewidth=2)
ax.step(sizes, nonconstant_bound, where="mid",
        label="nonconstant conjectured bound (<= 6)", linewidth=2)
ax.axvline(6, color="gray", linestyle="--", alpha=0.7)
ax.set_xlabel("set size |A|")
ax.set_ylabel("feasible? (1 = yes)")
ax.set_ylim(-0.1, 1.3)
ax.set_title("Where the size bound bites: constants vs nonconstant tuples")
ax.legend()
plt.tight_layout()
plt.savefig("size_feasibility.png", dpi=150)
print("wrote size_feasibility.png")
