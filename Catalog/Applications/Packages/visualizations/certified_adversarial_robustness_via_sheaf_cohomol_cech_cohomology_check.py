def cech_cohomology_vanishes(cocycle):
    n = cocycle.shape[0]
    import numpy as np
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if not np.isclose(cocycle[i,k], cocycle[i,j] + cocycle[j,k]):
                    return False, None
    potential = cocycle[0, :]
    return True, potential