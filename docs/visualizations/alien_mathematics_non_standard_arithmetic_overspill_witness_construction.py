def overspill_witness(P, i):
    best = 0
    for n in range(i + 1):
        if all(P(i, k) for k in range(n + 1)):
            best = n
        else:
            break
    return best