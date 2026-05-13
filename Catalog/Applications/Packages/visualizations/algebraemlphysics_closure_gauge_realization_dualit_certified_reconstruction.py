def reconstruct_valuation(cl_fn, universe):
    cl_empty = cl_fn(frozenset())
    base = len(cl_empty)
    return {x: len(cl_fn(frozenset([x]))) - base for x in universe}