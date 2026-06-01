def reconstruct_degree_sequence(deck, n):
    total_edges = reconstruct_edge_count(deck, n)
    return sorted([total_edges - c.edge_count() for c in deck], reverse=True)