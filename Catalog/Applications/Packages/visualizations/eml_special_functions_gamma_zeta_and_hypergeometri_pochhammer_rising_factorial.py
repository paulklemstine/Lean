def pochhammer(a, n):
    result = 1
    for k in range(n):
        result *= (a + k)
    return result