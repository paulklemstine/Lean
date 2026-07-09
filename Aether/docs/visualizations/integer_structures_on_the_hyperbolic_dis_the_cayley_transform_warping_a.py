import numpy as np
import matplotlib.pyplot as plt

def cayley(z):
    return (z - 1j) / (z + 1j)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 5))
t = np.linspace(-6, 6, 400)
for x0 in np.linspace(-5, 5, 11):        # vertical lines
    z = x0 + 1j * np.linspace(0.05, 6, 400)
    ax1.plot(z.real, z.imag, 'b', lw=0.7)
    w = cayley(z); ax2.plot(w.real, w.imag, 'b', lw=0.7)
for y0 in np.linspace(0.2, 6, 12):       # horizontal lines
    z = t + 1j * y0
    ax1.plot(z.real, z.imag, 'r', lw=0.7)
    w = cayley(z); ax2.plot(w.real, w.imag, 'r', lw=0.7)
ax1.set_title("Upper half-plane"); ax1.set_xlim(-6, 6); ax1.set_ylim(0, 6)
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), 'k', lw=1)
ax2.set_title("Poincare disk (image)"); ax2.set_aspect('equal')
plt.tight_layout(); plt.savefig("cayley_grid.png", dpi=150)
print("saved cayley_grid.png")
