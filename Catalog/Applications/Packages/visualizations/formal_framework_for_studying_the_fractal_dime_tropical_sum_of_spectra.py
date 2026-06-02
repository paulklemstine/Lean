def tropical_sum(counts1, counts2):
    return [max(c1, c2) for c1, c2 in zip(counts1, counts2)]