"""Row entries and the (constant) row sum as functions of the shift s."""
import numpy as np
import matplotlib.pyplot as plt
from math import comb, factorial

def A(n: int, k: int, s: float) -> float:
    return sum((-1) ** i * comb(n + 1, i) * (k + 1 - i - s) ** n for i in range(k + 1))

n = 4
S = np.linspace(-2, 2, 400)
fig, ax = plt.subplots(figsize=(7, 4.5))
for k in range(n + 1):
    ax.plot(S, [A(n, k, s) for s in S], label=f"A({n},{k},s)")
ax.plot(S, [sum(A(n, k, s) for k in range(n + 1)) for s in S],
        "k--", lw=2.5, label=f"row sum = {factorial(n)}")
ax.set_xlabel("shift s"); ax.set_ylabel("value"); ax.legend(ncol=2, fontsize=8)
ax.set_title(f"Entries vary with s; the row sum is frozen at {n}! = {factorial(n)}")
plt.tight_layout(); plt.savefig("eulerian_lines.png", dpi=150)
print("wrote eulerian_lines.png")
