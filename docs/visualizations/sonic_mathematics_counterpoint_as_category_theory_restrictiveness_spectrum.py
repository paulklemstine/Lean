def spectrum(consonances, perfect):
    counts = {}
    for a in consonances:
        for b in consonances:
            size = 3 if b in perfect else 4
            counts[size] = counts.get(size, 0) + 1
    return counts