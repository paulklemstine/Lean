import numpy as np
import itertools
from typing import Optional, Tuple
from collections import Counter

def tropical_univalence_decide(D, E):
    n = D.shape[0]
    if E.shape[0] != n: return False, "Different dimensions"
    # Invariant check
    d_dists = sorted(D[i,j] for i in range(n) for j in range(i+1,n))
    e_dists = sorted(E[i,j] for i in range(n) for j in range(i+1,n))
    if d_dists != e_dists: return False, "Distance multisets differ"
    # Permutation search
    for perm in itertools.permutations(range(n)):
        if all(E[perm[i],perm[j]] == D[i,j] for i in range(n) for j in range(n)):
            return True, f"Equivalent via sigma={perm}"
    return False, "No witness found"

# Examples
D1 = np.array([[0,1,2],[1,0,1],[2,1,0]])
D2 = np.array([[0,1,1],[1,0,2],[1,2,0]])
D3 = np.array([[0,1,1],[1,0,1],[1,1,0]])
print(tropical_univalence_decide(D1, D2))
print(tropical_univalence_decide(D1, D3))