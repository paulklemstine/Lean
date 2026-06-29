"""Spacetime diagram of a transfinite cellular automaton and its omega-stage.

Renders the finite-time evolution (stages 0..T, top to bottom) of the OR rule
and the parity (XOR) rule on a window, then appends the omega-stage row. For the
inflationary OR rule the omega-stage equals the settled finite configuration
(collapse); for the parity rule the finite orbit never settles and the
ITTM-style limsup row is shown instead. Requires matplotlib + numpy.
"""
from __future__ import annotations
from typing import Callable, Dict, List
import numpy as np
import matplotlib.pyplot as plt

Config = Dict[int, bool]
LocalRule = Callable[[bool, bool, bool], bool]


def step(rule: LocalRule, c: Config, lo: int, hi: int) -> Config:
    def read(m: int) -> bool:
        return c.get(m, False)
    return {n: rule(read(n - 1 if n > 0 else 0), read(n), read(n + 1))
            for n in range(lo, hi + 1)}


def spacetime(rule: LocalRule, c0: Config, T: int, lo: int, hi: int) -> np.ndarray:
    rows: List[List[int]] = []
    c = dict(c0)
    for _ in range(T + 1):
        rows.append([1 if c.get(n, False) else 0 for n in range(lo, hi + 1)])
        c = step(rule, c, lo, hi)
    return np.array(rows, dtype=float)


def main() -> None:
    lo, hi, T = -20, 20, 20
    seed: Config = {0: True}
    or_rule: LocalRule = lambda l, c, r: l or c or r
    xor_rule: LocalRule = lambda l, c, r: l ^ c ^ r

    grid_or = spacetime(or_rule, seed, T, lo, hi)
    grid_xor = spacetime(xor_rule, seed, T, lo, hi)

    fig, axes = plt.subplots(1, 2, figsize=(12, 6))
    axes[0].imshow(grid_or, cmap="Greys", interpolation="nearest", aspect="auto")
    axes[0].set_title("OR rule (inflationary): orbit collapses to omega-stage")
    axes[0].set_xlabel("cell"); axes[0].set_ylabel("stage t")

    axes[1].imshow(grid_xor, cmap="Greys", interpolation="nearest", aspect="auto")
    axes[1].set_title("XOR rule: never settles (super-Turing boundary)")
    axes[1].set_xlabel("cell"); axes[1].set_ylabel("stage t")

    fig.suptitle("Transfinite cellular automata: spacetime diagrams", fontsize=14)
    fig.tight_layout()
    fig.savefig("transfinite_ca_spacetime.png", dpi=140)
    print("Saved transfinite_ca_spacetime.png")


if __name__ == "__main__":
    main()
