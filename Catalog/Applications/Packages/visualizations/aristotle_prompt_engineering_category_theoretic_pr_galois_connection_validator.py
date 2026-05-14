def validate_gc(eval_fn, back_fn, p_elts, q_elts, p_le, q_le):
    """Check eval(p) <= q iff p <= back(q) for all p, q."""
    for p in p_elts:
        for q in q_elts:
            if q_le(eval_fn(p), q) != p_le(p, back_fn(q)):
                return False, (p, q)
    return True, None

# Example
p_elts = [(a,b) for a in range(5) for b in range(5)]
q_elts = list(range(5))
valid, _ = validate_gc(
    lambda p: max(p[0],p[1]), lambda q: (q,q),
    p_elts, q_elts,
    lambda a,b: a[0]<=b[0] and a[1]<=b[1],
    lambda a,b: a<=b)
print(f'Valid: {valid}')  # True