import matplotlib.pyplot as plt
import numpy as np

# Residue wheel of squares mod 5: shows each residue mapping to its square.
fig, ax = plt.subplots(figsize=(6, 6))
res = list(range(5))
angles = {r: 2 * np.pi * r / 5 for r in res}
R = 1.0
for r in res:
    x, y = R * np.cos(angles[r]), R * np.sin(angles[r])
    ax.plot([x], [y], 'o', ms=28, color='#dceeff', zorder=2)
    ax.text(x, y, str(r), ha='center', va='center', fontsize=16, zorder=3)
for r in res:
    s = (r * r) % 5
    x0, y0 = 0.82 * np.cos(angles[r]), 0.82 * np.sin(angles[r])
    x1, y1 = 0.82 * np.cos(angles[s]), 0.82 * np.sin(angles[s])
    ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                arrowprops=dict(arrowstyle="->", color="#c0392b", lw=1.6))
ax.set_title("Squaring map x -> x^2 (mod 5); image = {0,1,4}")
ax.set_aspect('equal'); ax.axis('off')
plt.tight_layout()
plt.savefig("squares_mod5_wheel.png", dpi=150)
print("saved squares_mod5_wheel.png")
