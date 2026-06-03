def spectral_energy(word, omega):
    import math
    cs = sum(w*math.cos(2*math.pi*omega*k) for k,w in enumerate(word))
    sn = sum(w*math.sin(2*math.pi*omega*k) for k,w in enumerate(word))
    return cs**2 + sn**2