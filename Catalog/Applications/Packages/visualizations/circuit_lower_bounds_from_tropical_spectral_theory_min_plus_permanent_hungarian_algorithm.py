import numpy as np
from itertools import permutations

def min_plus_permanent_exact(M):
    n = M.shape[0]
    best_cost = float('inf')
    best_perm = None
    for perm in permutations(range(n)):
        cost = sum(int(M[i, perm[i]]) for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    return int(best_cost), best_perm

# Example
M = np.array([[5,2,8],[3,7,1],[6,4,9]])
cost, perm = min_plus_permanent_exact(M)
print(f"Min-plus permanent: {cost}, Optimal permutation: {perm}")
