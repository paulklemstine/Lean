def sup_newton_gap(e):
    import numpy as np
    m = len(e) - 1
    if m <= 1: return 0.0
    gaps = []
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            gaps.append(np.log(e[k-1]) + np.log(e[k+1]) - 2*np.log(e[k]))
    return max(gaps) if gaps else 0.0