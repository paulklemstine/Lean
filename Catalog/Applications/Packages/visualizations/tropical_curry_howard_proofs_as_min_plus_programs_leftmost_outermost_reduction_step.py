def reduce_step(t):
    """Apply leftmost-outermost reduction. Returns None if normal. O(n) time."""
    if t.kind == 'min' and t.left == t.right: return t.left
    if t.kind == 'cut':
        if t.left.kind == 'min':
            return Term('min', left=Term('cut', left=t.left.left, right=t.right),
                               right=Term('cut', left=t.left.right, right=t.right))
        if t.right.kind == 'min':
            return Term('min', left=Term('cut', left=t.left, right=t.right.left),
                               right=Term('cut', left=t.left, right=t.right.right))
    if t.kind != 'atom':
        sl = reduce_step(t.left)
        if sl: return Term(t.kind, left=sl, right=t.right)
        sr = reduce_step(t.right)
        if sr: return Term(t.kind, left=t.left, right=sr)
    return None