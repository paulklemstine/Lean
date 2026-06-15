import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(10, 5))

categories = ["No Soundness", "Falsum-Soundness", "Full Soundness"]
colors = ["#ff6666", "#66aaff", "#66cc66"]
bridge_works = [False, True, True]
extra_guarantees = ["", "⊥ provable → no models", "All provable → true in models"]

bars = ax.barh(categories, [1, 2, 3], color=colors, edgecolor="black", height=0.5)

for i, (bar, works, extra) in enumerate(zip(bars, bridge_works, extra_guarantees)):
    status = "✓ Bridge works" if works else "✗ No bridge"
    ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
            f"{status}  |  {extra}", va="center", fontsize=10)

ax.set_xlim(0, 7)
ax.set_xlabel("Strength", fontsize=12)
ax.set_title("Soundness Hierarchy and the Physics→Logic Bridge", fontsize=14, fontweight="bold")
ax.axvline(x=1.5, color="gray", linestyle="--", alpha=0.5)
ax.text(1.5, -0.6, "Minimum for bridge", ha="center", fontsize=9, color="gray")

plt.tight_layout()
plt.savefig("soundness_spectrum.png", dpi=150, bbox_inches="tight")
print("Saved soundness_spectrum.png")