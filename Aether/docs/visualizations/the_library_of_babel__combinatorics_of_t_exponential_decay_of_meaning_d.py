"""Visualization: meaning-density bound decay with passage length."""
import numpy as np
import matplotlib.pyplot as plt

def bound(A: int, L: int, m: int) -> float:
    return (L - m + 1) * A ** (-m)

L = 1_312_000
ms = np.arange(1, 41)
for A in (2, 4, 25):
    ys = [bound(A, L, int(m)) for m in ms]
    plt.semilogy(ms, ys, marker="o", label=f"A={A}")
plt.xlabel("passage length m")
plt.ylabel("upper bound on fraction of volumes  (log scale)")
plt.title("Meaning-density: exponential decay in passage length")
plt.legend(); plt.grid(True, which="both", alpha=0.3)
plt.tight_layout(); plt.savefig("viz_density.png", dpi=150)
print("saved viz_density.png")
