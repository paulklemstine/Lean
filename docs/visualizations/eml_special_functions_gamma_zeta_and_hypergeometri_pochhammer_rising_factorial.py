def pochhammer(a, n):
    result = 1.0
    for k in range(n): result *= (a + k)
    return result