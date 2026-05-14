def tropical_ntk(W, b, S, x, y):
    import numpy as np
    def find_argmin(W, b, S, x):
        scores = [(np.dot(W[i], x) + b[i], i) for i in S]
        return min(scores, key=lambda t: t[0])[1]
    i0x = find_argmin(W, b, S, x)
    i0y = find_argmin(W, b, S, y)
    if i0x == i0y:
        return np.dot(x, y) + 1
    else:
        return 0.0