def region_bound(widths):
    from functools import reduce
    montufar = reduce(lambda a, b: a * b, (w + 1 for w in widths), 1)
    exponential = 2 ** sum(widths)
    return min(montufar, exponential)