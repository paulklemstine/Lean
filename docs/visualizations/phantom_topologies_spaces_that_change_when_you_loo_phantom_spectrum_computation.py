def phantom_spectrum(observers, consensus, X):
    spectrum = {x: set() for x in X}
    for i, t in enumerate(observers):
        for U in set(t) - set(consensus):
            for x in U:
                spectrum[x].add(i)
    return spectrum