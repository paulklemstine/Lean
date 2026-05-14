def enumerate_optimal(eval_fn, back_fn, elements):
    """Find all fixed points of the closure operator."""
    return [p for p in elements if back_fn(eval_fn(p)) == p]

# Example
eval_fn = lambda p: max(p[0], p[1])
back_fn = lambda q: (q, q)
elements = [(a, b) for a in range(6) for b in range(6)]
optimal = enumerate_optimal(eval_fn, back_fn, elements)
print(optimal)  # [(0,0), (1,1), (2,2), (3,3), (4,4), (5,5)]