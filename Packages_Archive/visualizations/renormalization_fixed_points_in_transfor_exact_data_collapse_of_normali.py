"""Visualization: exact data collapse of normalized RG error curves.

Plots the normalized error |p^n x|_p / |x|_p for several starting values x and
shows that they all collapse exactly onto the master curve n -> p^(-n).
Requires matplotlib.
"""
from fractions import Fraction
import matplotlib.pyplot as plt


def padic_abs(x: Fraction, p: int) -> float:
    if x == 0:
        return 0.0
    num, den, v = abs(x.numerator), x.denominator, 0
    while num % p == 0:
        num //= p; v += 1
    while den % p == 0:
        den //= p; v -= 1
    return float(p) ** (-v)


def main() -> None:
    p, n_max = 3, 8
    ns = list(range(n_max + 1))
    plt.figure(figsize=(8, 5))
    for x in [Fraction(1), Fraction(5), Fraction(7, 2), Fraction(2, 3)]:
        base = padic_abs(x, p)
        curve = [padic_abs((p ** n) * x, p) / base for n in ns]
        plt.plot(ns, curve, "o", label=f"x = {x}")
    plt.plot(ns, [p ** (-n) for n in ns], "k--", lw=2,
             label="master curve $p^{-n}$")
    plt.yscale("log")
    plt.xlabel("RG step n (prompt-length rescaling)")
    plt.ylabel("normalized error $|p^n x|_p / |x|_p$")
    plt.title(f"Exact data collapse onto $p^{{-n}}$ (p = {p})")
    plt.legend()
    plt.grid(True, which="both", ls=":")
    plt.tight_layout()
    plt.savefig("padic_data_collapse.png", dpi=150)
    print("wrote padic_data_collapse.png")


if __name__ == "__main__":
    main()
