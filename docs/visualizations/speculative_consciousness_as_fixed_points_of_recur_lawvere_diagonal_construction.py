def lawvere_diagonal(phi, f, domain):
    values = {}
    for a in domain:
        values[a] = f(phi(a)(a))
    return lambda x: values[x]