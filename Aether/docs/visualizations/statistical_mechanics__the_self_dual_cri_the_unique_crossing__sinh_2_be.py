import math
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    beta_c = 0.5 * math.log(1.0 + math.sqrt(2.0))
    betas = np.linspace(0.01, 1.0, 600)
    s = np.sinh(2.0 * betas)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(betas, s, lw=2, color="#1f3b73", label=r"$\sinh(2\beta)$")
    ax.axhline(1.0, ls="--", color="gray", label=r"$\sinh(2\beta)=1$")
    ax.axvline(beta_c, ls=":", color="#c0392b",
               label=rf"$\beta_c={beta_c:.4f}$")
    ax.scatter([beta_c], [1.0], color="#c0392b", zorder=5)
    ax.annotate("self-dual critical point", xy=(beta_c, 1.0),
                xytext=(beta_c + 0.08, 1.6),
                arrowprops=dict(arrowstyle="->", color="#c0392b"))
    ax.set_xlabel(r"inverse temperature $\beta$")
    ax.set_ylabel(r"$\sinh(2\beta)$")
    ax.set_title("2D Ising self-dual point: the unique root of "
                 r"$\sinh(2\beta)=1$")
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("ising_critical_point.png", dpi=150)
    print("saved ising_critical_point.png")


if __name__ == "__main__":
    main()
