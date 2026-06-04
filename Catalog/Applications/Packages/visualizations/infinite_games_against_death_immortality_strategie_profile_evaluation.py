def evaluate_profile(can_survive):
    for n in range(100000):
        if not can_survive(n):
            return n - 1
    return 'omega'