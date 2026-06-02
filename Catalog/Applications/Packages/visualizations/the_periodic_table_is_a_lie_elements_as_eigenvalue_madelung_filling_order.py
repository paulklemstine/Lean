def madelung_ordering(max_m=12):
    subshells = []
    for m in range(1, max_m + 1):
        for n in range(1, m + 1):
            l = m - n
            if l < n:
                subshells.append((n, l, 2*(2*l+1)))
    return subshells