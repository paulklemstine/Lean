"""Visualization: equivalence <=> contractible fibers (a bar chart of fiber sizes).

A function is an equivalence exactly when every fiber has size 1. This script
draws fiber-size histograms for a bijection (all bars at height 1) and for a
non-injective collapse map (uneven bars), making the criterion visible.
Run: python viz_fibers.py  (writes fibers.png)
"""
from typing import Callable, Dict, List

import matplotlib.pyplot as plt


def fiber_sizes(f: Callable[[int], str], domain: List[int], codomain: List[str]) -> Dict[str, int]:
    return {b: sum(1 for a in domain if f(a) == b) for b in codomain}


def main() -> None:
    domain = [0, 1, 2, 3]
    codomain = ["a", "b", "c", "d"]
    bijection: Callable[[int], str] = lambda n: codomain[n]
    collapse: Callable[[int], str] = lambda n: codomain[min(n, 1)]

    fig, axes = plt.subplots(1, 2, figsize=(10, 4), sharey=True)
    for ax, (title, f) in zip(axes, [("bijection (equivalence)", bijection),
                                     ("collapse (not equivalence)", collapse)]):
        sizes = fiber_sizes(f, domain, codomain)
        ax.bar(list(sizes.keys()), list(sizes.values()), color="#4C72B0")
        ax.axhline(1.0, color="crimson", linestyle="--", label="contractible (=1)")
        ax.set_title(title)
        ax.set_xlabel("codomain point b")
        ax.set_ylabel("|fiber f^-1(b)|")
        ax.legend()
    fig.suptitle("Equivalence  <=>  every fiber contractible (size 1)")
    fig.tight_layout()
    fig.savefig("fibers.png", dpi=120)
    print("wrote fibers.png")


if __name__ == "__main__":
    main()
