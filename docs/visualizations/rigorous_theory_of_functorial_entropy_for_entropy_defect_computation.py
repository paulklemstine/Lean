def entropy_defect(f, g, domain_f, codomain_f, codomain_g):
    H_f = functorial_entropy(f, domain_f, codomain_f)
    gf = lambda a: g(f(a))
    H_gf = functorial_entropy(gf, domain_f, codomain_g)
    return H_gf - H_f