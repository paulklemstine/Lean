def evaluate(t):
    """Evaluate a tropical proof term. O(n) time."""
    if t.kind == 'atom': return t.value
    l, r = evaluate(t.left), evaluate(t.right)
    if t.kind in ('cut', 'plus'): return l + r
    return min(l, r)