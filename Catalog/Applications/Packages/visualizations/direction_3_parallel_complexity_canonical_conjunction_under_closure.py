def canonical_and(op, xs, method='balanced'):
    if method == 'sequential': return op(fold_and(xs))
    elif method == 'balanced': return op(balanced_and(xs))
    elif method == 'dedup': return op(fold_and(list(set(xs))))