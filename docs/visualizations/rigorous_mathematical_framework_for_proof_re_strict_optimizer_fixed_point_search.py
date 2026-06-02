def find_fixed_point(step, complexity, x):
    current = x
    for _ in range(complexity(x) + 1):
        next_state = step(current)
        if next_state == current:
            return current
        current = next_state
    return current