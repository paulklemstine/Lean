"""Visualization: additive depth vs. multiplicative tropical shadow (log scale)."""
from __future__ import annotations
import matplotlib.pyplot as plt

def tropical_shadow(depth: int, base: int = 2) -> int:
    return base ** depth

def main() -> None:
    depths = list(range(0, 13))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for base in (2, 3):
        shadows = [tropical_shadow(d, base) for d in depths]
        ax1.plot(depths, shadows, marker="o", label=f"base={base}")
        ax2.semilogy(depths, shadows, marker="o", label=f"base={base}")

    ax1.set_title("Tropical shadow T(d) = base**d (linear axis)")
    ax1.set_xlabel("valuation depth d"); ax1.set_ylabel("tropical Lipschitz rate")
    ax1.legend(); ax1.grid(True, alpha=0.3)

    ax2.set_title("Same data, log y-axis: a straight line\n(depth is the logarithm of the rate)")
    ax2.set_xlabel("valuation depth d"); ax2.set_ylabel("rate (log scale)")
    ax2.legend(); ax2.grid(True, alpha=0.3, which="both")

    fig.suptitle("Valuation depth is the logarithm of the tropical Lipschitz constant")
    fig.tight_layout()
    fig.savefig("depth_vs_shadow.png", dpi=140)
    print("saved depth_vs_shadow.png")

if __name__ == "__main__":
    main()
