def sato_tate_second_moment(eigenvalues, weight, X):
    ps = [p for p in range(2, X+1) if is_prime(p) and p in eigenvalues]
    if not ps: return 0.0
    return sum(eigenvalues[p]**2 / p**(weight-1) for p in ps) / len(ps)