"""Visualization 3: comparison of multiplicative constants. Bar chart of the
Clark-Suen constant 1/2, the improved constant (19-sqrt73)/18, and the
conjectured Vizing constant 1, illustrating the strict ordering 1/2 < c < 1."""
import matplotlib.pyplot as plt
from math import sqrt

c = (19 - sqrt(73)) / 18
names = ["Clark-Suen\n1/2", f"Improved\n(19-√73)/18\n≈{c:.4f}", "Vizing\n1"]
vals = [0.5, c, 1.0]
colors = ["#4C72B0", "#C44E52", "#55A868"]

fig, ax = plt.subplots(figsize=(7, 5))
bars = ax.bar(names, vals, color=colors)
for b, v in zip(bars, vals):
    ax.text(b.get_x() + b.get_width() / 2, v + 0.01, f"{v:.4f}",
            ha="center", va="bottom")
ax.set_ylim(0, 1.15)
ax.set_ylabel("multiplicative constant c in  gamma(G[]H) >= c*gamma(G)gamma(H)")
ax.set_title("Where the improved constant sits")
plt.tight_layout()
plt.savefig("constant_comparison.png", dpi=150)
print("saved constant_comparison.png")
