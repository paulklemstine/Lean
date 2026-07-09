"""Bar chart comparing expected cover times: projective lines vs uniform blocks."""
from fractions import Fraction
from itertools import combinations
from math import comb
import matplotlib.pyplot as plt


def cover_count(blocks, subset):
    return sum(1 for b in blocks if b & subset)


def ect(blocks, n):
    m = len(blocks)
    total = Fraction(0)
    for s in range(1, n + 1):
        sign = 1 if s % 2 == 1 else -1
        for combo in combinations(range(n), s):
            total += Fraction(sign * m, cover_count(blocks, set(combo)))
    return float(total)


def fano():
    base = [0, 1, 3]
    return [set((b + s) % 7 for b in base) for s in range(7)]


lines = fano()
uniform = [set(c) for c in combinations(range(7), 3)]
vals = [ect(uniform, 7), ect(lines, 7)]
labels = ["Uniform 3-subsets\n(85691/15810)", "Fano lines\n(163/30)"]

fig, ax = plt.subplots(figsize=(6, 4))
bars = ax.bar(labels, vals, color=["#4C72B0", "#C44E52"])
ax.set_ylabel("Expected cover time")
ax.set_title("Fano lines are strictly slower to cover (q = 2)")
ax.set_ylim(5.40, 5.45)
for b, v in zip(bars, vals):
    ax.text(b.get_x() + b.get_width() / 2, v + 0.001, f"{v:.5f}",
            ha="center", va="bottom")
plt.tight_layout()
plt.savefig("cover_time_comparison.png", dpi=150)
print("saved cover_time_comparison.png")
