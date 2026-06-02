def count_colorings(g, k):
    edges = g.edges()
    if not edges:
        return k ** g.n
    u, v = edges[0]
    return count_colorings(g.delete_edge(u, v), k) - count_colorings(g.contract_edge(u, v), k)