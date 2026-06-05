def hamming_distance(f, g):
    return sum(a != b for a, b in zip(f, g))