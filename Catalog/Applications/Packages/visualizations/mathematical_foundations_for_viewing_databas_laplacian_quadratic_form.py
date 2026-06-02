def laplacian_form(values, weights):
    n = len(values)
    deg_term = sum(sum(weights[i]) * values[i]**2 for i in range(n))
    cross_term = sum(weights[i][j] * values[i] * values[j] for i in range(n) for j in range(n))
    return deg_term - cross_term