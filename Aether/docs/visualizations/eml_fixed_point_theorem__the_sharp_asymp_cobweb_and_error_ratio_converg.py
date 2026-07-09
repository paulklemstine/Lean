"""Visualization: cobweb diagram and error-ratio convergence for the EML map.

Generates a two-panel figure:
  (left)  the cobweb plot of x_{n+1} = exp(a) log(b x + c) showing the staircase
          spiralling into the fixed point x* where the curve meets the diagonal;
  (right) the measured consecutive-error ratio converging to the local rate
          |f'(x*)| (solid line), shown against the looser interval bound rho.

Requires matplotlib and numpy. Saves 'eml_fixed_point.png'.
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def f(x: float, a: float, b: float, c: float) -> float:
    return math.exp(a) * math.log(b * x + c)


def main() -> None:
    a, b, c = 0.2, 1.0, 2.0
    lo, hi = 1.0, 3.0

    # fixed point
    x = 3.0
    for _ in range(100_000):
        nx = f(x, a, b, c)
        if abs(nx - x) < 1e-15:
            x = nx
            break
        x = nx
    xstar = x
    local_rate = abs(math.exp(a) * b / (b * xstar + c))
    rho = max(abs(math.exp(a) * b / (b * lo + c)),
              abs(math.exp(a) * b / (b * hi + c)))

    fig, (axL, axR) = plt.subplots(1, 2, figsize=(12, 5))

    # ---- cobweb ----
    xs_curve = np.linspace(lo, hi, 400)
    ys_curve = [f(xx, a, b, c) for xx in xs_curve]
    axL.plot(xs_curve, ys_curve, "b-", lw=2, label=r"$f(x)=e^{a}\log(bx+c)$")
    axL.plot([lo, hi], [lo, hi], "k--", lw=1, label=r"$y=x$")

    x0 = 3.0
    cob_x: List[float] = [x0]
    cob_y: List[float] = [x0]
    xx = x0
    for _ in range(12):
        yy = f(xx, a, b, c)
        cob_x += [xx, yy]
        cob_y += [yy, yy]
        xx = yy
    axL.plot(cob_x, cob_y, "r-", lw=1, alpha=0.7)
    axL.plot([xstar], [xstar], " go", ms=9, label=fr"$x^*={xstar:.4f}$")
    axL.set_title("Cobweb of the EML iteration")
    axL.set_xlabel("$x_n$")
    axL.set_ylabel("$x_{n+1}$")
    axL.legend()

    # ---- ratio convergence ----
    seq = [x0]
    for _ in range(16):
        seq.append(f(seq[-1], a, b, c))
    ratios = [abs(seq[k] - xstar) / abs(seq[k - 1] - xstar)
              for k in range(1, len(seq)) if abs(seq[k - 1] - xstar) > 1e-12]
    axR.plot(range(len(ratios)), ratios, "mo-", label="measured error ratio")
    axR.axhline(local_rate, color="g", ls="-", lw=2,
                label=fr"$|f'(x^*)|={local_rate:.4f}$ (sharp rate)")
    axR.axhline(rho, color="gray", ls="--", lw=1.5,
                label=fr"$\rho={rho:.4f}$ (interval bound)")
    axR.set_title("Consecutive-error ratio converges to the local rate")
    axR.set_xlabel("step $n$")
    axR.set_ylabel(r"$|x_{n+1}-x^*|/|x_n-x^*|$")
    axR.legend()

    fig.tight_layout()
    fig.savefig("eml_fixed_point.png", dpi=130)
    print("saved eml_fixed_point.png")


if __name__ == "__main__":
    main()
