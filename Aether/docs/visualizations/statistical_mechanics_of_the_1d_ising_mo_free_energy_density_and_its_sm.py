"""Plot the 1D Ising bulk free energy density and its smoothness.

Generates a figure showing f(beta) = log(2 cosh(beta J)) together with its
first and second derivatives, illustrating that the curve is smooth (no kink,
no divergence) at every temperature -- the visual signature of "no phase
transition" in one dimension.
"""
import math
import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    J = 1.0
    beta = np.linspace(0.01, 4.0, 800)
    f = np.log(2.0 * np.cosh(beta * J))            # free energy density
    u = -J * np.tanh(beta * J)                     # -df/dbeta = energy per site
    c = (J ** 2) / np.cosh(beta * J) ** 2          # d2f/dbeta2 (heat-capacity-like)

    fig, ax = plt.subplots(3, 1, figsize=(7, 9), sharex=True)
    ax[0].plot(beta, f, color="navy")
    ax[0].set_ylabel(r"$f(\beta)=\log(2\cosh\beta J)$")
    ax[0].set_title("1D Ising free energy density is smooth everywhere")
    ax[1].plot(beta, u, color="darkgreen")
    ax[1].set_ylabel(r"$u(\beta)=-J\tanh\beta J$")
    ax[2].plot(beta, c, color="crimson")
    ax[2].set_ylabel(r"$f''(\beta)$ (Schottky peak)")
    ax[2].set_xlabel(r"inverse temperature $\beta$")
    for a in ax:
        a.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("ising_free_energy.png", dpi=150)
    print("saved ising_free_energy.png")

if __name__ == "__main__":
    main()
