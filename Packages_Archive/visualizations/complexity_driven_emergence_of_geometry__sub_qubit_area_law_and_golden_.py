"""Standalone visualization: fusion dimension vs. naive qubit count and the
golden-ratio encoding threshold.  Generates 'emergent_geometry.png'."""

from __future__ import annotations

from math import sqrt
from typing import List

import matplotlib.pyplot as plt

PHI: float = (1.0 + sqrt(5.0)) / 2.0


def fusion_count(n: int) -> int:
    if n == 0:
        return 1
    if n == 1:
        return 2
    a, b = 1, 2
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def crit_bond(n: int) -> float:
    return 1.0 + n / 10.0


def main() -> None:
    ns: List[int] = list(range(0, 13))
    fc: List[int] = [fusion_count(n) for n in ns]
    qubit: List[int] = [2 ** n for n in ns]
    dc: List[float] = [crit_bond(n) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.semilogy(ns, qubit, "o--", label=r"naive qubit count $2^n$", color="crimson")
    ax1.semilogy(ns, fc, "s-", label=r"fusion dim $\mathrm{fc}(n)=F_{n+2}$", color="navy")
    ax1.set_xlabel("chain length n")
    ax1.set_ylabel("Hilbert-space dimension (log scale)")
    ax1.set_title("Sub-qubit area law:  fc(n) < 2^n  (strict for n >= 2)")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    enc = [d < PHI for d in dc]
    colors = ["seagreen" if e else "darkorange" for e in enc]
    ax2.bar(ns, dc, color=colors, alpha=0.85)
    ax2.axhline(PHI, color="purple", linestyle="--", linewidth=2,
                label=fr"$\varphi = {PHI:.3f}$")
    ax2.axvline(6.5, color="black", linestyle=":", label="N_critical = 7")
    ax2.set_xlabel("chain length n")
    ax2.set_ylabel(r"critical bond dimension $D_c(n)=1+n/10$")
    ax2.set_title("Encoding threshold (green=encodable, orange=not)")
    ax2.legend()
    ax2.grid(True, axis="y", alpha=0.3)

    fig.tight_layout()
    fig.savefig("emergent_geometry.png", dpi=150)
    print("wrote emergent_geometry.png")


if __name__ == "__main__":
    main()
