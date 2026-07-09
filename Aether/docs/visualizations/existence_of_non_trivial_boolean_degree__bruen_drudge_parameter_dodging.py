"""
Visualization: the Bruen-Drudge parameter x = (q^2+1)/2 dodging the trivial band.

For each odd q >= 3 we plot the six trivial parameter values {0,1,2,q^2-1,q^2,q^2+1}
as a forbidden band, and the Bruen-Drudge parameter x = (q^2+1)/2 sitting strictly
in the middle gap 2 < x < q^2-1. The half-and-half (self-complementary) line
shows x at exactly the midpoint of the full parameter range [0, q^2+1].
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def x_param(q: int) -> int:
    return (q * q + 1) // 2


def main() -> None:
    qs: List[int] = [3, 5, 7, 9, 11, 13]
    fig, ax = plt.subplots(figsize=(9, 5))

    for i, q in enumerate(qs):
        q2 = q * q
        # full admissible parameter range
        ax.plot([0, q2 + 1], [i, i], color="0.8", lw=2, zorder=1)
        # trivial (forbidden) values
        triv = [0, 1, 2, q2 - 1, q2, q2 + 1]
        ax.scatter(triv, [i] * len(triv), color="crimson", s=60,
                   zorder=3, label="trivial params" if i == 0 else None)
        # Bruen-Drudge non-trivial parameter
        x = x_param(q)
        ax.scatter([x], [i], color="royalblue", s=130, marker="*",
                   zorder=4, label="x = (q^2+1)/2" if i == 0 else None)
        ax.annotate(f"q={q}, x={x}", (x, i), textcoords="offset points",
                    xytext=(0, 10), ha="center", fontsize=9)

    ax.set_yticks(range(len(qs)))
    ax.set_yticklabels([f"q={q}" for q in qs])
    ax.set_xlabel("Cameron-Liebler parameter value")
    ax.set_title("Bruen-Drudge parameter x = (q^2+1)/2 lands in the non-trivial gap "
                 "2 < x < q^2-1")
    ax.legend(loc="lower right")
    fig.tight_layout()
    fig.savefig("bruen_drudge_parameter.png", dpi=150)
    print("Saved bruen_drudge_parameter.png")


if __name__ == "__main__":
    main()
