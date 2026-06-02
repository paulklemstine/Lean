def symmetry_loss(q):
    pgl = q**3 * (q**3 - 1) * (q**2 - 1)
    hall = q**2 * (q**2 - 1) * q * (q - 1)
    return pgl / hall