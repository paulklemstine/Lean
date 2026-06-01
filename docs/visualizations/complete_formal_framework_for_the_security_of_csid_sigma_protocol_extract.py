def sigma_extract(ga, t0, t1):
    assert t0.commitment == t1.commitment
    return ga.multiply(t0.response, ga.inverse(t1.response))