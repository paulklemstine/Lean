def meaning_preserving_subgroup(elements, meaning):
    from itertools import permutations
    return [dict(zip(elements, p)) for p in permutations(elements)
            if all(meaning[p[i]] == meaning[i] for i, _ in enumerate(elements))]