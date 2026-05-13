def lens_transform(source, edge_cost):
    import numpy as np
    n = len(source)
    delay = np.full(n, np.inf)
    for o in range(n):
        for s in range(n):
            cost = source[s] + edge_cost[s, o]
            delay[o] = min(delay[o], cost)
    return delay.astype(int)

# Example
import numpy as np
source = np.array([7, 13, 3, 22])
M = 1000
cost = np.full((4, 4), M)
np.fill_diagonal(cost, 0)
print("Source:", source)
print("Delay:", lens_transform(source, cost))
