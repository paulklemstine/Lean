def eisenstein_legendre(a, p):
    a = a % p
    if a == 0: return 0
    s = sum((k * a) // p for k in range(1, (p - 1) // 2 + 1))
    return (-1) ** s