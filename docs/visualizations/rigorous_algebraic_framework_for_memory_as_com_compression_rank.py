def compression_rank(f, domain):
    return len(set(f(a) for a in domain))