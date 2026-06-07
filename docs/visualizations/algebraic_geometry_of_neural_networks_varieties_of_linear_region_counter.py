def count_regions(network, samples):
    patterns = set()
    for x in samples:
        h = x
        pattern = []
        for layer in network.layers:
            pattern.extend(np.dot(n.weights, h) + n.bias >= 0 for n in layer.neurons)
            h = np.array([max(np.dot(n.weights, h) + n.bias, 0) for n in layer.neurons])
        patterns.add(tuple(pattern))
    return len(patterns)