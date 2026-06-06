def galois_closure(l, u, a):
    return u(l(a))

def verify_idempotent(l, u, a):
    cl = galois_closure(l, u, a)
    return galois_closure(l, u, cl) == cl