"""Visualization: the tight ramps fitting underneath f and the discrepancy gap.

Requires matplotlib. Plots a non-order-convex target, its canonical max-plus
reconstruction, and shades the discrepancy region.
"""
from typing import List, Sequence
import matplotlib.pyplot as plt


def tight_coeff(f: Sequence[float], phi_k: Sequence[float]) -> float:
    return min(fx - pk for fx, pk in zip(f, phi_k))


def reconstruct(f: Sequence[float], phi: Sequence[Sequence[float]]) -> List[float]:
    coeffs = [tight_coeff(f, m) for m in phi]
    return [max(coeffs[k] + phi[k][x] for k in range(len(phi)))
            for x in range(len(f))]


def main() -> None:
    xs = list(range(6))
    f = [0.0, 2.0, 1.0, 3.0, 1.5, 4.0]            # bumpy, not order-convex
    phi = [[float(x) for x in xs], [float(5 - x) for x in xs]]  # two ramps
    rec = reconstruct(f, phi)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(xs, f, "o-", label="f (target)", linewidth=2)
    ax.plot(xs, rec, "s--", label="canonical reconstruction", linewidth=2)
    coeffs = [tight_coeff(f, m) for m in phi]
    for k, m in enumerate(phi):
        ax.plot(xs, [coeffs[k] + m[x] for x in xs], ":", alpha=0.6,
                label=f"tight ramp {k}")
    ax.fill_between(xs, rec, f, alpha=0.2, color="red", label="discrepancy gap")
    ax.set_title("Tropical max-plus reconstruction and the discrepancy")
    ax.set_xlabel("domain point x")
    ax.set_ylabel("value")
    ax.legend()
    plt.tight_layout()
    plt.savefig("discrepancy_visualization.png", dpi=150)
    print("saved discrepancy_visualization.png")


if __name__ == "__main__":
    main()
