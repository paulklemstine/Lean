import numpy as np
from typing import List, Dict

def compute_zero_distance_classes(D: np.ndarray) -> List[List[int]]:
    n = D.shape[0]
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i+1, n):
            if D[i,j] == 0: union(i, j)
    classes: Dict[int, List[int]] = {}
    for i in range(n):
        r = find(i)
        classes.setdefault(r, []).append(i)
    return list(classes.values())

# Example
D = np.array([[0,0,3,3],[0,0,3,3],[3,3,0,0],[3,3,0,0]])
print(compute_zero_distance_classes(D))  # [[0,1],[2,3]]