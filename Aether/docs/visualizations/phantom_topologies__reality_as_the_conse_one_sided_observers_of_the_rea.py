"""Visualization 1: the two one-sided observers and their consensus on R.

Draws [0,1), (0,1], and (0,1) and marks which observer sees each as open,
illustrating that only the two-sided interval survives the consensus.
"""
from __future__ import annotations

import matplotlib.pyplot as plt


def endpoint_openness(left_closed: bool, right_closed: bool) -> tuple[bool, bool, bool]:
    lower = not right_closed          # Sorgenfrey: right endpoint open
    upper = not left_closed           # upper-limit: left endpoint open
    euclid = (not left_closed) and (not right_closed)
    return lower, upper, euclid


def main() -> None:
    intervals = [
        ("(0,1)", False, False),
        ("[0,1)", True, False),
        ("(0,1]", False, True),
        ("[0,1]", True, True),
    ]
    fig, ax = plt.subplots(figsize=(9, 4))
    for row, (label, lc, rc) in enumerate(intervals):
        y = len(intervals) - row
        ax.hlines(y, 0, 1, color="steelblue", lw=6, alpha=0.7)
        ax.plot(0, y, "o", ms=12, mfc=("steelblue" if lc else "white"),
                mec="steelblue", mew=2)
        ax.plot(1, y, "o", ms=12, mfc=("steelblue" if rc else "white"),
                mec="steelblue", mew=2)
        lo, up, eu = endpoint_openness(lc, rc)
        tag = f"{label}   lower={lo}  upper={up}  consensus/Euclid={eu}"
        ax.text(1.15, y, tag, va="center", fontsize=11, family="monospace")
    ax.set_ylim(0.5, len(intervals) + 0.5)
    ax.set_xlim(-0.1, 3.2)
    ax.set_yticks([])
    ax.set_xticks([0, 1])
    ax.set_title("One-sided observers on R: only two-sided intervals survive consensus")
    plt.tight_layout()
    plt.savefig("phantom_realline.png", dpi=150)
    print("saved phantom_realline.png")


if __name__ == "__main__":
    main()
