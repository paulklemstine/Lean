
import numpy as np
from itertools import combinations

def canonical_tropical_reconstruction(num_participants, blocking_sets):
    """Canonical reconstruction algorithm.
    Input: number of participants, list of blocking sets (sets of ints)
    Output: (matrix, threshold) as numpy arrays
    """
    d = len(blocking_sets)
    matrix = np.zeros((num_participants, d), dtype=int)
    for j, block in enumerate(blocking_sets):
        for p in block:
            matrix[p, j] = 1
    threshold = np.ones(d, dtype=int)
    return matrix, threshold

def is_authorized(matrix, threshold, coalition):
    """Check authorization: score >= threshold in all dims."""
    if not coalition:
        return False
    score = matrix[list(coalition)].max(axis=0)
    return all(score[j] >= threshold[j] for j in range(len(threshold)))

def extract_minimal(matrix, threshold, coalition):
    """Extract minimal authorized subset via greedy removal."""
    D = set(coalition)
    for p in list(coalition):
        if p in D and is_authorized(matrix, threshold, D - {p}):
            D.remove(p)
    return D

def find_all_minimal_authorized(matrix, threshold, n):
    """Find all minimal authorized coalitions."""
    result = []
    for size in range(1, n + 1):
        for combo in combinations(range(n), size):
            coal = set(combo)
            if is_authorized(matrix, threshold, coal):
                is_min = all(not is_authorized(matrix, threshold, coal - {p}) for p in coal)
                if is_min:
                    result.append(coal)
    return result

# Example: (2,3)-threshold scheme
matrix = np.array([[0,1,1],[1,0,1],[1,1,0]])
threshold = np.array([1,1,1])
print("(2,3)-Threshold Scheme")
print("Matrix:", matrix.tolist())
print("Minimal authorized:", find_all_minimal_authorized(matrix, threshold, 3))

# Example: Blocker reconstruction
M, T = canonical_tropical_reconstruction(4, [{0,1}, {2,3}])
print("
Blocker {0,1},{2,3} reconstruction:")
print("Matrix:", M.tolist())
print("Minimal authorized:", find_all_minimal_authorized(M, T, 4))
