def mandelbrot_iter_mod(c: int, n: int, modulus: int) -> int:
    z = 0
    for _ in range(n):
        z = (z * z + c) % modulus
    return z