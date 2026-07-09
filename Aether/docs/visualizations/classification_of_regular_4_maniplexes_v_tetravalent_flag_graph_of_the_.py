"""Draw the 4-cube flag graph Q_4 (a tetravalent flag graph) with matplotlib."""
from itertools import product
import matplotlib.pyplot as plt
import networkx as nx


def hypercube_flag_graph(dim: int) -> nx.Graph:
    G = nx.Graph()
    verts = list(product((0, 1), repeat=dim))
    G.add_nodes_from(verts)
    for v in verts:
        for i in range(dim):
            w = list(v); w[i] ^= 1
            G.add_edge(v, tuple(w), color=i)
    return G


if __name__ == "__main__":
    G = hypercube_flag_graph(4)
    colors = ["#e6194B", "#3cb44b", "#4363d8", "#f58231"]
    edge_colors = [colors[G[u][v]["color"]] for u, v in G.edges()]
    pos = nx.spring_layout(G, seed=7)
    nx.draw(G, pos, node_size=120, node_color="#222", edge_color=edge_colors, width=2)
    plt.title("Flag graph Q_4: 16 flags, every vertex 4-valent (tetravalent)")
    plt.savefig("hypercube_flag_graph.png", dpi=150, bbox_inches="tight")
    print("degrees:", sorted(set(dict(G.degree()).values())))
