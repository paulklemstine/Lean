def myhill_nerode_quotient(edge_cost):
    import numpy as np
    n = len(edge_cost)
    classes = {}
    for i in range(n):
        profile = tuple(edge_cost[i])
        if profile not in classes:
            classes[profile] = []
        classes[profile].append(i)
    return classes

# Example
import numpy as np
edge_cost = np.array([
    [0, 1, 2, 3, 1, 2],
    [1, 0, 1, 2, 0, 1],
    [2, 1, 0, 1, 1, 0],
    [3, 2, 1, 0, 2, 1],
    [1, 0, 1, 2, 0, 1],
    [2, 1, 0, 1, 1, 0],
])
classes = myhill_nerode_quotient(edge_cost)
for k, (profile, nodes) in enumerate(classes.items()):
    print(f"Class {k}: nodes {nodes}")
print(f"|Quotient| = {len(classes)} <= |Node| = {len(edge_cost)}")
