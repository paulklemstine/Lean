"""Visualization: game tree of the escalation game for small r.

Draws the move graph of positions 0..R for granularity m, with nodes colored by
misere outcome, illustrating that every N-position has an edge to a P-position
while P-positions only reach N-positions. Requires networkx and matplotlib."""
import matplotlib.pyplot as plt
import networkx as nx


def misere_p(m: int, r: int) -> bool:
    return r % (m + 1) == 1


def main():
    m, R = 2, 12
    G = nx.DiGraph()
    for r in range(R + 1):
        for s in range(1, min(m, r) + 1):
            G.add_edge(r, r - s)
    colors = ["#d62728" if misere_p(m, r) else "#2ca02c" for r in G.nodes()]
    pos = {r: (r, 0) for r in G.nodes()}
    plt.figure(figsize=(12, 3))
    nx.draw(G, pos, with_labels=True, node_color=colors, node_size=600,
            connectionstyle="arc3,rad=0.3", arrows=True)
    plt.title(f"Escalation move graph, m={m}: red = misere P-position (r ≡ 1 mod {m+1})")
    plt.savefig("escalation_tree.png", dpi=120, bbox_inches="tight")
    print("saved escalation_tree.png")


if __name__ == "__main__":
    main()
