"""Visualization: the quadratic EML network and its certified 4/9 error band.

Generates two panels:
  (left)  emlQuadApprox(h, x) vs the exact parabola x^2 on [0,1] for several h,
  (right) the worst-case error sup_x |emlQuadApprox(h,x) - x^2| against the
          proven bound (4/9) h on a log-log scale, exhibiting the O(1/n) rate.

Saves 'eml_quadratic_rate.png'. Requires matplotlib + numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def eml_quad_approx(h: float, x: np.ndarray) -> np.ndarray:
    return (2.0 / h ** 2) * (np.exp(h * x) - 1.0 - h * x)


def main() -> None:
    x = np.linspace(0.0, 1.0, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(x, x ** 2, "k-", lw=2.5, label=r"$x^2$ (exact)")
    for h in (1.0, 0.5, 0.25, 0.1):
        ax1.plot(x, eml_quad_approx(h, x), "--", lw=1.6,
                 label=fr"$\mathrm{{emlQuadApprox}}_{{h={h}}}$")
    ax1.set_title(r"EML network $\frac{2}{h^2}(e^{hx}-1-hx)\to x^2$")
    ax1.set_xlabel("x"); ax1.set_ylabel("value"); ax1.legend(); ax1.grid(alpha=0.3)

    hs = np.array([2.0 ** (-k) for k in range(0, 11)])
    grid = np.linspace(0.0, 1.0, 2001)
    sup_err = np.array([np.max(np.abs(eml_quad_approx(h, grid) - grid ** 2))
                        for h in hs])
    ax2.loglog(hs, sup_err, "o-", label="empirical sup error")
    ax2.loglog(hs, (4.0 / 9.0) * hs, "r--", label=r"proven bound $\frac{4}{9}h$")
    ax2.loglog(hs, (1.0 / 3.0) * hs, "g:", label=r"leading slope $\frac{1}{3}h$")
    ax2.set_title("Certified Jackson-type rate (log-log)")
    ax2.set_xlabel("step size h = 1/n"); ax2.set_ylabel("sup error")
    ax2.legend(); ax2.grid(alpha=0.3, which="both")

    fig.suptitle("EML Interpolation Theory: approximating $x^2$ with an explicit rate")
    fig.tight_layout()
    fig.savefig("eml_quadratic_rate.png", dpi=150)
    print("saved eml_quadratic_rate.png")


if __name__ == "__main__":
    main()
