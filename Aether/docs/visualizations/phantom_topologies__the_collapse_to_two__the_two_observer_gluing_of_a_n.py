"""Visualize the gluing (a, x] u [x, b) = (a, b) that powers the R theorem."""
import matplotlib.pyplot as plt

a, x, b = -1.0, 0.3, 1.5
fig, ax = plt.subplots(figsize=(9, 2.6))
ax.hlines(2, a, x, color="tab:blue", lw=6, label="upper-limit observer: (a, x]")
ax.plot([x], [2], "o", color="tab:blue"); ax.plot([a], [2], "o", mfc="white", color="tab:blue")
ax.hlines(1, x, b, color="tab:red", lw=6, label="lower-limit observer: [x, b)")
ax.plot([x], [1], "o", color="tab:red"); ax.plot([b], [1], "o", mfc="white", color="tab:red")
ax.hlines(0, a, b, color="tab:green", lw=6, label="consensus: (a, b)")
ax.plot([a], [0], "o", mfc="white", color="tab:green"); ax.plot([b], [0], "o", mfc="white", color="tab:green")
for val, lab in [(a, "a"), (x, "x"), (b, "b")]:
    ax.axvline(val, color="gray", ls=":", lw=0.8); ax.text(val, 2.6, lab, ha="center")
ax.set_yticks([0, 1, 2]); ax.set_yticklabels(["(a,b)", "[x,b)", "(a,x]"])
ax.set_ylim(-0.6, 3.0); ax.set_title("Two observers reconstruct a two-sided neighbourhood")
ax.legend(loc="lower center", ncol=3, fontsize=8, bbox_to_anchor=(0.5, -0.45))
plt.tight_layout(); plt.savefig("squeeze.png", dpi=150); print("wrote squeeze.png")
