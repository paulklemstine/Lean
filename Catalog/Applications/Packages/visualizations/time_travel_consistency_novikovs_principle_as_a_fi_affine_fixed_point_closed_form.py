def affine_fixed_point(a, b):
    if abs(a) >= 1:
        raise ValueError('|a| must be < 1')
    return b / (1 - a)