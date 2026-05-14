def min_plus_mat_vec(M, v):
    """Min-plus matrix-vector product: (M x v)[i] = min_j(M[i][j] + v[j])."""
    return [min(M[i][j] + v[j] for j in range(len(v))) for i in range(len(M))]

# Example
M = [[0, 3, 5], [2, 0, 4], [1, 2, 0]]
v = [1, 2, 3]
print(min_plus_mat_vec(M, v))  # [1, 2, 2]