def sqrt_embedding(p):
    return np.sqrt(p)

def verify_on_sphere(p):
    sp = sqrt_embedding(p)
    return np.isclose(np.sum(sp**2), 1.0)