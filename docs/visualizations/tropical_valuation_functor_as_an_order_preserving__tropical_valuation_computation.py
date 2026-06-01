def padic_valuation(p, n):
    if n == 0: return float('inf')
    k = 0
    while n % p == 0:
        k += 1; n //= p
    return k