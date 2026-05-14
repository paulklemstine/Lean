def polynomial_interp(t):
    """Termination measure. Strictly decreases under reduction. O(n) time."""
    if t.kind == 'atom': return 2
    l, r = polynomial_interp(t.left), polynomial_interp(t.right)
    if t.kind == 'cut': return l * r
    if t.kind == 'plus': return l + r
    return l + r + 1  # min