import matplotlib.pyplot as plt

# The strict hierarchy visualized as nested regions with witnesses.
fig, ax = plt.subplots(figsize=(8, 6))
circles = [
    (3.0, "palindromic", "#cfe8ff"),
    (2.1, "unimodal palindromic", "#9ecbff"),
    (1.2, "gamma-positive", "#4a90e2"),
]
for r, label, color in circles:
    ax.add_patch(plt.Circle((0, 0), r, color=color, ec="black", zorder=-r))
    ax.text(0, r - 0.25, label, ha="center", fontsize=11, fontweight="bold")
ax.text(0, 0, "(1+t)^n", ha="center", va="center", fontsize=11)
ax.text(0, 1.65, "1+t+t^2+t^3+t^4", ha="center", fontsize=9)
ax.text(0, 2.55, "1 + t^2", ha="center", fontsize=9)
ax.set_xlim(-3.4, 3.4); ax.set_ylim(-3.4, 3.4); ax.set_aspect("equal"); ax.axis("off")
ax.set_title("Strict hierarchy of positivity classes")
plt.tight_layout(); plt.savefig("hierarchy.png", dpi=150)
print("saved hierarchy.png")
