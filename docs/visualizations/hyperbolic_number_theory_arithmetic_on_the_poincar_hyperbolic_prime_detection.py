def find_hyp_primes(lattice, tol=1e-10):
    primes = []
    for p in lattice:
        if abs(p) < tol: continue
        decomposable = False
        for a in lattice:
            if abs(a) < tol: continue
            for b in lattice:
                if abs(b) < tol: continue
                if abs((a+b)/(1+a*b) - p) < tol:
                    decomposable = True; break
            if decomposable: break
        if not decomposable: primes.append(p)
    return primes