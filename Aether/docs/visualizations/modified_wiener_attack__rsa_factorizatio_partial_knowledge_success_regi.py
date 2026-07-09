"""Visualization: the partial-knowledge success region for the modified Wiener attack.

Plots, for the instance n = p*q = 99799811 (p=10007, q=9973), how the maximum
recoverable private exponent d grows as more leading bits of p+q are revealed,
overlaying the classical Wiener bound n^(1/4). Requires matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt

def max_recoverable_d(n: int, k: int, delta: int) -> float:
    """Largest d satisfying the smallness condition 2*d*(k*Delta + 1) < n."""
    return (n - 1) / (2 * (k * delta + 1))

def main() -> None:
    p, q = 10007, 9973
    n, true_sum, k = p * q, p + q, 28
    bitlen = true_sum.bit_length()
    known_bits = list(range(0, bitlen + 1))
    dmax = []
    for kb in known_bits:
        unknown = bitlen - kb
        delta = (1 << unknown) if unknown > 0 else 1
        dmax.append(max_recoverable_d(n, k, delta))
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(known_bits, dmax, "o-", color="#2b6cb0",
                label=r"max recoverable $d$ (smallness bound)")
    ax.axhline(n ** 0.25, color="#c53030", ls="--",
               label=r"classical Wiener $n^{1/4}$")
    ax.set_xlabel("leading bits of $p+q$ known")
    ax.set_ylabel("maximum recoverable private exponent $d$")
    ax.set_title("Partial knowledge amplifies the modified Wiener attack")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("wiener_success_region.png", dpi=150)
    print("saved wiener_success_region.png")

if __name__ == "__main__":
    main()
