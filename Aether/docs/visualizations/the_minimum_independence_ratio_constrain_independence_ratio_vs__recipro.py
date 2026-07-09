import matplotlib.pyplot as plt
from fractions import Fraction

# (name, i(G), 1/chi, 1/(Delta+1))
data = [
    ("K3",            Fraction(1, 3),  Fraction(1, 3), Fraction(1, 3)),
    ("Moser spindle", Fraction(2, 7),  Fraction(1, 4), Fraction(1, 5)),
    ("Golomb graph",  Fraction(3, 10), Fraction(1, 4), Fraction(1, 5)),
    ("Prism",         Fraction(1, 3),  Fraction(1, 3), Fraction(1, 4)),
    ("C5",            Fraction(2, 5),  Fraction(1, 3), Fraction(1, 3)),
]

names = [d[0] for d in data]
i_vals = [float(d[1]) for d in data]
inv_chi = [float(d[2]) for d in data]
inv_deg = [float(d[3]) for d in data]

x = range(len(names))
width = 0.27
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar([xi - width for xi in x], i_vals, width, label="i(G)")
ax.bar(list(x), inv_chi, width, label="1/chi(G)")
ax.bar([xi + width for xi in x], inv_deg, width, label="1/(Delta+1)")
ax.axhline(0.25, color="crimson", linestyle="--", label="quarter floor 1/4")
ax.set_xticks(list(x))
ax.set_xticklabels(names)
ax.set_ylabel("ratio")
ax.set_title("Independence ratio and its reciprocal lower bounds")
ax.legend()
plt.tight_layout()
plt.savefig("independence_ratio_bounds.png", dpi=150)
print("saved independence_ratio_bounds.png")
