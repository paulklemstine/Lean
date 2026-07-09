"""
Visualization: growth-rate ladder of EML transmonomials.

Plots log10|f(x)| for representative transmonomials of increasing tower height,
showing that each higher tower eventually dominates every lower one, and that
exp x overtakes arbitrarily large powers of x.
Requires matplotlib and numpy.
"""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    x = np.linspace(2.0, 6.0, 400)
    series = {
        "log x":        np.log(x),
        "x^3":          x ** 3,
        "x^20":         x ** 20,
        "exp x":        np.exp(x),
        "exp(exp x)":   np.exp(np.exp(x)),
    }
    plt.figure(figsize=(9, 6))
    for label, y in series.items():
        plt.plot(x, np.log10(np.abs(y) + 1e-300), label=label, linewidth=2)
    plt.xlabel("x")
    plt.ylabel("log10 |f(x)|  (orders of magnitude)")
    plt.title("Asymptotic dominance ladder: higher towers eventually win")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("transseries_ladder.png", dpi=150)
    print("saved transseries_ladder.png")


if __name__ == "__main__":
    main()
