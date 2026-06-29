"""Visualize a contagion cascade: infection wavefront over saturation rounds.

Generates a figure showing, for a small social network with synergy rules, the
set of infected agents after each synchronous round of the one-step operator.
Requires matplotlib and networkx.
"""
from __future__ import annotations
from typing import FrozenSet, List, Set, Tuple
import matplotlib.pyplot as plt
import networkx as nx

Agent = int
Rule = Tuple[FrozenSet[Agent], Agent]


def step_op(rules: List[Rule], current: Set[Agent]) -> Set[Agent]:
    return {c for (p, c) in rules if p <= current}


def cascade_rounds(rules: List[Rule], seeds: Set[Agent]) -> List[Set[Agent]]:
    rounds = [set(seeds)]
    cur = set(seeds)
    while True:
        nxt = cur | step_op(rules, cur)
        if nxt == cur:
            return rounds
        rounds.append(nxt)
        cur = nxt


def main() -> None:
    n = 12
    # ring of pairwise rules + a few synergy rules
    rules: List[Rule] = [(frozenset({k}), (k + 1) % n) for k in range(n)]
    rules += [(frozenset({2, 5}), 9), (frozenset({9, 7}), 11)]
    seeds = {0}
    rounds = cascade_rounds(rules, seeds)

    G = nx.DiGraph()
    for p, c in rules:
        for x in p:
            G.add_edge(x, c)
    pos = nx.circular_layout(G)

    fig, axes = plt.subplots(1, len(rounds), figsize=(3 * len(rounds), 3))
    if len(rounds) == 1:
        axes = [axes]
    for ax, infected in zip(axes, rounds):
        colors = ["#e63946" if v in infected else "#a8dadc" for v in G.nodes()]
        nx.draw(G, pos, ax=ax, node_color=colors, with_labels=True,
                node_size=350, font_size=8, arrowsize=8)
        ax.set_title(f"|infected| = {len(infected)}")
    fig.suptitle("Contagion cascade (red = infected) per saturation round")
    fig.tight_layout()
    fig.savefig("cascade.png", dpi=140)
    print("wrote cascade.png")


if __name__ == "__main__":
    main()
