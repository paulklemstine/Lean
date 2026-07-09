"""Visualization: Euler characteristic of the RP^2 tower versus spheres.

Plots chi against dimension for the projective-plane suspension tower (constant
at 1) and for spheres (alternating between 0 and 2), highlighting that the two
families never meet.
"""
import matplotlib.pyplot as plt

dims = list(range(2, 11))
tower = [1 for _ in dims]
sphere = [1 + (-1) ** d for d in dims]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(dims, tower, "o-", color="crimson", lw=2, label="$\\mathbb{RP}^2$ tower  ($\\chi=1$)")
ax.plot(dims, sphere, "s--", color="navy", lw=2, label="$d$-sphere  ($\\chi=1+(-1)^d$)")
ax.axhline(1, color="gray", ls=":", alpha=0.6)
ax.set_xlabel("dimension $d$"); ax.set_ylabel("Euler characteristic $\\chi$")
ax.set_title("The Euler characteristic separates the projective tower from spheres")
ax.set_yticks([0, 1, 2]); ax.legend(); ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("euler_separator.png", dpi=150)
print("saved euler_separator.png")
