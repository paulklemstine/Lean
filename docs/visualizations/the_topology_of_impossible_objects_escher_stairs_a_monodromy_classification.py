def classify(weights):
    mono = sum(weights)
    if abs(mono) < 1e-12:
        h = [0.0]
        for w in weights[:-1]:
            h.append(h[-1] + w)
        return 'realizable', h
    return 'impossible', None