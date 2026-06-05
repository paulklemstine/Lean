def construct_eml_polynomial(coefficients):
    n = len(coefficients)
    if n == 0:
        return lambda x: 0.0
    def horner_eval(x):
        result = coefficients[-1]
        for i in range(n - 2, -1, -1):
            result = coefficients[i] + x * result
        return result
    return horner_eval