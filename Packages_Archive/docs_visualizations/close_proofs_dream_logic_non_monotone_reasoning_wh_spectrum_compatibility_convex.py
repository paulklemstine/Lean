def compatible(s, t):
    """Per-axiom defects sum to at most 1."""
    return all(si + ti <= 1.0 for si, ti in zip(s, t))

def convex_blend(t1, t2, c):
    """If s~t1 and s~t2 then s~blend for all c in [0,1] (compatibility is convex)."""
    return [c * a + (1 - c) * b for a, b in zip(t1, t2)]
