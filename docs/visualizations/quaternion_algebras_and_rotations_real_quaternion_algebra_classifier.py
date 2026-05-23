def classify_real_qa(a, b):
    if a == 0 or b == 0:
        raise ValueError('Parameters must be nonzero')
    return 'division' if a < 0 and b < 0 else 'split'