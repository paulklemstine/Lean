"""Visualization: soft maximum dequantizing to the tropical max as c grows."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def scaled_lse2(x1: np.ndarray, x2: float, c: float) -> np.ndarray:
    m = np.maximum(x1, x2)
    return m + np.log(np.exp(c * (x1 - m)) + np.exp(c * (x2 - m))) / c


def main() -> None:
    xs = np.linspace(-2.0, 2.0, 400)
    fixed = 0.0
    plt.figure(figsize=(8, 5))
    plt.plot(xs, np.maximum(xs, fixed), "k--", lw=2, label="max(x, 0) (tropical)")
    for c in (1.0, 2.0, 5.0, 20.0):
        plt.plot(xs, scaled_lse2(xs, fixed, c), label=f"soft max, c={c:g}")
    plt.title("EML soft maximum -> tropical max  (error <= log2 / c)")
    plt.xlabel("x"); plt.ylabel("value"); plt.legend(); plt.grid(alpha=0.3)
    plt.tight_layout(); plt.savefig("dequantization.png", dpi=150)
    print("saved dequantization.png")


if __name__ == "__main__":
    main()
