def check_ramanujan(A, q):
    evs = np.linalg.eigvalsh(A)
    bound = 2*np.sqrt(q)
    nontrivial = [e for e in evs if abs(abs(e)-(q+1)) > 1e-10]
    return all(abs(e) <= bound+1e-10 for e in nontrivial)