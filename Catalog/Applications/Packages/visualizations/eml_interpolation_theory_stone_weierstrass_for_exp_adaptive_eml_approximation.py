def adaptive_eml(f, eps, max_d=100):
    for d in range(1, max_d+1):
        c, err = eml_least_squares(f, d)
        if err < eps: return c, d, err
    return c, max_d, err