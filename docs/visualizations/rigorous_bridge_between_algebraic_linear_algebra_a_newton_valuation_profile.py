def newton_profile(coeffs, p):
    return [p_adic_valuation(c, p) for c in coeffs]