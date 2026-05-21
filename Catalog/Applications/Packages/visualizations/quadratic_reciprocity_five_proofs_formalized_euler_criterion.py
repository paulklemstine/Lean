def euler_criterion(a, p):
    a = a % p
    if a == 0: return 0
    r = pow(a, (p - 1) // 2, p)
    return 1 if r == 1 else -1