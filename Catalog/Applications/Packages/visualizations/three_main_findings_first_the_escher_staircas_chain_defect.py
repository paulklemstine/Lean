def chain_defect(seq):
    n = len(seq)
    for i in range(n):
        if all(seq[j] == seq[i] for j in range(i, n)):
            return i
    return None