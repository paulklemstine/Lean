def degree_obstruction_test(r_coeffs):
    deg = len(r_coeffs) - 1
    while deg >= 0 and abs(r_coeffs[deg]) < 1e-15:
        deg -= 1
    if deg < 0:
        return False, 'r = 0: omega = 0 is a solution'
    if deg % 2 == 1:
        return True, f'deg(r) = {deg} is odd => no polynomial Riccati solution'
    return False, f'deg(r) = {deg} is even => need further analysis'