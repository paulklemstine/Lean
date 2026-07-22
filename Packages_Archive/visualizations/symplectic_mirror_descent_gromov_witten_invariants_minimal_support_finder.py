def find_minimal_supports(cl, target, universe):
    supports = []
    for size in range(len(universe) + 1):
        for combo in combinations(universe, size):
            candidate = frozenset(combo)
            if target in cl(candidate):
                is_minimal = all(not (prev < candidate) for prev in supports)
                if is_minimal:
                    for sub_size in range(size):
                        for sub in combinations(combo, sub_size):
                            if target in cl(frozenset(sub)):
                                is_minimal = False; break
                        if not is_minimal: break
                if is_minimal:
                    supports.append(candidate)
    return supports