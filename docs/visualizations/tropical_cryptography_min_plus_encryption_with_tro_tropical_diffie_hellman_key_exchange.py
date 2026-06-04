def tropical_dh(G, a, b):
    Ga = tropical_mat_pow(G, a)
    Gb = tropical_mat_pow(G, b)
    shared_a = tropical_mat_mul(Ga, Gb)
    shared_b = tropical_mat_mul(Gb, Ga)
    assert np.allclose(shared_a, shared_b)
    return shared_a