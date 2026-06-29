"""Visualization: the HVZK bijection as a permutation grid on a small field.

For a fixed secret x and field Z_p (small p), the map r -> s = r + x*c (mod p)
is, for each challenge c, a bijection of Z_p. This script draws, for several
challenges, the permutation that the bijection induces on responses, making the
distributional equality of honest and simulated transcripts visible: each row
is just a cyclic shift, hence a relabeling of a uniform set.
"""

from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np


def hvzk_permutation_grid(p: int = 23, x: int = 5) -> None:
    challenges = list(range(p))
    grid = np.zeros((p, p), dtype=int)
    for c in challenges:
        for r in range(p):
            s = (r + x * c) % p  # forward bijection honest->sim on responses
            grid[c, r] = s

    fig, ax = plt.subplots(figsize=(8, 8))
    im = ax.imshow(grid, cmap="twilight", origin="lower")
    ax.set_xlabel("honest randomness r")
    ax.set_ylabel("challenge c")
    ax.set_title(f"HVZK bijection  s = r + x·c (mod {p}),  x = {x}\n"
                 "each row is a bijection of Z_p (uniform <-> uniform)")
    fig.colorbar(im, ax=ax, label="simulated response s")
    fig.tight_layout()
    fig.savefig("hvzk_bijection_grid.png", dpi=150)
    print("saved hvzk_bijection_grid.png")


if __name__ == "__main__":
    hvzk_permutation_grid()
