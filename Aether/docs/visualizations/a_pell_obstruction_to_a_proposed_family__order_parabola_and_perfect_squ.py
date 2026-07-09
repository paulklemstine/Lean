import matplotlib.pyplot as plt
import numpy as np
from math import isqrt

def order(u): return u * (3 * u + 2)
def is_square(n):
    r = isqrt(int(n)); return r * r == int(n)

U = 12
uu = np.linspace(0, U, 400)
fig, ax = plt.subplots(figsize=(9, 6))
ax.plot(uu, uu * (3 * uu + 2), color="navy", label="order = u(3u+2)")

adm = [u for u in range(U + 1) if is_square(order(u))]
for u in adm:
    o = order(u); r = isqrt(o)
    ax.axhline(o, color="crimson", ls=":", alpha=0.6)
    ax.scatter([u], [o], color="crimson", zorder=3)
    ax.annotate(f"u={u}, {r}²", (u, o), textcoords="offset points", xytext=(6, -12))

ax.set_xlabel("u"); ax.set_ylabel("order")
ax.set_title("Admissible u: where the order parabola hits a perfect square")
ax.legend(); ax.grid(alpha=0.3)
plt.tight_layout(); plt.savefig("parabola.png", dpi=150)
print("saved parabola.png")
