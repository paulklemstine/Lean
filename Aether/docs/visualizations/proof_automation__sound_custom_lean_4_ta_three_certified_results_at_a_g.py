import matplotlib.pyplot as plt
import numpy as np

def main() -> None:
    """Visualize three certified results in one figure."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # (1) Exponential dominance n^2 < 2^n for n >= 5
    n = np.arange(0, 13)
    axes[0].plot(n, n ** 2, "o-", label="$n^2$")
    axes[0].plot(n, 2.0 ** n, "s-", label="$2^n$")
    axes[0].axvline(5, color="gray", ls="--", label="$n=5$ (base)")
    axes[0].set_title("two_pow_gt_sq: $n^2 < 2^n$ for $n\\geq 5$")
    axes[0].set_xlabel("n"); axes[0].legend(); axes[0].set_yscale("log")

    # (2) Fermat residue heat: f(x) mod m == 0 for all residues
    mods = [(5, lambda x: x**5 - x), (7, lambda x: x**7 - x), (6, lambda x: x**3 - x)]
    labels = ["$n^5-n$ mod 5", "$n^7-n$ mod 7", "$n^3-n$ mod 6"]
    for i, (m, f) in enumerate(mods):
        vals = [f(x) % m for x in range(m)]
        axes[1].bar(np.arange(m) + i * 0.0, vals, alpha=0.5, label=labels[i])
    axes[1].set_title("Residues all 0 -> divisibility certified")
    axes[1].set_xlabel("residue x"); axes[1].set_ylabel("f(x) mod m"); axes[1].legend()

    # (3) Gershgorin disc (weak, origin-centered) containing eigenvalues
    M = np.array([[5.0, -2.0], [-3.0, 1.0]])
    B = np.abs(M).sum(axis=1).max()
    theta = np.linspace(0, 2 * np.pi, 200)
    axes[2].plot(B * np.cos(theta), B * np.sin(theta), "b-", label=f"|z|=B={B:g}")
    eig = np.linalg.eigvals(M)
    axes[2].scatter(eig.real, eig.imag, color="red", zorder=5, label="eigenvalues")
    axes[2].set_aspect("equal"); axes[2].set_title("spectral_bound: $|\\lambda|\\leq B$")
    axes[2].legend(); axes[2].grid(True)

    plt.tight_layout()
    plt.savefig("tactics_visualization.png", dpi=150)
    print("saved tactics_visualization.png")

if __name__ == "__main__":
    main()
