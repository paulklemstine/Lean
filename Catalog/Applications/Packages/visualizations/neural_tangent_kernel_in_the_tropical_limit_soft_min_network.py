def soft_min_network(W, b, S, x, tau):
    import numpy as np
    scores = np.array([np.dot(W[i], x) + b[i] for i in S])
    min_score = np.min(scores)
    shifted = -(scores - min_score) / tau
    return -tau * np.log(np.sum(np.exp(shifted))) + min_score