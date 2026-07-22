def construct_realization(cl, universe):
    base = len(cl(frozenset()))
    return {x: len(cl(frozenset([x]))) - base for x in universe}