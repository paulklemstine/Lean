def deficiency(f, domain):
    return len(domain) - len(set(f(x) for x in domain))