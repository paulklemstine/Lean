"""
Visualization of the Cusick density landscape and the digit-sum bias.

Generates two figures:
  (1) c_t for t = 1..63 against the DKS floor 1/2 + 2^{-(2 s2(t)+1)}, colored by
      s2(t), showing densities are dyadic rationals always above the floor.
  (2) The carry-budget picture: for fixed t, the fraction of n in [0,P) with
      exactly k carries, illustrating P_t(n) <=> carries <= s2(t).

Requires matplotlib. Run:  python3 visualize_cusick.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt


def s2(n: int) -> int:
    return bin(n).count("1")


def carries(t: int, n: int) -> int:
    return s2(t) + s2(n) - s2(n + t)


def period(t: int) -> int:
    return 2 ** (max(1, t.bit_length()) + s2(t))


def cusick_count(t: int, N: int) -> int:
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))


def density(t: int) -> Fraction:
    P = period(t)
    return Fraction(cusick_count(t, P), P)


def floor(t: int) -> Fraction:
    return Fraction(1, 2) + Fraction(1, 2 ** (2 * s2(t) + 1))


def main() -> None:
    ts = list(range(1, 64))
    dens = [float(density(t)) for t in ts]
    flr = [float(floor(t)) for t in ts]
    weight = [s2(t) for t in ts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    sc = ax1.scatter(ts, dens, c=weight, cmap="viridis", s=40, zorder=3,
                     label="c_t (exact)")
    ax1.scatter(ts, flr, marker="_", color="crimson", s=80, zorder=2,
                label="DKS floor")
    ax1.axhline(0.5, color="gray", ls="--", lw=1, label="trivial 1/2")
    ax1.set_xlabel("shift t")
    ax1.set_ylabel("density")
    ax1.set_title("Cusick density c_t vs DKS floor (color = s2(t))")
    ax1.legend(loc="upper right")
    fig.colorbar(sc, ax=ax1, label="s2(t)")

    # Carry distribution for t = 7 over one period.
    t = 7
    P = period(t)
    maxc = max(carries(t, n) for n in range(P))
    counts: List[int] = [0] * (maxc + 1)
    for n in range(P):
        counts[carries(t, n)] += 1
    fracs = [c / P for c in counts]
    bars = ax2.bar(range(maxc + 1), fracs,
                   color=["seagreen" if k <= s2(t) else "lightcoral"
                          for k in range(maxc + 1)])
    ax2.axvline(s2(t) + 0.5, color="black", ls="--",
                label=f"budget s2({t}) = {s2(t)}")
    ax2.set_xlabel("number of carries adding t")
    ax2.set_ylabel("fraction of n in [0,P)")
    ax2.set_title(f"Carry budget for t={t}: green = Cusick success")
    ax2.legend()

    plt.tight_layout()
    plt.savefig("cusick_landscape.png", dpi=150)
    print("Saved cusick_landscape.png")


if __name__ == "__main__":
    main()
