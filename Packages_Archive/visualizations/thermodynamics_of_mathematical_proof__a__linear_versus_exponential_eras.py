"""Visualization: linear vs exponential erasure families (semilog).

Compares erased(C_m) = m against erased(B_m) = 2**m over the same parameter,
displaying the exponential separation between the two collapse families.
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def main() -> None:
    ms = list(range(0, 11))
    linear = [float(m) for m in ms]
    big = [float(2 ** m) for m in ms]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(ms, [max(v, 0.5) for v in linear], "o-", label="linear collapse  erased = m")
    ax.semilogy(ms, big, "s-", color="darkorange", label="big collapse  erased = 2^m")
    ax.set_xlabel("size parameter m")
    ax.set_ylabel("bits erased (log scale)")
    ax.set_title("Exponential erasure separation")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("erasure_separation.png", dpi=150)
    print("wrote erasure_separation.png")


if __name__ == "__main__":
    main()
