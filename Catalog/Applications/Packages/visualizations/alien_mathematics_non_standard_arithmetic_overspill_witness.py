def overspill_witness(P, max_n=1000):
    def f(i):
        best = 0
        for n in range(min(i+1, max_n)):
            if P(i, n): best = n
            else: break
        return best
    return f