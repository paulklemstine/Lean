def lawvere_witness(phi, n, f):
    d = lambda x: f(phi(x, x))
    d_tuple = tuple(d(x) for x in range(n))
    for a in range(n):
        if tuple(phi(a, x) for x in range(n)) == d_tuple:
            return phi(a, a)
    return -1