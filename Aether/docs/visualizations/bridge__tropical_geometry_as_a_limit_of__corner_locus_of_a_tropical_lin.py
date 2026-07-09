"""Visualize the corner locus of the tropical line trop(x+y+1) in the plane:
three rays emanating from the origin, the simplest tropical hypersurface."""
import matplotlib.pyplot as plt
import numpy as np


def plot_tropical_line() -> None:
    n = 400
    w1 = np.linspace(-4, 4, n)
    w2 = np.linspace(-4, 4, n)
    W1, W2 = np.meshgrid(w1, w2)
    # terms: w1, w2, 0  -> count minimizers (within tol) per pixel
    terms = np.stack([W1, W2, np.zeros_like(W1)], axis=0)
    M = terms.min(axis=0)
    ties = (np.abs(terms - M) < 0.04).sum(axis=0)
    plt.contourf(W1, W2, (ties >= 2).astype(float), levels=[0.5, 1.5],
                 colors=["crimson"])
    plt.title("Corner locus of trop(x+y+1): a tropical line")
    plt.xlabel("w1"); plt.ylabel("w2"); plt.gca().set_aspect("equal")
    plt.tight_layout(); plt.savefig("tropical_line.png", dpi=150)
    print("saved tropical_line.png")


if __name__ == "__main__":
    plot_tropical_line()
