def check_refinement(encode1, encode2, domain):
    for i, a in enumerate(domain):
        for b in domain[i+1:]:
            if encode1(a) == encode1(b) and encode2(a) != encode2(b):
                return False
    return True