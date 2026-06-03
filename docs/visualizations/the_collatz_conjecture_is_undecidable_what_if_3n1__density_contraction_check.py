def density_contraction_check(j, e):
    return {'is_descent': 3**j < 2**e, 'sufficient': 2*j <= e, 'sharp': j * 1.585 < e}