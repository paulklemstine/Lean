def knaster_tarski_lfp(f, universe):
    current = frozenset()
    while True:
        next_val = f(current)
        if next_val == current:
            return current
        current = next_val