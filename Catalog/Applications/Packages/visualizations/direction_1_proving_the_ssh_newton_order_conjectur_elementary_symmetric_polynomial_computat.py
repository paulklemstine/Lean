def esymm_stable(eigenvalues):
    import numpy as np
    m = len(eigenvalues)
    e = np.zeros(m + 1); e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e