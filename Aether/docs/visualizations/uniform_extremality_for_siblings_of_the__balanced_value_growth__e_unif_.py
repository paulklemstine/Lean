from fractions import Fraction
from math import comb
import matplotlib.pyplot as plt


def expected_empty_uniform(n: int, j: int) -> Fraction:
    return Fraction(n) * sum(
        (Fraction((-1) ** s * comb(n - 1, s), (1 + s) ** j) for s in range(n)),
        Fraction(0),
    )


def plot_balanced_growth() -> None:
    Ns = list(range(2, 31))
    plt.figure(figsize=(8, 5))
    for j in (2, 3, 5):
        ys = [float(expected_empty_uniform(n, j)) for n in Ns]
        plt.plot(Ns, ys, marker="o", markersize=3, label=f"j = {j}")
    plt.plot(Ns, Ns, color="gray", linestyle="--", alpha=0.5, label="y = N")
    plt.title("Balanced-distribution expected empty count vs. N")
    plt.xlabel("number of coupon types N")
    plt.ylabel("E_unif[U_j^N]")
    plt.legend()
    plt.tight_layout()
    plt.savefig("balanced_growth.png", dpi=150)
    print("saved balanced_growth.png")


if __name__ == "__main__":
    plot_balanced_growth()
