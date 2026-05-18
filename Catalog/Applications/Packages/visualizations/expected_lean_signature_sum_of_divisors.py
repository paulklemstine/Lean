def sum_of_divisors(n: int) -> int:
    if n <= 0: return 0
    total = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total