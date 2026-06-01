def tropical_eval(profile, t):
    return min(v_i + i * t for i, v_i in enumerate(profile))