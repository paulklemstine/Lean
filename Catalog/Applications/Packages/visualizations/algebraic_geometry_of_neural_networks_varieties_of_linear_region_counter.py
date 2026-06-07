def max_linear_regions_1d(widths):
    result = 1
    for w in widths:
        result *= (w + 1)
    return result