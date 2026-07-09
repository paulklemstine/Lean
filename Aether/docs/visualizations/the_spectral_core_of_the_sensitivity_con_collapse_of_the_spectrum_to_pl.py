"""Eigenvalue spectrum of A_n, showing every eigenvalue collapses to +/- sqrt(n)."""
import numpy as np
import matplotlib.pyplot as plt

def signed_adjacency(n: int) -> np.ndarray:
    if n == 0:
        return np.zeros((1, 1), dtype=np.int64)
    a = signed_adjacency(n - 1); s = a.shape[0]; i = np.eye(s, dtype=np.int64)
    return np.vstack([np.hstack([a, i]), np.hstack([i, -a])])

fig, ax = plt.subplots(figsize=(8, 5))
for n in range(1, 7):
    eig = np.linalg.eigvalsh(signed_adjacency(n).astype(float))
    ax.scatter([n] * len(eig), eig, s=12, alpha=0.6)
    ax.axhline(0, color="grey", lw=0.4)
xs = np.linspace(1, 6, 200)
ax.plot(xs, np.sqrt(xs), "r--", label=r"$+\sqrt{n}$")
ax.plot(xs, -np.sqrt(xs), "b--", label=r"$-\sqrt{n}$")
ax.set_xlabel("dimension n"); ax.set_ylabel("eigenvalues of $A_n$")
ax.set_title("Spectrum of the signed hypercube collapses to $\pm\sqrt{n}$")
ax.legend()
plt.tight_layout()
plt.savefig("spectrum.png", dpi=150)
print("saved spectrum.png")
