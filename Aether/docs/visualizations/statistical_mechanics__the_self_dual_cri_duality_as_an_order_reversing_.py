import math
import numpy as np
import matplotlib.pyplot as plt


def dual_beta(beta):
    return 0.5 * np.arcsinh(1.0 / np.sinh(2.0 * beta))


def main() -> None:
    beta_c = 0.5 * math.log(1.0 + math.sqrt(2.0))
    betas = np.linspace(0.05, 1.2, 500)
    duals = dual_beta(betas)

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.plot(betas, duals, lw=2, color="#1f3b73",
            label=r"$\beta^\ast(\beta)$ (Kramers-Wannier dual)")
    ax.plot(betas, betas, ls="--", color="gray", label=r"$\beta^\ast=\beta$")
    ax.scatter([beta_c], [beta_c], color="#c0392b", zorder=5,
               label=rf"fixed point $\beta_c={beta_c:.4f}$")
    ax.set_xlabel(r"$\beta$")
    ax.set_ylabel(r"$\beta^\ast$")
    ax.set_title("Duality is an order-reversing involution; "
                 r"its only fixed point is $\beta_c$")
    ax.set_aspect("equal")
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("ising_duality_involution.png", dpi=150)
    print("saved ising_duality_involution.png")


if __name__ == "__main__":
    main()
