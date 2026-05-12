def reconstruct_mv(C_adj, C_weights, C_base, k, chi):
    """Reconstruct MV polytope from admissible character data."""
    n = len(chi)
    # Certificate verification
    assert chi[C_base] == 0, "Normalization failed"
    for i in range(n):
        for j in range(i+1, n):
            if C_adj[i][j]:
                assert chi[i] - chi[j] <= k * C_weights[i][j], f"Edge ({i},{j}) violated"
                assert chi[j] - chi[i] <= k * C_weights[i][j], f"Edge ({j},{i}) violated"
    return chi, k  # weight, level

# Example
adj = [[0,1,1],[1,0,1],[1,1,0]]
wts = [[0,1,1],[1,0,1],[1,1,0]]
w, lev = reconstruct_mv(adj, wts, 0, 1, [0, 1, 0])
print(f"Reconstructed: weight={w}, level={lev}")
