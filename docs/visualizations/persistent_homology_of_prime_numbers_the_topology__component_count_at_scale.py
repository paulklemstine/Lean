def count_components(gaps, epsilon):
    return 1 + sum(1 for g in gaps if g > epsilon)