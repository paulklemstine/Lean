"""Bar chart of the rank-valence principle: rank n hypercube family is n-regular."""
from itertools import product
import matplotlib.pyplot as plt


def hypercube_degrees(dim: int):
    verts = list(product((0, 1), repeat=dim))
    nb = {v: set() for v in verts}
    for v in verts:
        for i in range(dim):
            w = list(v); w[i] ^= 1; w = tuple(w)
            nb[v].add(w); nb[w].add(v)
    return [len(s) for s in nb.values()]


if __name__ == "__main__":
    ranks = list(range(1, 8))
    valence = [hypercube_degrees(r)[0] for r in ranks]
    plt.bar(ranks, valence, color="#4363d8")
    plt.plot(ranks, ranks, "o--", color="#e6194B", label="predicted degree = rank")
    plt.xlabel("rank n (number of connection involutions)")
    plt.ylabel("flag-graph valence")
    plt.title("Rank-valence principle: flag graph of a rank-n maniplex is n-regular")
    plt.legend()
    plt.savefig("rank_valence.png", dpi=150, bbox_inches="tight")
