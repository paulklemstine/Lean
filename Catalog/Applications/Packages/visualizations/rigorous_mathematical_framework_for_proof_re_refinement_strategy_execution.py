def run_strategy(strategy, complexity, x):
    current = x
    steps = 0
    while steps <= complexity(x):
        result = strategy(current)
        if result is None:
            return current, steps
        current = result
        steps += 1
    return current, steps