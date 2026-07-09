"""Draw the Paley graph on 17 vertices (the extremal R(4,4) witness)."""
import matplotlib.pyplot as plt
from math import cos, sin, pi

p = 17
qr = {(x * x) % p for x in range(1, p)}
pos = {i: (cos(2 * pi * i / p), sin(2 * pi * i / p)) for i in range(p)}

fig, ax = plt.subplots(figsize=(7, 7))
for a in range(p):
    for b in range(a + 1, p):
        red = (a - b) % p in qr
        x0, y0 = pos[a]; x1, y1 = pos[b]
        ax.plot([x0, x1], [y0, y1],
                color=("crimson" if red else "royalblue"),
                lw=0.7, alpha=0.6)
for i, (x, y) in pos.items():
    ax.plot(x, y, "o", color="black", ms=8)
    ax.annotate(str(i), (x, y), textcoords="offset points", xytext=(6, 6))
ax.set_aspect("equal"); ax.axis("off")
ax.set_title("Paley graph on 17 vertices: no red K4, no blue K4")
plt.tight_layout()
plt.savefig("paley17.png", dpi=150)
print("wrote paley17.png")
