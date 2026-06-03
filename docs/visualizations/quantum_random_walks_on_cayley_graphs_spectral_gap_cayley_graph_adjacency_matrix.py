def cayley_adjacency_matrix(group_elements, generators, group_op, group_inv):
    n = len(group_elements)
    elem_to_idx = {str(g): i for i, g in enumerate(group_elements)}
    A = [[0]*n for _ in range(n)]
    for i, g in enumerate(group_elements):
        for s in generators:
            h = group_op(g, s)
            j = elem_to_idx[str(h)]
            A[i][j] = 1
    return A