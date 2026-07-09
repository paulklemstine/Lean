"""Visualize the Euclidean two-observer squeeze (a, x] u [x, b) = (a, b)."""
import matplotlib.pyplot as plt

a, x, b = -1.0, 0.4, 2.0
fig, ax = plt.subplots(figsize=(9, 2.6))
ax.hlines(2, a, x, color="crimson", lw=6, label="upper observer (a, x]")
ax.plot([x], [2], "o", color="crimson")            # closed at x
ax.hlines(1, x, b, color="royalblue", lw=6, label="lower observer [x, b)")
ax.plot([x], [1], "o", color="royalblue")          # closed at x
ax.hlines(0, a, b, color="black", lw=6, label="consensus (a, b)")
for xv, lbl in [(a, "a"), (x, "x"), (b, "b")]:
    ax.axvline(xv, ls="--", color="gray", alpha=0.5)
    ax.text(xv, -0.6, lbl, ha="center")
ax.set_yticks([0, 1, 2]); ax.set_yticklabels(["consensus", "lower", "upper"])
ax.set_title("Two one-sided views reassemble a two-sided neighbourhood")
ax.legend(loc="upper right"); ax.set_ylim(-0.9, 2.6)
plt.tight_layout(); plt.savefig("euclidean_squeeze.png", dpi=150)
print("saved euclidean_squeeze.png")
