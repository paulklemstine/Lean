def certified_robustness_radius(W, b, S, x, norm_type="l2"):
    import numpy as np
    def affine_score(W, b, i, x):
        return float(np.dot(W[i], x) + b[i])
    def find_argmin(W, b, S, x):
        scores = [(affine_score(W, b, i, x), i) for i in S]
        return min(scores, key=lambda t: t[0])[1]
    i0 = find_argmin(W, b, S, x)
    score_i0 = affine_score(W, b, i0, x)
    min_margin = float("inf")
    for j in S:
        if j != i0:
            margin = affine_score(W, b, j, x) - score_i0
            diff = W[j] - W[i0]
            norm = np.linalg.norm(diff, 2 if norm_type=="l2" else 1)
            if norm > 1e-12:
                min_margin = min(min_margin, margin / norm)
    return min_margin