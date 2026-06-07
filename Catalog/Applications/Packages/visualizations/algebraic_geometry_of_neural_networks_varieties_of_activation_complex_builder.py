def build_activation_complex(weights, biases, x_samples):
    patterns = set()
    for x in x_samples:
        h = np.array([x]).reshape(1, -1)
        pattern = []
        for W, b in zip(weights[:-1], biases[:-1]):
            pre = h @ W.T + b
            pattern.extend(tuple(bool(v > 0) for v in pre.flatten()))
            h = np.maximum(pre, 0)
        patterns.add(tuple(pattern))
    return patterns