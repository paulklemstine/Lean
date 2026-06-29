import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, ax = plt.subplots(1, 1, figsize=(10, 7))
ax.set_xlim(-3, 3)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect("equal")
ax.axis("off")
ax.set_title("The Logic-Physics Consistency Hierarchy", fontsize=16, fontweight="bold")

# All theories (outer)
outer = patches.Ellipse((0, 0), 5.5, 4.5, fill=True, facecolor="#ffcccc", edgecolor="#cc0000", linewidth=2)
ax.add_patch(outer)
ax.text(2.0, 1.8, "All Theories", fontsize=12, ha="center", color="#cc0000")

# Mathematically consistent (middle)
middle = patches.Ellipse((0, -0.2), 4.0, 3.2, fill=True, facecolor="#ccddff", edgecolor="#0044cc", linewidth=2)
ax.add_patch(middle)
ax.text(1.3, 1.0, "Mathematically
Consistent", fontsize=11, ha="center", color="#0044cc")

# Physically consistent (inner)
inner = patches.Ellipse((0, -0.3), 2.2, 1.8, fill=True, facecolor="#ccffcc", edgecolor="#008800", linewidth=2)
ax.add_patch(inner)
ax.text(0, -0.3, "Physically
Consistent", fontsize=11, ha="center", fontweight="bold", color="#008800")

# Gap annotation
ax.annotate("The Gap
(Separation Thm)",
            xy=(1.5, -0.5), xytext=(2.5, -1.5),
            fontsize=10, ha="center", color="#0044cc",
            arrowprops=dict(arrowstyle="->", color="#0044cc"))

plt.tight_layout()
plt.savefig("consistency_hierarchy.png", dpi=150, bbox_inches="tight")
print("Saved consistency_hierarchy.png")