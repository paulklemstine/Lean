def diagonal_language(enumeration):
    return lambda n: not enumeration(n)(n)

def verify_diagonal_separation(enumeration, num_checks=100):
    diag = diagonal_language(enumeration)
    for k in range(num_checks):
        assert enumeration(k)(k) != diag(k)
    return True