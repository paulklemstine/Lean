"""Standalone visualization: independence ratio vs. forced chromatic lower bound."""
import matplotlib.pyplot as plt
import numpy as np


def main() -> None:
    ratios = np.linspace(0.10, 0.60, 400)
    lower_bound = 1.0 / ratios  # chi_f >= 1/i(G)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ratios, lower_bound, lw=2.5, color="#1f4e79",
            label=r"forced $\chi_f \geq 1/i(G)$")
    ax.axvline(0.25, color="crimson", ls="--", lw=2, label="frontier $i = 1/4$")
    ax.axhline(4.0, color="crimson", ls=":", lw=1.5)
    ax.fill_between(ratios, 4, lower_bound, where=(ratios < 0.25),
                    color="crimson", alpha=0.15, label=r"$\chi_f > 4$ region")

    for k, name in [(1/3, "$K_3$ (triangle): $i=1/3$"),
                    (1/4, "$K_4$: $i=1/4$"),
                    (1/5, "$K_5$: $i=1/5$")]:
        ax.plot(k, 1.0 / k, "o", ms=8, color="black")
        ax.annotate(name, (k, 1.0 / k), textcoords="offset points",
                    xytext=(8, 8), fontsize=9)

    ax.set_xlabel("independence ratio  $i(G) = \\alpha(G)/n$")
    ax.set_ylabel("forced lower bound on $\\chi_f(G)$")
    ax.set_title("The reciprocal map: small independence ratio forces many colours")
    ax.set_ylim(2, 8)
    ax.legend()
    fig.tight_layout()
    fig.savefig("independence_ratio_frontier.png", dpi=150)
    print("wrote independence_ratio_frontier.png")


if __name__ == "__main__":
    main()
