def certificate(L, delta):
    assert L < 1 and delta >= 0
    return {"radius": delta / (1 - L), "L": L, "delta": delta}