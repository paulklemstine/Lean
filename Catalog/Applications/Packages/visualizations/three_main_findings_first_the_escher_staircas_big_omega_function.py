def big_omega(n):
    total = 0
    d = 2
    while d * d <= n:
        while n % d == 0:
            total += 1
            n //= d
        d += 1
    if n > 1:
        total += 1
    return total