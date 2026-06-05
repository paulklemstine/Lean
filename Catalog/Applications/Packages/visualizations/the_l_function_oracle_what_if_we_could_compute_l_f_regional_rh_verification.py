def verify_rh(zeros, tol=1e-10):
    return all(abs(z.real - 0.5) < tol for z in zeros if 0 < z.real < 1)