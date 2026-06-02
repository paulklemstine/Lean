def hall_mul(x, y, q, alpha_sq):
    if y[1] == 0:
        return ((x[0]*y[0])%q, (x[1]*y[0])%q)
    else:
        sx = frobenius(x, q)
        return field_mul(sx, y, q, alpha_sq)