def approx_spectrum(f, a, b, eps_list):
    result = {}
    for eps in eps_list:
        for d in range(100):
            coeffs = taylor_coeffs(f, d)
            expr = horner_to_eml(coeffs)
            if max_error(f, expr, a, b) <= eps:
                result[eps] = expr.size()
                break
    return result