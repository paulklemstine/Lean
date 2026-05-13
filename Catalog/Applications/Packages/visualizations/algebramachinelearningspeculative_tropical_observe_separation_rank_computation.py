from itertools import combinations

def subfamily_separates(phi, J):
    '''Check if subfamily J separates all states.'''
    n = len(phi[0])
    phi_J = [phi[j] for j in J]
    for x in range(n):
        for y in range(x + 1, n):
            if all(phi_J[k][x] == phi_J[k][y] for k in range(len(J))):
                return False
    return True

def compute_separation_rank(phi):
    '''Compute the separation rank and a minimal separating subfamily.'''
    num_obs = len(phi)
    for k in range(1, num_obs + 1):
        for J in combinations(range(num_obs), k):
            if subfamily_separates(phi, list(J)):
                return k, list(J)
    return num_obs, list(range(num_obs))

# Example
phi = [
    [0, 0, 1, 1],  # Observer 0
    [0, 1, 0, 1],  # Observer 1
    [0, 0, 1, 1],  # Observer 2 (duplicate)
    [0, 1, 0, 1],  # Observer 3 (duplicate)
]
rank, J = compute_separation_rank(phi)
print(f"Separation rank: {rank}, minimal subfamily: {J}")
