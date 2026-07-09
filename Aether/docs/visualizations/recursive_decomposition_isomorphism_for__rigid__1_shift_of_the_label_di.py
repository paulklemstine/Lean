"""Visualization 3: Label distribution and its rigid +1 shift.

Bar chart of the label multiset at a chosen depth for the active-sites tree and
the shifted tree, showing the shifted distribution is the active-sites one
translated by exactly +1 (refined equinumerosity).
"""
from collections import Counter
from typing import Callable, List
import matplotlib.pyplot as plt

def sites_rule(m: int, k: int) -> List[int]:
    return list(range(1, m * k + 2))

def shifted_rule(m: int, k: int) -> List[int]:
    return list(range(2, (m * k - m + 1) + 2))

def level_labels(succ: Callable[[int], List[int]], root: int, depth: int) -> List[int]:
    labels = [root]
    for _ in range(depth):
        nxt: List[int] = []
        for lab in labels:
            nxt.extend(succ(lab))
        labels = nxt
    return labels

def main(m: int = 2, depth: int = 3) -> None:
    s = Counter(level_labels(lambda k: sites_rule(m, k), 1, depth))
    t = Counter(level_labels(lambda k: shifted_rule(m, k), 2, depth))
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.bar([k - 0.18 for k in s], [s[k] for k in s], width=0.36, label="active-sites")
    ax.bar([k + 0.18 for k in t], [t[k] for k in t], width=0.36, label="shifted")
    ax.set_xlabel("label value")
    ax.set_ylabel("multiplicity at depth %d" % depth)
    ax.set_title(f"Label distributions differ by a rigid +1 shift (m = {m})")
    ax.legend()
    plt.tight_layout()
    plt.savefig("labels.png", dpi=150)
    print("wrote labels.png")

if __name__ == "__main__":
    main()
