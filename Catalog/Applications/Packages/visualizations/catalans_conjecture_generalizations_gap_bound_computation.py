def pillai_gap_bound(e, k):
    b0 = 2
    while (b0 + 1) ** e - b0 ** e <= k:
        b0 += 1
    return b0