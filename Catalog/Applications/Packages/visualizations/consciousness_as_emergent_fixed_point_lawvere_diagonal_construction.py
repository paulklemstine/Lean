def lawvere_diagonal(phi, f, domain_size):
    diagonal = lambda x: f(phi(x)(x))
    for a in range(domain_size):
        phi_a = phi(a)
        if all(phi_a(x) == diagonal(x) for x in range(domain_size)):
            return phi_a(a)
    return None