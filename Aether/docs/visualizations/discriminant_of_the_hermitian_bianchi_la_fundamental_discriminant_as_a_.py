"""Bar chart of det Gram(S_K) = D_K over squarefree d < 0.

Requires matplotlib. Run: python this_script.py
"""
from __future__ import annotations

import matplotlib.pyplot as plt


def is_squarefree(n: int) -> bool:
    m = abs(n)
    k = 2
    while k * k <= m:
        if m % (k * k) == 0:
            return False
        k += 1
    return m != 0


def fundamental_disc(d: int) -> int:
    return d if d % 4 == 1 else 4 * d


ds = [d for d in range(-1, -41, -1) if is_squarefree(d)]
disc = [fundamental_disc(d) for d in ds]
colors = ["#d62728" if d % 4 == 1 else "#1f77b4" for d in ds]

fig, ax = plt.subplots(figsize=(11, 5))
ax.bar([str(d) for d in ds], disc, color=colors)
ax.set_xlabel("d (squarefree, < 0)")
ax.set_ylabel("det Gram(S_K) = D_K")
ax.set_title("Fundamental discriminant as Gram determinant of S_K = Herm_2(O_K)")
ax.axhline(0, color="black", linewidth=0.8)
red = plt.Rectangle((0, 0), 1, 1, fc="#d62728")
blue = plt.Rectangle((0, 0), 1, 1, fc="#1f77b4")
ax.legend([red, blue], ["d == 1 (mod 4):  D_K = d",
                        "otherwise:  D_K = 4d"])
plt.xticks(rotation=90)
plt.tight_layout()
plt.savefig("hermitian_bianchi_discriminant.png", dpi=150)
print("saved hermitian_bianchi_discriminant.png")
