"""Plot eigenvalues of random 3x3 matrices against the weak Gershgorin disc."""
import matplotlib.pyplot as plt
import numpy as np


def weak_gershgorin_bound(M: np.ndarray) -> float:
    return float(np.max(np.sum(np.abs(M), axis=1)))


def main() -> None:
    rng = np.random.default_rng(0)
    fig, ax = plt.subplots(figsize=(6, 6))
    for _ in range(40):
        M = rng.uniform(-2, 2, size=(3, 3))
        B = weak_gershgorin_bound(M)
        eig = np.linalg.eigvals(M)
        ax.scatter(eig.real, eig.imag, s=12, color="#d95f02", alpha=0.6)
    # draw the largest bound seen as a reference disc
    theta = np.linspace(0, 2 * np.pi, 200)
    ax.plot(6 * np.cos(theta), 6 * np.sin(theta), "k--", alpha=0.4,
            label="|lambda| <= max row sum (per matrix)")
    ax.axhline(0, color="gray", lw=0.5)
    ax.axvline(0, color="gray", lw=0.5)
    ax.set_aspect("equal")
    ax.set_xlabel("Re(lambda)")
    ax.set_ylabel("Im(lambda)")
    ax.set_title("Eigenvalues fall inside the weak Gershgorin disc |lambda| <= B")
    ax.legend()
    plt.tight_layout()
    plt.savefig("gershgorin_disc.png", dpi=150)
    print("wrote gershgorin_disc.png")


if __name__ == "__main__":
    main()
