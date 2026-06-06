def verify_soundness(algebra, provable):
    for s in provable:
        if not is_true(algebra.val(s)): return (False, s)
    return (True, None)