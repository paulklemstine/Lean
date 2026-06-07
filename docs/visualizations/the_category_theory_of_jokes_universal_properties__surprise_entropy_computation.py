def surprise_entropy(expected, punchlines, weights):
    return sum(w * abs(p - expected) for w, p in zip(weights, punchlines))