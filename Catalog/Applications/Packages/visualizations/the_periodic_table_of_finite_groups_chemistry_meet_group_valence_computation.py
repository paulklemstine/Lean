def valence(G):
    normals = find_normal_subgroups(G)
    minimal = [N for N in normals if not any(M < N for M in normals)]
    return len(minimal)