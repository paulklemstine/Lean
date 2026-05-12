def build_clustering(rels, size, n_scales):
    """Build hierarchical clustering from equivalence relations."""
    clustering = []
    for i in range(n_scales):
        level = {}
        for x in range(size):
            level[x] = frozenset(y for y in range(size) if rels[i][x][y])
        clustering.append(level)
    return clustering

# Example
import numpy as np
R0 = np.eye(4, dtype=bool)
R1 = np.array([[1,1,0,0],[1,1,0,0],[0,0,1,1],[0,0,1,1]], dtype=bool)
R2 = np.ones((4,4), dtype=bool)
rels = [R0, R1, R2]
clustering = build_clustering(rels, 4, 3)
for i, level in enumerate(clustering):
    classes = set(level.values())
    print(f"Scale {i}: {[sorted(c) for c in classes]}")
