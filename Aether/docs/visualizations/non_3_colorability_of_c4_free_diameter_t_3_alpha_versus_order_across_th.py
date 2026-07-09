"""Visualization: 3*alpha versus |V| across the extremal Moore graphs,
illustrating where 3-colorability must fail (3*alpha < |V|)."""
import matplotlib.pyplot as plt

# (name, |V|, Delta, alpha, chi)
data = [
    ("C5 (pentagon)", 5, 2, 2, 3),
    ("Petersen", 10, 3, 4, 3),
    ("Hoffman-Singleton", 50, 7, 15, 4),
]

names = [d[0] for d in data]
n_vals = [d[1] for d in data]
three_alpha = [3 * d[3] for d in data]

x = range(len(data))
width = 0.38
fig, ax = plt.subplots(figsize=(8, 5))
ax.bar([i - width / 2 for i in x], n_vals, width, label="|V|", color="#3366cc")
ax.bar([i + width / 2 for i in x], three_alpha, width, label="3*alpha",
       color="#dc3912")
for i, d in enumerate(data):
    ax.text(i, max(n_vals[i], three_alpha[i]) + 0.8,
            f"chi={d[4]}", ha="center", fontsize=10)
ax.set_xticks(list(x))
ax.set_xticklabels(names, rotation=10)
ax.set_ylabel("count")
ax.set_title("3-colorability requires 3*alpha >= |V|")
ax.legend()
plt.tight_layout()
plt.savefig("colorability_bounds.png", dpi=150)
print("wrote colorability_bounds.png")
