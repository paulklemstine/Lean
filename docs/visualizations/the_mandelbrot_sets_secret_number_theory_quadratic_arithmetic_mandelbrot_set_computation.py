def arithmetic_mandelbrot_set(p: int) -> dict:
    result = {}
    for c in range(p):
        z, period = 0, 0
        for n in range(1, p*p+2):
            z = (z*z + c) % p
            if z == 0:
                period = n
                break
        if period > 0:
            result[c] = period
    return result