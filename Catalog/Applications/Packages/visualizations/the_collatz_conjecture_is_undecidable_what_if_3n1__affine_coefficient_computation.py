def compute_affine_iterative(w):
    slope, intercept = Fraction(1), Fraction(0)
    for b in reversed(w):
        if b:
            intercept = slope + intercept
            slope = 3 * slope
        else:
            slope = slope / 2
    return slope, intercept