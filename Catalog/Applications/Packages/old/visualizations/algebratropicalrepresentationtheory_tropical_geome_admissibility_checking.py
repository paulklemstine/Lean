def check_admissible(C_adj, C_weights, C_base, k, chi):
    """Check if character chi is admissible at level k."""
    n = len(chi)
    if chi[C_base] != 0:
        return False
    for i in range(n):
        for j in range(i+1, n):
            if C_adj[i][j]:
                if chi[i] - chi[j] > k * C_weights[i][j]:
                    return False
                if chi[j] - chi[i] > k * C_weights[i][j]:
                    return False
    return True

# Example: A2 chamber complex
adj = [[0,1,1],[1,0,1],[1,1,0]]
wts = [[0,1,1],[1,0,1],[1,1,0]]
print(check_admissible(adj, wts, 0, 1, [0, 1, 0]))  # True
print(check_admissible(adj, wts, 0, 1, [0, 2, 0]))  # False
