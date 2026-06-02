def lawvere_diagonal(repr_func, t, domain):
    return {a: t(repr_func(a)(a)) for a in domain}