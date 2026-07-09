"""Visualize the conformal factor 4/(1+r^2)^2 and its Liouville residual."""
import numpy as np
import matplotlib.pyplot as plt

def conformal_factor(r2: np.ndarray) -> np.ndarray:
    return 4.0 / (1.0 + r2) ** 2

def main() -> None:
    lim, n = 3.0, 400
    xs = np.linspace(-lim, lim, n)
    X, Y = np.meshgrid(xs, xs)
    R2 = X ** 2 + Y ** 2
    Omega = conformal_factor(R2)

    U = np.log(2.0 / (1.0 + R2))
    h = xs[1] - xs[0]
    lap = (np.roll(U, 1, 0) + np.roll(U, -1, 0)
           + np.roll(U, 1, 1) + np.roll(U, -1, 1) - 4 * U) / h ** 2
    residual = lap + np.exp(2 * U)

    fig, ax = plt.subplots(1, 2, figsize=(12, 5))
    c0 = ax[0].contourf(X, Y, Omega, levels=40, cmap="viridis")
    ax[0].set_title(r"Conformal factor $4/(1+r^2)^2$")
    fig.colorbar(c0, ax=ax[0])
    c1 = ax[1].contourf(X[2:-2, 2:-2], Y[2:-2, 2:-2],
                        residual[2:-2, 2:-2], levels=40, cmap="coolwarm")
    ax[1].set_title(r"Liouville residual $\Delta u + e^{2u}$")
    fig.colorbar(c1, ax=ax[1])
    plt.tight_layout()
    plt.savefig("conformal_factor.png", dpi=150)

if __name__ == "__main__":
    main()
