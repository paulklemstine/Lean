"""Visualization: the apparition grid and the join law.

Plots, for several moduli m, the indices n where m | F(n) (an arithmetic
progression with step entry(m)), making the apparition law visually obvious,
and overlays the join law entry(lcm(a,b)) = lcm(entry(a),entry(b)).
"""
from math import gcd
import matplotlib.pyplot as plt


def lcm(a, b):
    return a * b // gcd(a, b)


def entry(m):
    if m == 1:
        return 1
    a, b, k = 0, 1, 1
    while b % m != 0:
        a, b = b, (a + b) % m
        k += 1
    return k


moduli = [2, 3, 4, 5, 6, 7]
N = 48
fig, ax = plt.subplots(figsize=(11, 5))
for row, m in enumerate(moduli):
    e = entry(m)
    hits = [n for n in range(1, N + 1) if n % e == 0]
    ax.scatter(hits, [row] * len(hits), s=70, label=f"m={m} (entry={e})")
ax.set_yticks(range(len(moduli)))
ax.set_yticklabels([f"m={m}" for m in moduli])
ax.set_xlabel("index n  (dots mark m | F(n))")
ax.set_title("Apparition grid: multiples of m appear at multiples of entry(m)")
ax.grid(True, axis="x", alpha=0.3)
ax.legend(loc="upper right", fontsize=8)
plt.tight_layout()
plt.savefig("apparition_grid.png", dpi=140)
print("saved apparition_grid.png")

# Join-law check overlay
print("Join law spot-checks:")
for a, b in [(2, 3), (2, 5), (4, 7), (6, 10)]:
    print(f"  entry(lcm({a},{b})={lcm(a,b)}) = {entry(lcm(a,b))}, "
          f"lcm(entry,entry) = {lcm(entry(a), entry(b))}")
