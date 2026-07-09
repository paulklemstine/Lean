"""Visualization: binary entropy curve and the special point at alpha = 1/3."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def H(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def main() -> None:
    ps = [i / 400 for i in range(1, 400)]
    hs = [H(p) for p in ps]
    a = 1 / 3
    ha = H(a)  # = log2 3 - 2/3

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ps, hs, label=r"$H(p)$")
    ax.scatter([a], [ha], color="crimson", zorder=5)
    ax.annotate(
        rf"$H(1/3)={ha:.4f}$" + "\n" + r"$2^{H(1/3)}=3/2^{2/3}$",
        xy=(a, ha), xytext=(0.45, 0.55),
        arrowprops=dict(arrowstyle="->"))
    ax.set_xlabel("p")
    ax.set_ylabel("H(p)  (bits)")
    ax.set_title("The base 3/2^(2/3) is the entropy 2^{H(1/3)}")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("entropy_curve.png", dpi=150)
    print("wrote entropy_curve.png")


if __name__ == "__main__":
    main()
