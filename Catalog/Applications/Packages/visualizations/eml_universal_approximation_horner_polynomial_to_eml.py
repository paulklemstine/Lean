def poly_to_eml(coeffs):
    if len(coeffs) <= 1: return Const(coeffs[0] if coeffs else 0)
    return Add(Const(coeffs[0]), Mul(Var(), poly_to_eml(coeffs[1:])))