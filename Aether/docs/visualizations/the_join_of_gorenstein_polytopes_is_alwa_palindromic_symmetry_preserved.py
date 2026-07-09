"""Visualize that the join (convolution) of palindromic h*-vectors stays palindromic.

Generates a bar-chart comparison of two Gorenstein h*-vectors and their join,
highlighting the preserved left-right symmetry. Saves to gorenstein_join.png.
"""
from typing import List
import matplotlib.pyplot as plt


def join_hstar(p: List[int], q: List[int]) -> List[int]:
    r = [0] * (len(p) + len(q) - 1)
    for j, pj in enumerate(p):
        for k, qk in enumerate(q):
            r[j + k] += pj * qk
    return r


def main() -> None:
    p = [1, 4, 1]
    q = [1, 3, 3, 1]
    r = join_hstar(p, q)
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))
    for ax, vec, title in zip(
        axes,
        [p, q, r],
        [f"h*_P = {p}", f"h*_Q = {q}", f"h*_(P*Q) = {r}"],
    ):
        idx = list(range(len(vec)))
        ax.bar(idx, vec, color="#3b6ea5")
        ax.set_title(title + "\n(palindromic)")
        ax.set_xlabel("coefficient index i")
        ax.set_ylabel("h*_i")
        ax.set_xticks(idx)
    fig.suptitle("Join multiplies h*-polynomials and preserves palindromic symmetry",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("gorenstein_join.png", dpi=140)
    print("saved gorenstein_join.png")


if __name__ == "__main__":
    main()
