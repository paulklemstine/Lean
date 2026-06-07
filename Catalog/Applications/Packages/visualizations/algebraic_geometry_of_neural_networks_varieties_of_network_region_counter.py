def network_complexity(widths):
    import math
    regions = math.prod(w + 1 for w in widths)
    patterns = 2 ** sum(widths)
    boundary = 2 * regions - 2
    return {'max_regions': regions, 'activation_patterns': patterns, 'boundary_components': boundary}