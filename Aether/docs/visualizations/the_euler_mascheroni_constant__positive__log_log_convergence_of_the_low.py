"""Visualization: convergence of the sandwich approximants to gamma.

Plots, on a log-log scale, the errors of the lower approximant
ell_n = H_n - log(n+1), the upper approximant u_n = H_n - log n, and their
average m_n = (ell_n + u_n)/2, against n. The one-sided errors decay like 1/n
(slope -1), while the averaged error decays like 1/n^2 (slope -2), exhibiting
the provable acceleration from cancelling the leading 1/n term.

Run:  python3 _viz_convergence.py   (saves euler_mascheroni_convergence.png)
"""

from __future__ import annotations

import math

import numpy as np
import matplotlib.pyplot as plt

GAMMA = 0.57721566490153286


def harmonic(n: int) -> float:
    return sum(1.0 / k for k in range(1, n + 1))


def main() -> None:
    ns = [2 ** j for j in range(1, 14)]
    e_low, e_up, e_mid = [], [], []
    for n in ns:
        h = harmonic(n)
        ell = h - math.log(n + 1)
        up = h - math.log(n)
        e_low.append(abs(ell - GAMMA))
        e_up.append(abs(up - GAMMA))
        e_mid.append(abs(0.5 * (ell + up) - GAMMA))

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.loglog(ns, e_low, "o-", color="#2980b9", label=r"$|\ell_n - \gamma|$ (lower)")
    ax.loglog(ns, e_up, "s-", color="#c0392b", label=r"$|u_n - \gamma|$ (upper)")
    ax.loglog(ns, e_mid, "^-", color="#27ae60", label=r"$|m_n - \gamma|$ (averaged)")

    ax.loglog(ns, [0.5 / n for n in ns], "k--", alpha=0.5, label=r"$1/(2n)$ guide")
    ax.loglog(ns, [1.0 / (6 * n * n) for n in ns], "k:", alpha=0.5,
              label=r"$1/(6n^2)$ guide")

    ax.set_xlabel("n")
    ax.set_ylabel("absolute error")
    ax.set_title("Convergence of sandwich approximants to the Euler--Mascheroni constant")
    ax.legend()
    ax.grid(True, which="both", alpha=0.25)

    fig.tight_layout()
    fig.savefig("euler_mascheroni_convergence.png", dpi=150)
    print("saved euler_mascheroni_convergence.png")


if __name__ == "__main__":
    main()
