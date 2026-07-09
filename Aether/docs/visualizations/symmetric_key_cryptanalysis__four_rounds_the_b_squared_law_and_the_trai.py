"""Visualization: branch number B vs. guaranteed active S-boxes (B^2 law).

Plots the wide-trail four-round guarantee min active S-boxes = B^2 as a
function of the linear-layer branch number B, highlighting AES (B = 5 -> 25)
and the corresponding 2^(-6 * B^2) trail-probability ceiling.  Requires
matplotlib.
"""

from typing import List
import matplotlib.pyplot as plt


def main() -> None:
    branch_numbers: List[int] = list(range(2, 9))
    guarantees: List[int] = [B * B for B in branch_numbers]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))

    ax1.bar([str(B) for B in branch_numbers], guarantees, color="#4C72B0")
    ax1.set_xlabel("branch number B of the mixing layer")
    ax1.set_ylabel("guaranteed active S-boxes over 4 rounds (B^2)")
    ax1.set_title("Wide-trail four-round guarantee = B^2")
    idx = branch_numbers.index(5)
    ax1.patches[idx].set_color("#C44E52")
    ax1.annotate("AES: 25", xy=(idx, 25), xytext=(idx, 33),
                 ha="center", arrowprops=dict(arrowstyle="->"))

    exponents = [6 * B * B for B in branch_numbers]
    ax2.plot(branch_numbers, exponents, "o-", color="#55A868")
    ax2.axhline(128, color="gray", ls="--", label="security threshold (128)")
    ax2.set_xlabel("branch number B")
    ax2.set_ylabel("trail probability ceiling: -log2 = 6 * B^2")
    ax2.set_title("Four-round trail probability ceiling 2^(-6 B^2)")
    ax2.annotate("AES: 2^-150", xy=(5, 150), xytext=(5.2, 170),
                 arrowprops=dict(arrowstyle="->"))
    ax2.legend()

    fig.tight_layout()
    fig.savefig("branch_number_law.png", dpi=150)
    print("Saved branch_number_law.png")


if __name__ == "__main__":
    main()
