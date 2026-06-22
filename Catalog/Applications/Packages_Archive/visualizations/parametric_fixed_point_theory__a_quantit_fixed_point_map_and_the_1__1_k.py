"""Visualize parametric fixed-point stability and the K -> 1 blow-up.

Generates two panels:
  (left)  the fixed-point map t -> x*(t) for the family F_t(x) = K x + t,
          which is exactly L/(1-K)-Lipschitz (a straight line of that slope);
  (right) the amplification factor 1/(1-K) as K -> 1, the divergence that
          the x -> x+1 counterexample certifies as real.

Requires matplotlib and numpy.
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def x_star(t: float, K: float) -> float:
    """Fixed point of F_t(x) = K x + t, namely t / (1 - K)."""
    return t / (1.0 - K)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: fixed-point map for several contraction constants.
    ts = np.linspace(-2.0, 2.0, 200)
    for K in [0.2, 0.5, 0.8]:
        ys = [x_star(t, K) for t in ts]
        ax1.plot(ts, ys, label=f"K = {K}  (slope 1/(1-K) = {1/(1-K):.2f})")
    ax1.set_title("Fixed-point map t -> x*(t),  F_t(x) = Kx + t")
    ax1.set_xlabel("parameter t")
    ax1.set_ylabel("fixed point x*(t)")
    ax1.axhline(0, color="gray", lw=0.5)
    ax1.axvline(0, color="gray", lw=0.5)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: amplification factor 1/(1-K) diverging as K -> 1.
    Ks = np.linspace(0.0, 0.98, 200)
    ax2.plot(Ks, 1.0 / (1.0 - Ks), color="crimson")
    ax2.set_title("Stability amplification 1/(1-K) blows up as K -> 1")
    ax2.set_xlabel("contraction constant K")
    ax2.set_ylabel("1 / (1 - K)")
    ax2.set_ylim(0, 60)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("parametric_fixed_point.png", dpi=150)
    print("saved parametric_fixed_point.png")


if __name__ == "__main__":
    main()
