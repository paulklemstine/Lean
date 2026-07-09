"""Visualization: exact certification of the envelope 3/2 <= c_k < 3.

Rather than floating point, this plots the three EXACT rational/integer
witnesses that drive the proof:
  - the lower witness   (3/2)^{k-1}  <= c_k^{k-1}
  - the constant value  c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}
  - the upper witness   c_k^{k-1} < (k-1) 2^{k-2} < 3^{k-1}
on a log scale, so the sandwich is visible directly.
"""
from __future__ import annotations

from fractions import Fraction
import matplotlib.pyplot as plt


def c_pow(k: int) -> Fraction:
    """Exact value of c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}."""
    return Fraction(k - 1) * (Fraction(2 * (k - 1), k)) ** (k - 2)


def main() -> None:
    ks = list(range(4, 26))
    lower = [float(Fraction(3, 2) ** (k - 1)) for k in ks]
    mid = [float(c_pow(k)) for k in ks]
    up_lin = [float(Fraction(k - 1) * 2 ** (k - 2)) for k in ks]
    up_three = [float(3 ** (k - 1)) for k in ks]

    fig, ax = plt.subplots(figsize=(9, 5.5))
    ax.semilogy(ks, up_three, "s-", color="#d1495b", label=r"$3^{k-1}$ (ceiling)")
    ax.semilogy(ks, up_lin, "^-", color="#e09f3e", label=r"$(k-1)2^{k-2}$")
    ax.semilogy(ks, mid, "o-", color="#1b4965", label=r"$c_k^{\,k-1}$")
    ax.semilogy(ks, lower, "v-", color="#43aa8b", label=r"$(3/2)^{k-1}$ (floor)")
    ax.set_xlabel("cycle length k")
    ax.set_ylabel(r"value of $c_k^{\,k-1}$ (log scale)")
    ax.set_title("Exact sandwich certifying 3/2 <= c_k < 3")
    ax.legend()
    ax.grid(alpha=0.3, which="both")
    fig.tight_layout()
    fig.savefig("envelope_certificate.png", dpi=150)

    # Also print an exact certificate table.
    for k in ks:
        assert Fraction(3, 2) ** (k - 1) <= c_pow(k) < 3 ** (k - 1)
    print("exact certificate verified for 4 <= k <= 25; wrote envelope_certificate.png")


if __name__ == "__main__":
    main()
