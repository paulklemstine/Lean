"""Visualization: the bi-Holder distortion corridor as a chain grows."""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def distortion_corridor(d_source: float, r: float, max_links: int):
    ks: List[int] = list(range(0, max_links + 1))
    upper = [d_source / (r ** k) for k in ks]
    lower = [d_source * (r ** k) for k in ks]
    return ks, lower, upper


def main() -> None:
    d_source = math.log(2) / math.log(3)   # Cantor set dimension
    r = 0.8
    ks, lower, upper = distortion_corridor(d_source, r, 10)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.fill_between(ks, lower, upper, alpha=0.25, color="#3b7dd8",
                    label="reachable image dimensions")
    ax.plot(ks, upper, "o-", color="#d83b3b",
            label="upper bound  d/r^k (Holder inflation)")
    ax.plot(ks, lower, "o-", color="#2a9d4a",
            label="lower bound  d*r^k (inverse Holder)")
    ax.axhline(d_source, ls="--", color="gray", label="source dimension")
    ax.set_xlabel("number of composed bi-Holder links  k")
    ax.set_ylabel("Hausdorff dimension of image")
    ax.set_title(f"Composite distortion corridor (link exponent r = {r})")
    ax.legend(); ax.grid(alpha=0.3); fig.tight_layout()
    fig.savefig("distortion_corridor.png", dpi=150)


if __name__ == "__main__":
    main()
