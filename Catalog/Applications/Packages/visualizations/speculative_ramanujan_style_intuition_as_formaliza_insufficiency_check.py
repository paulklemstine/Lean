def check_insufficiency(m, n, d):
    ball = sum(comb(n, i) for i in range(d + 1))
    return m * ball < 2**n