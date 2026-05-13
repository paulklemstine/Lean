def reconstruct_quantizer(universe, closure_fn):
    """Reconstruct minimal quantizer from closure operator.
    Cells = closure classes of singletons."""
    cells = {}
    for a in universe:
        key = closure_fn(frozenset({a}))
        cells.setdefault(key, set()).add(a)
    return {i: frozenset(v) for i, (k, v) in enumerate(cells.items())}

# Example: partition closure on {0,1,2,3,4,5}
universe = {0, 1, 2, 3, 4, 5}
def cl(s):
    r = set(s)
    if any(x in r for x in [0,1,2]): r |= {0,1,2}
    if any(x in r for x in [3,4,5]): r |= {3,4,5}
    return frozenset(r)

q = reconstruct_quantizer(universe, cl)
for i, cell in q.items():
    print(f"Cell {i}: {sorted(cell)}")
