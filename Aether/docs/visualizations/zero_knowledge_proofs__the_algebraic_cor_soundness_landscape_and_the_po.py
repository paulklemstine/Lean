"""Visualize the Schnorr soundness landscape and the power automorphism.

Generates two panels:
  (left)  the acceptance indicator over all q challenges for a fixed pre-committed
          (A, s): exactly one challenge accepts -> soundness error 1/q.
  (right) the permutation induced by the power map x -> x^k on the subgroup,
          shown as a scatter of (index, image-index), a bijection for k != 0.
"""
from __future__ import annotations
import matplotlib.pyplot as plt


def gexp(x: int, e: int, p: int, q: int) -> int:
    return pow(x, e % q, p)


def main() -> None:
    p, q = 2027, 1013
    g = 4
    x_secret = 123
    y = gexp(g, x_secret, p, q)

    # Panel 1: acceptance over all challenges for a fixed cheating (A, s).
    a = gexp(g, 42, p, q)
    s = 99
    accept = [
        1 if gexp(g, s, p, q) == (a * gexp(y, c, p, q)) % p else 0
        for c in range(q)
    ]

    # Panel 2: power map permutation for k = 17.
    subgroup = sorted({gexp(g, e, p, q) for e in range(q)})
    index = {v: i for i, v in enumerate(subgroup)}
    k = 17
    xs = list(range(q))
    ys = [index[gexp(subgroup[i], k, p, q)] for i in range(q)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.bar(range(q), accept, width=1.0, color="crimson")
    ax1.set_title(f"Accepting challenges for fixed (A,s): exactly 1 of q={q}")
    ax1.set_xlabel("challenge c"); ax1.set_ylabel("accept?")

    ax2.scatter(xs, ys, s=2, color="navy")
    ax2.set_title(f"Power map x -> x^{k} is a bijection of the subgroup")
    ax2.set_xlabel("element index"); ax2.set_ylabel("image index")

    fig.tight_layout()
    fig.savefig("schnorr_visualization.png", dpi=130)
    print("wrote schnorr_visualization.png")


if __name__ == "__main__":
    main()
