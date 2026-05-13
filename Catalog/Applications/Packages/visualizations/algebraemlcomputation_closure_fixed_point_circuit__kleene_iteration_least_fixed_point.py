def kleene_iteration(F, cl, x, N):
    """Compute the least fixed point above cl(x) by Kleene iteration.
    
    Args:
        F: Monotone inflationary function
        cl: Closure operator
        x: Starting element
        N: Bound (typically |alpha|)
    Returns:
        The least fixed point above cl(x)
    """
    y = cl(x)
    for _ in range(N):
        y = F(y)
    return y