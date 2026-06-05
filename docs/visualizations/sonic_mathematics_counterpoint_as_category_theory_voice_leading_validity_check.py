def is_valid_vl(interval, delta_u, delta_l, n=12, consonant={0,3,4,7,8,9}, perfect={0,7}):
    target = (interval + delta_u - delta_l) % n
    if interval not in consonant or target not in consonant:
        return False
    if interval in perfect and target == interval and delta_u % n == delta_l % n and delta_u % n != 0:
        return False
    return True