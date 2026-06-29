"""Visualization: the period-8 orbit of (1+i) in the complex plane."""
import matplotlib.pyplot as plt

pts = [(1+1j)**k for k in range(9)]
xs = [p.real for p in pts]; ys = [p.imag for p in pts]

fig, ax = plt.subplots(figsize=(7, 7))
ax.plot(xs, ys, "-o", color="#2b6cb0")
for k, p in enumerate(pts):
    ax.annotate(f"(1+i)^{k}", (p.real, p.imag), textcoords="offset points", xytext=(6, 6))
ax.axhline(0, color="gray", lw=0.7); ax.axvline(0, color="gray", lw=0.7)
ax.scatter([16], [0], color="#c05621", zorder=5, s=80, label="(1+i)^8 = 16 (positive real)")
ax.set_title("Powers of (1+i): period 8, only exp. divisible by 8 are positive real")
ax.set_xlabel("Re"); ax.set_ylabel("Im"); ax.legend(); ax.set_aspect("equal", "box")
plt.tight_layout()
plt.savefig("onePlusI_cycle.png", dpi=140)
print("saved onePlusI_cycle.png")
