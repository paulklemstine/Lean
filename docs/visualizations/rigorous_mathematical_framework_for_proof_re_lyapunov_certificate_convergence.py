def lyapunov_converge(step, potential, x):
    current = x
    for _ in range(potential(x) + 1):
        next_state = step(current)
        if potential(next_state) == potential(current):
            return current
        current = next_state
    return current