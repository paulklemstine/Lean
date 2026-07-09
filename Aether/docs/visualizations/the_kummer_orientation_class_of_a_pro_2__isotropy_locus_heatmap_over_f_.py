import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def self_cup(M, x):
    n = len(M)
    t = 0
    for i in range(n):
        for j in range(n):
            t ^= (x[i] & M[i][j] & x[j])
    return t & 1


def plot_locus(M, title, ax):
    n = len(M)
    vecs = [list(b) for b in product((0, 1), repeat=n)]
    vals = np.array([self_cup(M, x) for x in vecs]).reshape(1, -1)
    ax.imshow(vals, aspect="auto", cmap="coolwarm", vmin=0, vmax=1)
    ax.set_title(title)
    ax.set_yticks([])
    ax.set_xticks(range(len(vecs)))
    ax.set_xticklabels(["".join(map(str, v)) for v in vecs], rotation=90, fontsize=6)


if __name__ == "__main__":
    dot = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    hyp = [[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0]]
    fig, axs = plt.subplots(2, 1, figsize=(10, 4))
    plot_locus(dot, "dot product F_2^3 (odd: half isotropic)", axs[0])
    plot_locus(hyp, "hyperbolic^2 F_2^4 (even: all isotropic)", axs[1])
    plt.tight_layout()
    plt.savefig("isotropy_locus.png", dpi=150)
    print("saved isotropy_locus.png")
