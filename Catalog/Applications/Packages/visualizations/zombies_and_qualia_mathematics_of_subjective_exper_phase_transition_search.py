def find_phase_transition(complexity_fn, threshold, max_n=1000):
    for n in range(max_n):
        if complexity_fn(n) > threshold:
            return n
    return None