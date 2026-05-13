def tropical_distance(phi, x, y):
    '''Compute tropical separation distance d_Φ(x, y) = max_i |Φ_i(x) - Φ_i(y)|.'''
    return max(abs(phi[i][x] - phi[i][y]) for i in range(len(phi)))

def tropical_distance_matrix(phi):
    '''Compute the full pairwise tropical distance matrix.'''
    n = len(phi[0])
    return [[tropical_distance(phi, x, y) for y in range(n)] for x in range(n)]

# Example
phi = [[1, 3, 2, 5, 4], [2, 2, 4, 1, 3], [0, 1, 1, 2, 0]]
D = tropical_distance_matrix(phi)
print("Distance matrix:")
for row in D:
    print(row)
