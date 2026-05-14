def find_argmin(W, b, S, x):
    import numpy as np
    scores = [(np.dot(W[i], x) + b[i], i) for i in S]
    return min(scores, key=lambda t: t[0])[1]