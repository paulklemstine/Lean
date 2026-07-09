"""Visualization: valuation-exponent chains in Z_p always stabilize (no staircase)."""
import matplotlib.pyplot as plt


def main() -> None:
    fig, ax = plt.subplots(figsize=(8, 5))
    # ascending ideal chains = non-increasing exponent sequences; all stabilize at 0
    chains = {
        "from (p^5)": [5, 4, 3, 2, 1, 0, 0, 0],
        "from (p^3)": [3, 2, 1, 0, 0, 0, 0, 0],
        "stalling":   [4, 4, 2, 2, 1, 0, 0, 0],
    }
    for label, exps in chains.items():
        ax.step(range(len(exps)), exps, where="post", marker="s", label=label)
    ax.set_xlabel("step in ascending ideal chain")
    ax.set_ylabel("valuation exponent k of (p^k)")
    ax.set_title("Z_p (DVR): ascending chains have non-increasing exponents -> stabilize")
    ax.legend()
    fig.tight_layout()
    fig.savefig("dvr_stabilizes.png", dpi=150)
    print("wrote dvr_stabilizes.png")


if __name__ == "__main__":
    main()
