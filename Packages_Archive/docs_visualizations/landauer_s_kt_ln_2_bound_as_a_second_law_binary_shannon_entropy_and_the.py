"""Visualize bit Shannon entropy H(q) and the erasure entropy drop to 0.

Saves 'bit_entropy.png'. Requires matplotlib + numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def binary_entropy(q: np.ndarray) -> np.ndarray:
    out = np.zeros_like(q)
    mask = (q > 0) & (q < 1)
    qq = q[mask]
    out[mask] = -qq * np.log(qq) - (1 - qq) * np.log(1 - qq)
    return out

def main() -> None:
    q = np.linspace(0.0, 1.0, 400)
    H = binary_entropy(q)
    plt.figure(figsize=(8, 5))
    plt.plot(q, H, lw=2, label="H(q) = -q ln q - (1-q) ln(1-q)")
    plt.scatter([0.5], [np.log(2)], color="crimson", zorder=5,
                label="uniform bit: H = ln 2")
    plt.scatter([0.0], [0.0], color="navy", zorder=5,
                label="erased bit: H = 0")
    plt.annotate("", xy=(0.02, 0.02), xytext=(0.5, np.log(2)),
                 arrowprops=dict(arrowstyle="->", color="gray", lw=1.5))
    plt.text(0.18, 0.4, "erasure\nΔH = ln 2", color="gray")
    plt.xlabel("probability q of state 1")
    plt.ylabel("Shannon entropy (nats)")
    plt.title("Erasing a uniform bit destroys ln 2 of Shannon entropy")
    plt.legend()
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("bit_entropy.png", dpi=150)
    print("wrote bit_entropy.png")

if __name__ == "__main__":
    main()
