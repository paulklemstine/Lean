def compute_phi_sheaf(graph, sheaf):
    delta = assemble_coboundary(graph, sheaf)
    rank = np.linalg.matrix_rank(delta)
    return sheaf.dim_c1 - rank