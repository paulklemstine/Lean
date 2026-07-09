import numpy as np
import matplotlib.pyplot as plt

h = (1.0, -2.0)
y = 0.0
N = 400
xs = np.linspace(-6, 6, N)
ys = np.linspace(-6, 6, N)
X, Y = np.meshgrid(xs, ys)
digest = np.minimum(X + h[0], Y + h[1])
level = np.abs(digest - y) < 0.03  # thin band around the fiber

plt.figure(figsize=(6, 6))
plt.imshow(level, extent=[-6, 6, -6, 6], origin="lower", cmap="viridis")
plt.xlabel(r"$m_0$")
plt.ylabel(r"$m_1$")
plt.title(f"Collision fiber min(m0+{h[0]}, m1+{h[1]}) = {y}")
plt.tight_layout()
plt.savefig("collision_fiber.png", dpi=150)
print("saved collision_fiber.png")
