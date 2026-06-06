def hamming_distance(b1, b2):
    return sum(1 for s1, s2 in zip(b1, b2) if s1 != s2)