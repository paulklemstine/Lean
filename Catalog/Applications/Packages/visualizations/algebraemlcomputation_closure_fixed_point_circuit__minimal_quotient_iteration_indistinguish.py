def minimal_quotient(elements, F, cl, N):
    """Compute iteration-indistinguishability classes.
    
    Args:
        elements: List of all elements in the finite type
        F: Monotone inflationary function
        cl: Closure operator  
        N: Bound (typically |elements|)
    Returns:
        Dict mapping each element to its class ID
    """
    def profile(x):
        result = []
        current = x
        for _ in range(N + 1):
            result.append(cl(current))
            current = F(current)
        return tuple(result)
    
    profiles = {x: profile(x) for x in elements}
    unique_profiles = {}
    classes = {}
    class_id = 0
    for x in elements:
        p = profiles[x]
        if p not in unique_profiles:
            unique_profiles[p] = class_id
            class_id += 1
        classes[x] = unique_profiles[p]
    return classes