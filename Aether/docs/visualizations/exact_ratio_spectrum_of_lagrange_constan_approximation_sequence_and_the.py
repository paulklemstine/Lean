"""Visualization: q*||qx|| sequence and the dilation ratio window."""
import math
import matplotlib.pyplot as plt


def ndist(y: float) -> float:
    return abs(y - round(y))


def main() -> None:
    phi = (1 + math.sqrt(5)) / 2
    sqrt2 = math.sqrt(2)
    qs = list(range(1, 120))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Left: q*||qx|| for two badly approximable numbers, with liminf floor.
    ax1.plot(qs, [q * ndist(q * phi) for q in qs], ".-", label="x = golden ratio")
    ax1.plot(qs, [q * ndist(q * sqrt2) for q in qs], ".-", label="x = sqrt(2)")
    ax1.axhline(1 / math.sqrt(5), ls="--", color="gray",
                label="k(phi) = 1/sqrt5")
    ax1.set_xlabel("denominator q")
    ax1.set_ylabel("q * ||q x||")
    ax1.set_title("Approximation function and its liminf (Lagrange constant)")
    ax1.legend()

    # Right: dilation ratio window [1/n, n] vs. exact sqrt ratios.
    ns = [2, 3, 4, 5]
    ax2.fill_between(ns, [1 / n for n in ns], ns, alpha=0.2,
                     label="window [1/n, n]")
    ax2.plot(ns, ns, "k-", lw=1)
    ax2.plot(ns, [1 / n for n in ns], "k-", lw=1)
    ax2.axhline(1.0, color="gray", ls=":")
    ax2.set_xlabel("dilation factor n = |det|")
    ax2.set_ylabel("k(n x)/k(x)")
    ax2.set_title("Ratio spectrum window [|det|^-1, |det|]")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("lagrange_spectrum.png", dpi=150)
    print("wrote lagrange_spectrum.png")


if __name__ == "__main__":
    main()
