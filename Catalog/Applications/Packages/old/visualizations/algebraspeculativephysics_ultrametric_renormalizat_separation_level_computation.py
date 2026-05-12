def compute_sep_level(rels, x, y, n_scales):
    """Compute separation level of x and y."""
    for i in range(n_scales):
        if rels[i][x][y]:
            return i
    return n_scales - 1

# Example: Binary merge tree
import numpy as np
R0 = np.eye(4, dtype=bool)
R1 = np.array([[1,1,0,0],[1,1,0,0],[0,0,1,1],[0,0,1,1]], dtype=bool)
R2 = np.ones((4,4), dtype=bool)
rels = [R0, R1, R2]

for x in range(4):
    for y in range(4):
        print(f"sep({x},{y}) = {compute_sep_level(rels, x, y, 3)}", end="  ")
    print()
