def growth_test(powers: list[int]) -> dict:
    results = {}
    for k in powers:
        N = 2 ** k
        best = 0
        for n in range(1, N + 1):
            st = stopping_time(n)
            if st and st > best: best = st
        results[k] = {'max_st': best, 'ratio': best / (k*k)}
    return results