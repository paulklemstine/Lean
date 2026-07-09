"""Visualize convergence of the finite-size free energy density to the limit.

Plots f_n = (1/(n+1)) log Z_n versus chain length n on a log scale and shows
its approach to the thermodynamic limit log(2 cosh(beta J)), demonstrating the
free_energy_density_limit theorem numerically.
"""
import math
import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    beta, J = 0.9, 1.0
    limit = math.log(2.0 * math.cosh(beta * J))
    ns = np.unique(np.round(np.logspace(0, 5, 40)).astype(int))
    # stable: log Z_n = log 2 + n log(2 cosh beta J)
    logz = math.log(2.0) + ns * math.log(2.0 * math.cosh(beta * J))
    fn = logz / (ns + 1)

    fig, ax = plt.subplots(1, 2, figsize=(11, 4.5))
    ax[0].semilogx(ns, fn, "o-", color="navy", label=r"$f_n$")
    ax[0].axhline(limit, color="crimson", ls="--", label="thermodynamic limit")
    ax[0].set_xlabel("chain length n"); ax[0].set_ylabel(r"$f_n$")
    ax[0].legend(); ax[0].grid(True, alpha=0.3)
    ax[1].loglog(ns, np.abs(fn - limit), "s-", color="darkgreen")
    ax[1].set_xlabel("chain length n"); ax[1].set_ylabel(r"$|f_n-f_\infty|$")
    ax[1].set_title("error decays like 1/n"); ax[1].grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("ising_convergence.png", dpi=150)
    print("saved ising_convergence.png")

if __name__ == "__main__":
    main()
