def verify_two_infinity(stable_level, has_tqft, has_string):
    if stable_level == 0 and has_tqft:
        return False  # Obj(0) trivial contradicts TQFT
    if stable_level == 1 and has_string:
        return False  # Obj(1) trivial contradicts String
    return True