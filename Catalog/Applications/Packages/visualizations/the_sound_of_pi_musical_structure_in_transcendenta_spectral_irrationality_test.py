def irrationality_test(digits, p, n_tests=10):
    for k in range(n_tests):
        r1 = sum(digits[i]*digits[i+k] for i in range(len(digits)-k-p))
        r2 = sum(digits[i]*digits[i+k+p] for i in range(len(digits)-k-p))
        if abs(r1 - r2) > 0: return True  # not periodic
    return False  # might be periodic