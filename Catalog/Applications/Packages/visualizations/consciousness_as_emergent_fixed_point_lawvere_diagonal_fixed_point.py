def lawvere_diagonal(phi, f, domain):
    d = lambda x: f(phi(x)(x))
    for a in domain:
        if all(phi(a)(x) == d(x) for x in domain):
            return phi(a)(a)
    return None