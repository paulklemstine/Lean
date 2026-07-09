"""Visualize a univariate tropical polynomial as the lower envelope of lines,
marking the tropical roots (corners) and labeling slope-drop multiplicities."""
import matplotlib.pyplot as plt
import numpy as np


def plot_tropical_polynomial(coeffs: dict[int, float], degree: int) -> None:
    w = np.linspace(-1.0, 5.0, 1000)
    T = np.full_like(w, np.inf)
    for k, c in coeffs.items():
        line = c + k * w
        plt.plot(w, line, "--", alpha=0.4, label=f"slope {k}: {c}+{k}w")
        T = np.minimum(T, line)
    plt.plot(w, T, "k-", linewidth=2.5, label="trop(f)(w) = min")
    # mark corners (roots) where two consecutive integer slopes cross
    items = sorted(coeffs.items())
    for (k1, c1), (k2, c2) in zip(items, items[1:]):
        x = (c1 - c2) / (k2 - k1)
        plt.scatter([x], [c1 + k1 * x], color="red", zorder=5, s=60)
        plt.annotate(f"root w={x:.1f}\nmult {k2-k1}", (x, c1 + k1 * x),
                     textcoords="offset points", xytext=(6, -22))
    plt.title("Univariate tropical polynomial: lower envelope and roots")
    plt.xlabel("w"); plt.ylabel("trop(f)(w)")
    plt.legend(fontsize=8); plt.grid(alpha=0.3)
    plt.tight_layout(); plt.savefig("tropical_envelope.png", dpi=150)
    print("saved tropical_envelope.png")


if __name__ == "__main__":
    plot_tropical_polynomial({0: 6.0, 1: 3.0, 2: 1.0, 3: 0.0}, 3)
