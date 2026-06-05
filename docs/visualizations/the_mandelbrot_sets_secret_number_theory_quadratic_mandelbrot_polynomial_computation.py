def mandelbrot_poly(n):
    if n == 0: return [0]
    p = [0, 1]
    for _ in range(n-1):
        d = len(p)
        sq = [0]*(2*d-1)
        for i in range(d):
            for j in range(d):
                sq[i+j] += p[i]*p[j]
        sq[1] += 1
        p = sq
    return p