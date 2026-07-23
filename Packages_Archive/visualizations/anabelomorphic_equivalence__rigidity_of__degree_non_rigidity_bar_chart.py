"""Visualization: degree non-rigidity — classes realizable in each degree N."""
import matplotlib.pyplot as plt

def divisors(n):
    return [d for d in range(1, n + 1) if n % d == 0]

p = 2
Ns = list(range(1, 13))
num_classes = []
for N in Ns:
    orders = {p ** f - 1 for f in divisors(N)}
    num_classes.append(len(orders))

colors = ["seagreen" if c == 1 else "indianred" for c in num_classes]
fig, ax = plt.subplots(figsize=(9, 4.5))
ax.bar([str(n) for n in Ns], num_classes, color=colors)
ax.set_xlabel("total field degree N = e * f  (over Q_2)")
ax.set_ylabel("# distinct residue-anabelomorphic classes")
ax.set_title("Degree non-rigidity: green = rigid (1 class), red = non-rigid")
for i, c in enumerate(num_classes):
    ax.text(i, c + 0.05, str(c), ha="center", fontsize=8)
plt.tight_layout()
plt.savefig("degree_non_rigidity.png", dpi=150)
print("wrote degree_non_rigidity.png")
