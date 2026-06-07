def hamming_distance(b1, b2):
    return sum(1 for x, y in zip(b1, b2) if x != y)