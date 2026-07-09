"""
Visualization: the constant-factor gap between the AFL target 1/(r+t-1) and the
bounded-degree guarantee 1/(rt), as a function of the number of colors r and the
uniformity t.

Produces a heatmap of the multiplicative gap rt/(r+t-1) = 1 + (r-1)(t-1)/(r+t-1)
and a line plot of the two fractions versus r for fixed t.
Requires matplotlib and numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    rs = np.arange(1, 9)
    ts = np.arange(1, 9)
    R, T = np.meshgrid(rs, ts)
    gap = (R * T) / (R + T - 1)  # rt/(r+t-1)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    im = ax1.imshow(gap, origin="lower", cmap="viridis",
                    extent=(0.5, 8.5, 0.5, 8.5), aspect="auto")
    ax1.set_xlabel("number of colors  r")
    ax1.set_ylabel("uniformity  t")
    ax1.set_title("Multiplicative gap  rt/(r+t-1) = 1 + (r-1)(t-1)/(r+t-1)")
    for i, t in enumerate(ts):
        for j, r in enumerate(rs):
            ax1.text(r, t, f"{(r*t)/(r+t-1):.2f}", ha="center", va="center",
                     color="white", fontsize=7)
    fig.colorbar(im, ax=ax1, label="gap factor")

    t_fixed = 3
    r_line = np.arange(1, 13)
    afl = 1.0 / (r_line + t_fixed - 1)
    loc = 1.0 / (r_line * t_fixed)
    ax2.plot(r_line, afl, "o-", label=f"AFL target 1/(r+t-1), t={t_fixed}")
    ax2.plot(r_line, loc, "s--", label=f"bounded-degree 1/(rt), t={t_fixed}")
    ax2.fill_between(r_line, loc, afl, alpha=0.2, color="red",
                     label="provable deficit")
    ax2.set_xlabel("number of colors  r")
    ax2.set_ylabel("guaranteed fraction of n")
    ax2.set_title("AFL fraction vs. local guarantee (t = 3)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("afl_gap.png", dpi=150)
    print("Saved afl_gap.png")


if __name__ == "__main__":
    main()
