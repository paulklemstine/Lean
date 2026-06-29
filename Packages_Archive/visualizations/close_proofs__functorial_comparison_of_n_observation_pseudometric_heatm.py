"""Visualize the observation pseudometric and behavioral quotient.

Generates two panels:
  (left)  the 16x16 observation-distance matrix (0 = indistinguishable, 1 = separable),
  (right) the block structure after Myhill-Nerode collapse.
Requires matplotlib + numpy."""
from itertools import product
from typing import Dict, List, Optional, Sequence, Tuple

import numpy as np
import matplotlib.pyplot as plt

Vec = Tuple[int, ...]
Wiring = Tuple[Optional[int], ...]


def apply_wiring(w: Wiring, x: Vec) -> Vec:
    return tuple(0 if s is None else x[s] for s in w)


STEPS: Dict[str, Wiring] = {"a": (1, 0, 0, 1), "b": (0, 1, 1, 0)}
OBSERVE: Wiring = (0,)
N_BITS = 4


def step(x: Vec, a: str) -> Vec:
    return apply_wiring(STEPS[a], x)


def behavior(x: Vec, word: Sequence[str]) -> Vec:
    s = x
    for a in word:
        s = step(s, a)
    return apply_wiring(OBSERVE, s)


def words_upto(k: int) -> List[Tuple[str, ...]]:
    out: List[Tuple[str, ...]] = [()]
    for L in range(1, k + 1):
        out.extend(product("ab", repeat=L))
    return out


def main() -> None:
    states: List[Vec] = [tuple(b) for b in product((0, 1), repeat=N_BITS)]
    words = words_upto(N_BITS + 2)
    sigs = {x: tuple(behavior(x, w) for w in words) for x in states}
    n = len(states)
    D = np.zeros((n, n))
    for i, x in enumerate(states):
        for j, y in enumerate(states):
            D[i, j] = 0 if sigs[x] == sigs[y] else 1

    labels = ["".join(map(str, s)) for s in states]
    fig, axes = plt.subplots(1, 2, figsize=(13, 6))
    axes[0].imshow(D, cmap="viridis")
    axes[0].set_title("Observation pseudometric obsDist(x, y)")
    axes[0].set_xticks(range(n)); axes[0].set_xticklabels(labels, rotation=90, fontsize=6)
    axes[0].set_yticks(range(n)); axes[0].set_yticklabels(labels, fontsize=6)

    # quotient blocks
    order = sorted(range(n), key=lambda i: sigs[states[i]])
    Dq = D[np.ix_(order, order)]
    axes[1].imshow(Dq, cmap="magma")
    axes[1].set_title("After Myhill-Nerode reordering: behavior blocks")
    axes[1].set_xticks([]); axes[1].set_yticks([])
    plt.tight_layout()
    plt.savefig("obsdist_quotient.png", dpi=150)
    print("wrote obsdist_quotient.png")


if __name__ == "__main__":
    main()
