def tower(base: int, height: int) -> int:
    """tower(b,0)=1, tower(b,m+1)=b**tower(b,m): a stack of `height` copies of `base`."""
    value: int = 1
    for _ in range(height):
        value = base ** value
    return value

def stepping_up_upper_bound(graph_ramsey_bound: int, steps: int) -> int:
    """Iterate R_{r+1}(k+1,k+1) <= 2^{R_r(k,k)} starting from a graph bound.
    `steps` increments of uniformity stack `steps` exponentials on top of the base."""
    value: int = graph_ramsey_bound
    for _ in range(steps):
        value = 2 ** value
    return value
