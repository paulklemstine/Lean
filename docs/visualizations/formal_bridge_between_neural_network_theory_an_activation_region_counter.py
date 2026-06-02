def count_regions(W, b, points):
    import numpy as np
    sigs = set()
    for x in points:
        pre = W @ np.array(x) + b
        sigs.add(tuple(p > 0 for p in pre))
    return len(sigs)