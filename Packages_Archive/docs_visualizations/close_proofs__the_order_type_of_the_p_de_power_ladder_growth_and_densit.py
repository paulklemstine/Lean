"""Visualize the power ladder growth rates and why the ladder does not collapse.
Plots log2(size) = n^k for several rungs, and the parity-glued intermediate rate.
Requires matplotlib."""
from __future__ import annotations
import matplotlib.pyplot as plt


def main() -> None:
    ns = list(range(0, 9))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # log2 of size = n^k for rungs k=1,2,3 (plot the exponent, since sizes are huge)
    for k in (1, 2, 3):
        ax1.plot(ns, [n ** k for n in ns], marker="o", label=f"powSystem {k}: log2 size = n^{k}")
    ax1.set_title("Power ladder: exponents n^k (infinite height)")
    ax1.set_xlabel("theorem index n")
    ax1.set_ylabel("log2(proof size)")
    ax1.legend(); ax1.grid(True, alpha=0.3)

    # parity-glued intermediate degree between rungs k=1 and k=2
    lo = [n ** 1 for n in ns]
    hi = [n ** 2 for n in ns]
    inter = [(n ** 2 if n % 2 == 0 else n ** 1) for n in ns]
    ax2.plot(ns, lo, "--", label="powSystem 1 (n^1)")
    ax2.plot(ns, hi, "--", label="powSystem 2 (n^2)")
    ax2.plot(ns, inter, marker="s", label="interPowSys 1 (parity-glued)")
    ax2.set_title("Density: a degree strictly between two rungs")
    ax2.set_xlabel("theorem index n")
    ax2.set_ylabel("log2(proof size)")
    ax2.legend(); ax2.grid(True, alpha=0.3)

    fig.suptitle("The order type of the p-degrees")
    fig.tight_layout()
    fig.savefig("pdegree_ladder.png", dpi=140)
    print("wrote pdegree_ladder.png")


if __name__ == "__main__":
    main()
