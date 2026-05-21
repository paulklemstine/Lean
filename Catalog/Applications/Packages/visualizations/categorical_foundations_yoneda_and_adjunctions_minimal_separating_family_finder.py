def find_minimal_separating_family(cat):
    """Find minimal separating probe family by exhaustive search."""
    from itertools import combinations
    for size in range(1, len(cat.objects) + 1):
        for probes in combinations(cat.objects, size):
            if is_separating_family(cat, list(probes)):
                return list(probes)
    return cat.objects