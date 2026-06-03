def landauer_cost(f, domain):
    N = len(domain)
    if N == 0: return 0.0
    range_f = set(f(a) for a in domain)
    return math.log(N) - math.log(len(range_f))