def tropical_hecke_seq(a, q, length):
    t = [0.0] * length
    if length > 1: t[1] = a
    for n in range(2, length):
        t[n] = min(a + t[n-1], q + t[n-2])
    return t