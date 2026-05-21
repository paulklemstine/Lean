import networkx as nx

def compute_all_cycle_pressures(G: nx.Graph) -> dict:
    """Compute local cycle pressure for every vertex in O(|V|+|E|)."""
    bridges = set(nx.bridges(G))
    pressures = {}
    for v in G.nodes():
        p = sum(1 for u in G.neighbors(v)
                if (v, u) not in bridges and (u, v) not in bridges)
        pressures[v] = p
    return pressures

# Examples
for name, G in [("Path P5", nx.path_graph(5)),
                ("Cycle C5", nx.cycle_graph(5)),
                ("Complete K4", nx.complete_graph(4))]:
    print(f"{name}: {compute_all_cycle_pressures(G)}")
