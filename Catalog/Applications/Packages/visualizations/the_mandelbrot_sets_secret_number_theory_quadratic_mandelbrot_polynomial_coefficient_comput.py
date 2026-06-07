def mandelbrot_poly_coeffs(n: int) -> list:
    if n == 0: return [0]
    poly = [0, 1]
    for _ in range(n - 1):
        deg = len(poly) - 1
        sq = [0] * (2*deg + 1)
        for i in range(deg+1):
            for j in range(deg+1):
                sq[i+j] += poly[i] * poly[j]
        while len(sq) < 2: sq.append(0)
        sq[1] += 1
        poly = sq
    return poly