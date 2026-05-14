def iterate_to_optimal(eval_fn, back_fn, p0, max_steps=1000):
    """Iterate closure until convergence. Guaranteed to terminate on finite P."""
    p = p0
    for step in range(max_steps):
        p_new = back_fn(eval_fn(p))
        if p_new == p:
            return p, step + 1
        p = p_new
    return p, max_steps

# Example
eval_fn = lambda p: max(p[0], p[1])
back_fn = lambda q: (q, q)
result, steps = iterate_to_optimal(eval_fn, back_fn, (3, 8))
print(f'{result} in {steps} step(s)')  # (8, 8) in 2 step(s)