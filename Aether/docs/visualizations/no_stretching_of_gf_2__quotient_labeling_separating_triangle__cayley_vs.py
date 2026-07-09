"""
Visualization: the separating triangle K_3. Plots the graph, the quotient
labels in GF(2)^2, and a bar chart contrasting Cayley distance (correct,
no-stretch) with Hamming distance (wrong, stretches the edge {0,2}).
Requires matplotlib.
"""
import matplotlib.pyplot as plt
import numpy as np

labels = {0: (0, 0), 1: (1, 0), 2: (1, 1)}
edges = [(0, 1), (1, 2), (0, 2)]
cayley = {(0, 1): 1, (1, 2): 1, (0, 2): 1}
hamming = {(0, 1): 1, (1, 2): 1, (0, 2): 2}
dG = {(0, 1): 1, (1, 2): 1, (0, 2): 1}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

# Triangle drawing
pos = {0: (0, 0), 1: (1, 0), 2: (0.5, 0.87)}
for u, v in edges:
    ax1.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]], "k-", lw=2, zorder=1)
for v, (x, y) in pos.items():
    ax1.scatter([x], [y], s=900, c="#4C72B0", zorder=2)
    ax1.text(x, y, f"{v}\n{labels[v]}", ha="center", va="center",
             color="white", fontsize=10, zorder=3)
ax1.set_title("Triangle $K_3$ with quotient labels in $\\mathbb{F}_2^2$")
ax1.axis("off")

# Distance comparison
x = np.arange(len(edges))
w = 0.25
ax2.bar(x - w, [dG[e] for e in edges], w, label="$d_G$ (true)", color="#55A868")
ax2.bar(x, [cayley[e] for e in edges], w, label="Cayley (correct)", color="#4C72B0")
ax2.bar(x + w, [hamming[e] for e in edges], w, label="Hamming (wrong)", color="#C44E52")
ax2.set_xticks(x)
ax2.set_xticklabels([f"edge {e}" for e in edges])
ax2.set_ylabel("distance")
ax2.set_title("Cayley never stretches; Hamming stretches edge (0,2)")
ax2.legend()

plt.tight_layout()
plt.savefig("no_stretch_triangle.png", dpi=150)
print("saved no_stretch_triangle.png")
