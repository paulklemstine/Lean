def hamming_distance(b1, b2):
    return sum(1 for a, c in zip(b1, b2) if a != c)