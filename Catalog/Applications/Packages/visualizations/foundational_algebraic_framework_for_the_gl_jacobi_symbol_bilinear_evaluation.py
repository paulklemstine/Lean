def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        raise ValueError('n must be a positive odd integer')
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0