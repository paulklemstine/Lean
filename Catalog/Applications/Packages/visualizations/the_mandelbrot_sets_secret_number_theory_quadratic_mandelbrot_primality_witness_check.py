def is_witness(c: int, n: int) -> bool:
    if mandelbrot_iter_mod(c, n, n) != 0:
        return False
    return all(mandelbrot_iter_mod(c, d, n) != 0 for d in range(1, n))