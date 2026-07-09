"""
Visualization: empirical Cusick density c_t over [0, 2^k) against the explicit
lower bound 1/2 + 2^{-(2 s2(t)+1)}, plus the exact t=1 staircase showing c_1=3/4.

Produces 'cusick_density.png'. Requires matplotlib.
"""
from __future__ import annotations

import matplotlib.pyplot as plt


def s2(n: int) -> int:
    return bin(n).count("1")


def cusick_holds(t: int, n: int) -> bool:
    return s2(n) <= s2(n + t)


def main() -> None:
    k = 20
    N = 1 << k
    ts = list(range(1, 33))
    emp = [sum(1 for n in range(N) if cusick_holds(t, n)) / N for t in ts]
    bound = [0.5 + 2.0 ** (-(2 * s2(t) + 1)) for t in ts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.scatter(ts, emp, c="crimson", label=r"empirical $c_t$", zorder=3)
    ax1.scatter(ts, bound, c="navy", marker="_", s=160,
                label=r"bound $\frac12+2^{-(2s_2(t)+1)}$", zorder=2)
    ax1.axhline(0.5, color="gray", ls="--", lw=1)
    for t, e, b in zip(ts, emp, bound):
        ax1.plot([t, t], [b, e], color="lightgray", lw=1, zorder=1)
    ax1.set_xlabel("step size t")
    ax1.set_ylabel("density")
    ax1.set_title(r"Cusick density $c_t$ exceeds the explicit bound")
    ax1.legend()

    # exact t=1 running density staircase
    m = 64
    xs = list(range(4 * m))
    run = []
    g = 0
    for n in xs:
        if cusick_holds(1, n):
            g += 1
        run.append(g / (n + 1))
    ax2.plot(xs, run, color="darkgreen", lw=1.2)
    ax2.axhline(0.75, color="crimson", ls="--", label=r"$c_1=3/4$")
    ax2.axhline(0.625, color="navy", ls=":", label=r"bound $5/8$")
    ax2.set_xlabel("N")
    ax2.set_ylabel("running density on [0,N)")
    ax2.set_title(r"$t=1$: running density converges to $3/4$")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("cusick_density.png", dpi=150)
    print("wrote cusick_density.png")


if __name__ == "__main__":
    main()
