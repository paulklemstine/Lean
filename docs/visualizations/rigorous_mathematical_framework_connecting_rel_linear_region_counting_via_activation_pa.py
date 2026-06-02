def count_regions(weights, biases, num_samples=10000):
    import numpy as np
    patterns = set()
    input_dim = weights[0].shape[1]
    for _ in range(num_samples):
        x = np.random.uniform(-5, 5, size=input_dim)
        pattern = []
        h = x
        for W, b in zip(weights, biases):
            pre = W @ h + b
            pattern.extend(pre > 0)
            h = np.maximum(pre, 0)
        patterns.add(tuple(pattern))
    return len(patterns)