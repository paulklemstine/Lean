def compute_phi(vertices, edges):
    c = num_components(vertices, edges)  # BFS
    return len(edges) - len(vertices) + c