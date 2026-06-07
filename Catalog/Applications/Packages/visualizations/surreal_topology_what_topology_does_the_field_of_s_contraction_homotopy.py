def contraction_path(x, steps=100):
    return [(t/steps, (1 - t/steps) * x) for t in range(steps + 1)]