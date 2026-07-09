"""Visualization: resolvent symmetry heatmap + transfer-product collapse.

Generates two panels:
  (left)  heatmaps of (I-A)^-1 and its row-exchange conjugate S(I-A)^-1 S,
          showing they coincide for a swap-symmetric 5x5 contraction;
  (right) the accumulated half-strip product norm ||P_m|| vs its certified
          geometric envelope ||P_N|| * c^(m-N) under eventual contraction.

Requires numpy and matplotlib.
"""
import numpy as np
import matplotlib.pyplot as plt


def swap_symmetric_operator(i: int = 1, j: int = 3) -> np.ndarray:
    raw = np.array([
        [0.30, 0.10, 0.05, 0.10, 0.04],
        [0.08, 0.22, 0.06, 0.12, 0.05],
        [0.05, 0.07, 0.28, 0.07, 0.06],
        [0.08, 0.12, 0.06, 0.22, 0.05],
        [0.04, 0.06, 0.05, 0.06, 0.30],
    ])
    perm = np.arange(5); perm[i], perm[j] = perm[j], perm[i]
    a = 0.5 * (raw + raw[np.ix_(perm, perm)])
    a *= 0.6 / np.abs(a).sum(axis=1).max()
    return a, perm


def main() -> None:
    a, perm = swap_symmetric_operator()
    S = np.eye(5)[perm]
    res = np.linalg.inv(np.eye(5) - a)
    conj = S @ res @ S

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.2))
    for ax, M, title in ((axes[0], res, "(I-A)^-1"),
                         (axes[1], conj, "S (I-A)^-1 S")):
        im = ax.imshow(M, cmap="viridis"); ax.set_title(title)
        fig.colorbar(im, ax=ax, fraction=0.046)

    # Eventual contraction collapse.
    c, N = 0.6, 3
    big = a * (2.0 / np.abs(a).sum(axis=1).max())
    P = np.eye(5); norms = []
    for m in range(16):
        norms.append(np.abs(P).sum(axis=1).max())
        Mk = big if m < N else a
        P = Mk @ P
    norms = np.array(norms)
    ms = np.arange(16)
    axes[2].semilogy(ms, norms, "o-", label="||P_m||")
    env = norms[N] * c ** (ms[N:] - N)
    axes[2].semilogy(ms[N:], env, "--", label="certificate ||P_N|| c^(m-N)")
    axes[2].axvline(N, color="gray", ls=":"); axes[2].set_xlabel("rows m")
    axes[2].set_title("transfer-product collapse"); axes[2].legend()

    fig.tight_layout()
    fig.savefig("five_vertex_row_exchange.png", dpi=140)
    print("saved five_vertex_row_exchange.png")


if __name__ == "__main__":
    main()
