"""Draw the flag graph of an n-gon: a 2n-cycle with two perfect matchings."""
import matplotlib.pyplot as plt
import networkx as nx


def polygon_flag_graph(n: int) -> nx.Graph:
    m = 2 * n
    G = nx.Graph()
    for k in range(m):
        s0 = k + 1 if k % 2 == 0 else k - 1          # sigma_0 pairs (0,1),(2,3),...
        s1 = (k + 1) % m if k % 2 == 1 else (k - 1) % m  # sigma_1 pairs (1,2),(3,4),...
        G.add_edge(k, s0, color=0)
        G.add_edge(k, s1, color=1)
    return G


if __name__ == "__main__":
    n = 6
    G = polygon_flag_graph(n)
    pos = nx.circular_layout(G)
    ec = ["#e6194B" if G[u][v]["color"] == 0 else "#4363d8" for u, v in G.edges()]
    nx.draw(G, pos, node_size=160, node_color="#222", edge_color=ec, width=3, with_labels=True,
            font_color="white")
    plt.title(f"Flag graph of the {n}-gon: {2*n}-cycle, 2-valent, two matchings")
    plt.savefig("polygon_flag_graph.png", dpi=150, bbox_inches="tight")
