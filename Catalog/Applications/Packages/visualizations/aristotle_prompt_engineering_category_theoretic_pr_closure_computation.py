def compute_closure(eval_fn, back_fn, p):
    """Compute cl(p) = back(eval(p)). Idempotent, so single application suffices."""
    return back_fn(eval_fn(p))

# Example
eval_fn = lambda p: max(p[0], p[1])
back_fn = lambda q: (q, q)
print(compute_closure(eval_fn, back_fn, (3, 7)))  # (7, 7)