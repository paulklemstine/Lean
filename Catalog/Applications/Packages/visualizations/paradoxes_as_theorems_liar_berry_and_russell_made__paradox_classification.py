def classify_fixed_point(v):
    if v != neg(v): return 'not_fixed'
    if is_true(v): return 'dialetheia'
    return 'gap'