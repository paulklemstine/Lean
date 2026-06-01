def hecke_seq(a, q, length):
    h = [0] * length
    h[0] = 1
    if length > 1: h[1] = a
    for n in range(2, length):
        h[n] = a * h[n-1] - q * h[n-2]
    return h