"""Visualization: special-soundness extraction across all challenge pairs.

For a fixed Schnorr instance, every pair of distinct challenges (c1, c2) on a
shared commitment recovers the SAME secret x via the field extractor
x = (s1 - s2) * (c1 - c2)^{-1} mod p. This heatmap shows the extracted value is
constant (and equal to x) across the whole challenge grid -- a visual proof of
the robustness of special soundness.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def inv_mod(a: int, p: int) -> int:
    return pow(a % p, -1, p)


def main() -> None:
    p, g = 101, 7
    x = 42
    r = 17
    Y = (x * g) % p
    t = (r * g) % p

    n = 40
    grid = np.full((n, n), np.nan)
    for c1 in range(1, n + 1):
        for c2 in range(1, n + 1):
            if c1 == c2:
                continue
            s1 = (r + c1 * x) % p
            s2 = (r + c2 * x) % p
            x_rec = ((s1 - s2) * inv_mod(c1 - c2, p)) % p
            grid[c1 - 1, c2 - 1] = x_rec

    fig, ax = plt.subplots(figsize=(7, 6))
    im = ax.imshow(grid, cmap="viridis", origin="lower")
    ax.set_title(f"Extracted witness across challenge pairs (true x = {x})")
    ax.set_xlabel("challenge c2")
    ax.set_ylabel("challenge c1")
    fig.colorbar(im, ax=ax, label="extracted x (mod p)")
    fig.tight_layout()
    fig.savefig("extraction_heatmap.png", dpi=120)
    print("saved extraction_heatmap.png")


if __name__ == "__main__":
    main()
