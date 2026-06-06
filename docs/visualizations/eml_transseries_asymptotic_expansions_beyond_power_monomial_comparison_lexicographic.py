def compare_monomials(m1, m2):
    if m1.exp_coeff != m2.exp_coeff:
        return -1 if m1.exp_coeff < m2.exp_coeff else 1
    if m1.poly_exp != m2.poly_exp:
        return -1 if m1.poly_exp < m2.poly_exp else 1
    if m1.log_exp != m2.log_exp:
        return -1 if m1.log_exp < m2.log_exp else 1
    return 0