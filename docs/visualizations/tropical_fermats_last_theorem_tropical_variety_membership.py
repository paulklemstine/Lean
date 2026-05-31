def is_in_tropical_variety(poly, x, y):
    values = [m.coeff + m.x_exp * x + m.y_exp * y for m in poly.monomials]
    min_val = min(values)
    return sum(1 for v in values if v == min_val) >= 2