def normalize(t):
    """Normalize by exhaustive reduction. Always terminates."""
    steps = 0
    while True:
        next_t = reduce_step(t)
        if next_t is None: return t, steps
        t, steps = next_t, steps + 1