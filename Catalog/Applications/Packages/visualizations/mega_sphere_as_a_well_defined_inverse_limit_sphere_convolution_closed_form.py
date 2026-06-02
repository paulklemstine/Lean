def sphere_convolution(n):
    if n % 2 == 1:
        return 0
    return 4 * (n // 2 + 1)