"""Visualization: adjacency spectra of P_n, C_n, star, K_{a,b} on a number line."""
import math
import matplotlib.pyplot as plt

def path_eig(n, k): return 2*math.cos((k+1)*math.pi/(n+1))

n = 8
spec = [path_eig(n, k) for k in range(n)]
fig, ax = plt.subplots(figsize=(8, 2))
ax.axhline(0, color="gray", lw=0.5)
ax.scatter(spec, [0]*n, s=80, color="crimson", zorder=3)
for x in spec:
    ax.annotate(f"{x:.2f}", (x, 0), textcoords="offset points", xytext=(0, 8),
                ha="center", fontsize=8)
ax.set_title(f"Adjacency spectrum of the path P_{n}  (symmetric about 0)")
ax.set_yticks([]); ax.set_xlim(-2.3, 2.3)
plt.tight_layout(); plt.savefig("path_spectrum.png", dpi=150)
print("wrote path_spectrum.png")
